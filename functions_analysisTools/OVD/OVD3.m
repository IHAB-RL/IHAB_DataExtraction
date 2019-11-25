function [stDataReal] = OVD3(Cxy, Pxx, Pyy, fs, mRMS)
% Cxy - cross power spectral density
% Pxx, Pyy - auto power spectral density
% data format: time x frequency
% fs - sampling frequency
% optional mRMS - rms vector in dB SPL

% number of frames
nFrames = size(Cxy,1);

% number of frequency bins
nFreqBins = size(Cxy,2);

% OWN VOICE DETECTION------------------------------------------------------
isprivacy = true;
stDataReal.Coh = zeros(nFrames, nFreqBins);
nFFT = 2*(nFreqBins - 1);

% Think of assessing the OVD per minute
% 480 frames is one minute
curCxy = zeros(nFrames, nFreqBins);
curPxx = zeros(nFrames, nFreqBins);
curPyy = zeros(nFrames, nFreqBins);

%% NS
MIN_COH = 0.1;
MIN_RMS = 10^(-40/20);

vFreqRange = [140 1500];
vFreqBins = round(vFreqRange./fs*nFFT); % 5:40. 6:64 17:43

%% JP
% MIN_COH = 0.3;
% MIN_RMS = 10^(-45/20); % -> for dB FS
% 
% vFreqRange = [400 1000];
% vFreqBins = round(vFreqRange./fs*nFFT); % 5:40. 6:64 17:43


% smoothing PSD data for 3 adjacent frames respectively
for iFrame = 1:nFrames
    if iFrame == 1
        curCxy(iFrame,:) = mean(Cxy(iFrame:iFrame+1,:));
        curPxx(iFrame,:) = mean(Pxx(iFrame:iFrame+1,:));
        curPyy(iFrame,:) = mean(Pyy(iFrame:iFrame+1,:));
    elseif iFrame < nFrames
        curCxy(iFrame,:) = mean(Cxy(iFrame-1:iFrame+1,:));
        curPxx(iFrame,:) = mean(Pxx(iFrame-1:iFrame+1,:));
        curPyy(iFrame,:) = mean(Pyy(iFrame-1:iFrame+1,:));
    else
        curCxy(iFrame,:) = mean(Cxy(iFrame-1:iFrame,:));
        curPyy(iFrame,:) = mean(Pyy(iFrame-1:iFrame,:));
        curPxx(iFrame,:) = mean(Pxx(iFrame-1:iFrame,:));
    end
end

% 'A weighting' is probably not needed because it should only be calculated
% on noise and not on levels with speech
[A_log,A_lin] = a_weighting(nFFT,fs);

if ~exist('mRMS', 'var')
    % Divide by 4 as a scaling to RMS feature; has to be checked if real
    % features are used
    stDataReal.curRMSfromPxx = sqrt(sum((fs/nFFT).*curPxx, 2))./4;
    stDataReal.curRMS_A = sqrt(sum((fs/nFFT).*curPxx'.*A_lin/10^(-2/20)))./4;
else
    stDataReal.curRMSfromPxx = mRMS(:,1);
    
    MIN_RMS = 30; % dB SPL
end

% Calculate coherence
stDataReal.Coh = curCxy./(sqrt(curPxx.*curPyy) + eps);

% Calculate 'mean real coherence' over a number of bins times the factor
% where cross power density is also high
stDataReal.meanCoheTimesCxy = mean(real(stDataReal.Coh(:,vFreqBins(1):vFreqBins(2))),2);%.*fac; 


% Calculate a priori SNR
noisy = [fliplr(curPxx+curPyy); curPxx+curPyy];
clear curPxx curPyy curCxy;
[~, stDataReal.snrPrio, ~,stDataReal.PH1] = timoundjoergNils(noisy,fs,1);
clear noisy;
% new frequency range
vFreqRange = [120 1000];
vFreqBins = round(vFreqRange./fs*nFFT);
stDataReal.meanLogSNRPrio = 20*log10(mean(stDataReal.snrPrio(vFreqBins(1):vFreqBins(2),:),1));

% Set window size dependent on privacy parameter; should actually always be
% private, but because of evaluation reasons it has been a bigger window
if isprivacy
    stDataReal.winLen = floor(nFFT/10);
else
    stDataReal.winLen = nFFT;
end

% 'Overall level'
stDataReal.movAvgSNR = movmax(stDataReal.meanLogSNRPrio,stDataReal.winLen);

% This parameters are set dependent on 'overall level'
stDataReal.a_rms = 0.15.*ones(nFrames, 1); % NS
stDataReal.a_rms(stDataReal.movAvgSNR >= 30) = 0.2;
% stDataReal.a_rms = 0.5.*ones(nFrames, 1); % JP

stDataReal.a_cohe = 0.3.*ones(nFrames, 1);
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

