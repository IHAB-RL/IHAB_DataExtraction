function [stDataReal] = OVD3(Cxy, Pxx, Pyy, fs)

% OWN VOICE DETECTION------------------------------------------------------
isprivacy = true;
% isOVS = zeros(size(Cxy,2),1);
stDataReal.Coh = zeros(size(Cxy));
fftSize = (size(Cxy,1)-1)*2;
vFreqRange = [140 1500];
vFreqBins = round(vFreqRange./fs*fftSize); % 5:40. 6:64 17:43
coheThresh = 0.5.*ones(size(Cxy,2),1);

% Think of assessing the OVD per minute
% 480 frames is one minute
curCxy = zeros(size(Cxy));
curPxx = zeros(size(Cxy));
curPyy = zeros(size(Cxy));


MIN_COH = 0.1;
MIN_RMS = 10^(-40/20);

% smoothing PSD data for 3 adjacent frames respectively
for iFrame = 1:size(Cxy,2)
    if iFrame == 1
        curCxy(:,iFrame) = mean(Cxy(:,iFrame:iFrame+1),2);
        curPxx(:,iFrame) = mean(Pxx(:,iFrame:iFrame+1),2);
        curPyy(:,iFrame) = mean(Pyy(:,iFrame:iFrame+1),2);
    elseif iFrame < size(Cxy,2)
        curCxy(:,iFrame) = mean(Cxy(:,iFrame-1:iFrame+1),2);
        curPxx(:,iFrame) = mean(Pxx(:,iFrame-1:iFrame+1),2);
        curPyy(:,iFrame) = mean(Pyy(:,iFrame-1:iFrame+1),2);
    else
        curCxy(:,iFrame) = mean(Cxy(:,iFrame-1:iFrame),2);
        curPyy(:,iFrame) = mean(Pyy(:,iFrame-1:iFrame),2);
        curPxx(:,iFrame) = mean(Pxx(:,iFrame-1:iFrame),2);
    end
end

% 'A weighting' is probably not needed because it should only be calculated
% on noise and not on levels with speech
[A_log,A_lin] = a_weighting(fftSize,fs);

% Divide by 4 as a scaling to RMS feature; has to be checked if real
% features are used
stDataReal.curRMSfromPxx = sqrt(sum((fs/fftSize).*curPxx,1))./4;
stDataReal.curRMS_A = sqrt(sum((fs/fftSize).*curPxx.*A_lin(:)/10^(-2/20),1))./4;

% Calculate coherence
stDataReal.Coh = curCxy./(sqrt(curPxx.*curPyy) + eps);

% Calculate 'mean real coherence' over a number of bins times the factor
% where cross power density is also high
stDataReal.meanCoheTimesCxy = mean(real(stDataReal.Coh(vFreqBins(1):vFreqBins(2),:)),1);%.*fac; 


% Calculate a priori SNR
noisy = [fliplr(curPxx+curPyy) curPxx+curPyy];
clear curPxx curPyy curCxy;
[~, stDataReal.snrPrio, ~,stDataReal.PH1] = timoundjoergNils(noisy,fs,1);
clear noisy;
stDataReal.meanLogSNRPrio = 20*log10(mean(stDataReal.snrPrio(5:43,:),1));

% Set window size dependent on privacy parameter; should actually always be
% private, but because of evaluation reasons it has been a bigger window
if isprivacy
    stDataReal.winLen = floor(fftSize/10);
else
    stDataReal.winLen = fftSize;
end

% 'Overall level'
stDataReal.movAvgSNR = movmax(stDataReal.meanLogSNRPrio,stDataReal.winLen);

% This parameters are set dependent on 'overall level'
stDataReal.a_cohe = 0.3.*ones(1,length(coheThresh));
stDataReal.a_rms = 0.15.*ones(1,length(coheThresh));
stDataReal.a_rms(stDataReal.movAvgSNR >= 30) = 0.2;
stDataReal.a_cohe(stDataReal.movAvgSNR >= 20) = 0.5;
stDataReal.a_cohe(stDataReal.movAvgSNR >= 30) = 0.4;
stDataReal.a_cohe(stDataReal.movAvgSNR >= 40) = 0.5;
stDataReal.a_cohe(stDataReal.movAvgSNR >= 50) = 0.4;

% Sliding max and min
stDataReal.adapThreshMax = movmax(stDataReal.meanCoheTimesCxy,stDataReal.winLen);
stDataReal.adapThreshMin = movmin(stDataReal.meanCoheTimesCxy,stDataReal.winLen);
stDataReal.adapThreshMaxRMS = movmax(stDataReal.curRMSfromPxx,stDataReal.winLen.*1.5);
stDataReal.adapThreshMinRMS = movmin(stDataReal.curRMSfromPxx,stDataReal.winLen.*1.5);

% Adaptive thresholds
stDataReal.adapThreshCohe = (stDataReal.a_cohe.*stDataReal.adapThreshMax + (1-stDataReal.a_cohe).*stDataReal.adapThreshMin);
stDataReal.adapThreshCohe = max(stDataReal.adapThreshCohe, MIN_COH);
stDataReal.adapThreshRMS = (stDataReal.a_rms.*stDataReal.adapThreshMaxRMS + (1-stDataReal.a_rms).*stDataReal.adapThreshMinRMS);
stDataReal.adapThreshRMS = max(stDataReal.adapThreshRMS, MIN_RMS);
stDataReal.vOVS = (stDataReal.meanCoheTimesCxy >= stDataReal.adapThreshCohe ...
                 &  stDataReal.curRMSfromPxx >= stDataReal.adapThreshRMS);
end

