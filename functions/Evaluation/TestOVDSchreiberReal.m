% test script to evaluate the Own Voice Detection (OVD)
% by Nils Schreiber (Master 2019)
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
%
% contains mainTest.m and main.m by Nils Schreiber (IHAB_DB)
% make use of daily recordings from Nils Schreiber
% ground truth ovs are labeled with 0 (Schreiber)
% ground truth fvs are labeled with 1, 2, 3 (Schreiber) dependent on the
% number of voices
%
% Version History:
% Ver. 0.01 initial create 18-Sep-2019 	JP

clear; close all;

% set path to data folder
dataPath = 'K:\IHAB_DB\OVD_nils';

% set name of test subject
subject = 'IN05NZ08';

% number of measurement configuration
config = 1;

% preallocation of the foldername
prefix  = 'config';


% construct the path where the induvidual subject data are stored
path = [dataPath filesep subject filesep prefix num2str(config)];
audiofile = [path filesep subject '_' prefix num2str(config) '.wav'];
[stParam.mSignal,fs] = audioread(audiofile);

stParam.privacy     = true;
if stParam.privacy
    stParam.fs      = fs/2;
    stParam.mSignal = resample(stParam.mSignal, stParam.fs, fs);
else
    stParam.fs      = fs;
end
sampleLen           = size(stParam.mSignal,1);
timeLen             = sampleLen/stParam.fs;
stTime.vTime        = linspace(0,timeLen,sampleLen);



stParam.tFrame      = 0.025; % block length in sec (Sascha)
stParam.lFrame      = floor(stParam.tFrame*stParam.fs); % block length in samples
stParam.lOverlap    = stParam.lFrame/2; % overlap adjacent blocks
stParam.nFFT        = 1024; % number of fast Fourier transform points
stParam.vFreqRange  = [400 1000]; % frequency range of interest in Hz
stParam.vFreqBins   = round(stParam.vFreqRange./stParam.fs*stParam.nFFT);
stParam.tFrame      = 0.125; % Nils
stParam.tauCoh      = 0.1; % Nils
stParam.fixThresh   = 0.6; % fixed coherence threshold
stParam.adapThreshWin  = 0.05*stParam.fs; % window length for the adaptive threshold
stParam.winLen      = floor(stParam.nFFT/10); % normalized window length (Nils)

% [stDataReal] = computeSpectraAndCoherence(stParam);
[stDataReal] = detectOVSRealCoherence(stParam);


% calculate a time vector for the coherence data
stTime.vTimeCoh = linspace(0,timeLen,size(stDataReal.Pxx,2));


%% DETECTION
% Bilert 2018
[stDataBilert] = OVD_Bilert(stParam, stDataReal);


% Schreiber 2019
[stDataOVD] = OVD3(stDataReal.Cxy,stDataReal.Pxx,stDataReal.Pyy,stParam.fs);

[stDataFVD] = FVD3(stDataOVD.vOVS,stDataOVD.snrPrio,stDataOVD.movAvgSNR);

%% Ground truths
if stParam.privacy == true
    fsOVD = 8;
else
    fsOVD = 80;
end

gtFile = fullfile(path,[subject '_config' num2str(config) '.txt']);

vActVoice = importdata(gtFile);


%% OVS
ovsIndicator = 0; 
startTimeOVS = vActVoice(vActVoice(:,3)==ovsIndicator, 1);
endTimeOVS = vActVoice(vActVoice(:,3)==ovsIndicator, 2);

startIdxOVS = round(startTimeOVS*fsOVD);
startIdxOVS(startIdxOVS==0) = 1;
endIdxOVS = round(endTimeOVS*fsOVD);
outOfBounceStart = find(startIdxOVS>size(stDataOVD.vOVS(:)',2),1);
outOfBounceEnd = find(endIdxOVS>size(stDataOVD.vOVS(:)',2),1);
if ~isempty(outOfBounceEnd) && ~isempty(outOfBounceStart)
    endIdxOVS(outOfBounceEnd:end) = [];
    startIdxOVS(outOfBounceEnd:end) = [];
    
elseif ~isempty(outOfBounceEnd) && startIdxOVS(outOfBounceEnd) <= size(stDataOVD.vOVS(:)',2)
    endIdxOVS(outOfBounceEnd) = size(stDataOVD.vOVS(:)',2);
    if length(endIdxOVS)>outOfBounceEnd
        endIdxOVS(outOfBounceEnd+1:end) = [];
        startIdxOVS(outOfBounceEnd+1:end) = [];
    end
end

stDataReal.vActivOVS = zeros(1,size(stDataOVD.vOVS(:)',2));

for ll = 1:size(startIdxOVS,1)
    stDataReal.vActivOVS(startIdxOVS(ll):endIdxOVS(ll)) = 1;
end

%% evaluate performace OVD
disp(['prob: ' subject ' conf' num2str(config) ':'])
% fix
[stResults.F2ScoreOVS_fix,stResults.precOVS_fix,stResults.recOVS_fix] = F1M(stDataBilert.vOVS_fix, stDataReal.vActivOVS);
stResults.mConfusion_fix = getConfusionMatrix(stDataBilert.vOVS_fix, stDataReal.vActivOVS);

% adaptiv Bilert
[stResults.F2ScoreOVS_Bilert,stResults.precOVS_Bilert,stResults.recOVS_Bilert] = F1M(stDataBilert.vOVS_adap, stDataReal.vActivOVS);
stResults.mConfusion_Bilert = getConfusionMatrix(stDataBilert.vOVS_adap, stDataReal.vActivOVS);

% adaptiv Nils
[stResults.F2ScoreOVS_Schreiber,stResults.precOVS_Schreiber,stResults.recOVS_Schreiber] = F1M(stDataOVD.vOVS, stDataReal.vActivOVS);
stResults.mConfusion_Schreiber = getConfusionMatrix(stDataOVD.vOVS, stDataReal.vActivOVS);


%% FVS
fvsIndicator = [1 2 3]; 
startTimeFVS = vActVoice((vActVoice(:,3)==fvsIndicator(1) | vActVoice(:,3)==fvsIndicator(2) | vActVoice(:,3)==fvsIndicator(3)),1);
endTimeFVS = vActVoice((vActVoice(:,3)==fvsIndicator(1) | vActVoice(:,3)==fvsIndicator(2) | vActVoice(:,3)==fvsIndicator(3)),2);

startIdxFVS = round(startTimeFVS*fsOVD);
startIdxFVS(startIdxFVS==0) = 1;
endIdxFVS = round(endTimeFVS*fsOVD);
outOfBounceStart = find(startIdxFVS>size(stDataFVD.vFVS(:)',2),1);
outOfBounceEnd = find(endIdxFVS>size(stDataFVD.vFVS(:)',2),1);
if ~isempty(outOfBounceEnd) && ~isempty(outOfBounceStart)
    endIdxFVS(outOfBounceEnd:end) = [];
    startIdxFVS(outOfBounceEnd:end) = [];
    
elseif ~isempty(outOfBounceEnd) && startIdxFVS(outOfBounceEnd) <= size(stDataFVD.vFVS(:)',2)
    endIdxFVS(outOfBounceEnd) = size(stDataFVD.vFVS(:)',2);
    if length(endIdxFVS)>outOfBounceEnd
        endIdxFVS(outOfBounceEnd+1:end) = [];
        startIdxFVS(outOfBounceEnd+1:end) = [];
    end
end

stDataReal.vActivFVS = zeros(1,size(stDataFVD.vFVS(:)',2));

for ll = 1:size(startIdxFVS,1)
    stDataReal.vActivFVS(startIdxFVS(ll):endIdxFVS(ll)) = 1;
end

%% evaluate performace FVD
[stResults.F2ScoreFVS,stResults.precFVS,stResults.recFVS] = F1M(stDataFVD.vFVS, stDataReal.vActivFVS);
stResults.mConfusion_FVD = getConfusionMatrix(stDataFVD.vFVS, stDataReal.vActivFVS);


plot_time = 1;
if plot_time
    groundTrOVS = stDataReal.vActivOVS;
    groundTrFVS = stDataReal.vActivFVS;
    
    vOVS = double(stDataOVD.vOVS);
    vFVS = double(stDataFVD.vFVS);
    
    % pre allocation
    vHit.OVD = zeros(size(vOVS));
    vFalseAlarm.OVD = zeros(size(vOVS));
    vHit.FVD = zeros(size(vFVS));
    vFalseAlarm.FVD = zeros(size(vFVS));
    
    vHit.OVD(groundTrOVS == vOVS) = groundTrOVS(groundTrOVS == vOVS);
    vFalseAlarm.OVD(groundTrOVS ~= vOVS) = vOVS(groundTrOVS ~= vOVS);
    vHit.FVD(groundTrFVS == vFVS) = groundTrFVS(groundTrFVS == vFVS);
    vFalseAlarm.FVD(groundTrFVS ~= vFVS) = vFVS(groundTrFVS ~= vFVS);
    
%     groundTrOVS(groundTrOVS == 0) = NaN;
%     groundTrFVS(groundTrFVS == 0) = NaN;
    stDataBilert.vOVS_fix(stDataBilert.vOVS_fix == 0)= NaN;
    stDataBilert.vOVS_adap(stDataBilert.vOVS_adap == 0)= NaN;
    
    % plot OVD
    f1 = figure;
    f1.Position = [400 50 1100 1050];
    f1_left = 0.13;
    f1_width = 0.8;
    mTextTitle = uicontrol(gcf,'style','text');
    set(mTextTitle,'Units','normalized','Position', [0.25 0.95 0.6 0.05], 'String','Own Voice Detection','FontSize',16);
    
    axTime = axes('Position',[f1_left 0.65 f1_width 0.27]);
    plot(stTime.vTime, stParam.mSignal(:,1), 'Color', [0.4 0.4 0.4]);
    hold on;
    plot(stTime.vTimeCoh, groundTrOVS, 'k','LineWidth', 1.5);
    plot(stTime.vTimeCoh, vHit.OVD, 'r', 'LineWidth', 2);
    plot(stTime.vTimeCoh, vFalseAlarm.OVD, 'Color', [0.7 0.7 0.7]);
    lgd = legend('time signal', 'ground truth', 'hits', 'false alarm');
    lgd.Location = 'southwest';
    lgd.NumColumns = 2;
    title('timesignal');
    xlabel('time in s \rightarrow');
    ylabel('amplitude \rightarrow');
    ylim([-1.3 1.3]);
    PosVecTime = get(axTime,'Position');
    
    axOVD = axes('Position',[f1_left 0.34 PosVecTime(3) 0.23]);
    plot(stTime.vTimeCoh, stDataOVD.meanCoheTimesCxy,'Color', [0.4 0.4 0.4]);
    hold on;
    plot(stTime.vTimeCoh, stDataOVD.adapThreshCohe,'r');
%     plot(stTime.vTimeCoh, stDataBilert.adapThresh,'b');
    plot(stTime.vTimeCoh, 1.2*stDataBilert.vOVS_fix, 'mo','MarkerSize',5);
    plot(stTime.vTimeCoh, 1.1*stDataBilert.vOVS_adap, 'bo','MarkerSize',5);
    ylim([-0.3 1.3]);
%     lgd = legend('coherence', 'Threshold Schreiber', 'Threshold Bilert', 'Bitzer', 'Bilert');
    lgd = legend('coherence', 'Threshold Schreiber', 'Bitzer', 'Bilert');
    lgd.Location = 'southwest';
    lgd.NumColumns = 3;
    title('avg. Coherence');
    xlabel('time in s \rightarrow');
    ylabel('coherence \rightarrow');
    PosVecOVD = get(axOVD,'Position');
    
    axRMS = axes('Position',[f1_left 0.04 PosVecTime(3) PosVecOVD(4)]);
    plot(stTime.vTimeCoh, stDataOVD.curRMSfromPxx,'Color', [0.4 0.4 0.4]);
    hold on;
    plot(stTime.vTimeCoh, stDataOVD.adapThreshRMS,'r');
    title('RMS');
    xlabel('time in s \rightarrow');
    ylabel('amplitude \rightarrow');
    
    linkaxes([axOVD,axRMS,axTime],'x');
    
    exportName = [path filesep 'Results_OVD_' subject '_config' num2str(config)];
    savefig(exportName);

    
    % plot FVD
    f2 = figure;
    f2.Position = [400 300 1100 700];
    plot(stTime.vTime, stParam.mSignal(:,1), 'Color', [0.4 0.4 0.4]);
    hold on;
    plot(stTime.vTimeCoh, groundTrFVS, 'k', 'LineWidth', 1.5);
    plot(stTime.vTimeCoh, vHit.FVD, 'r', 'LineWidth', 2);
    plot(stTime.vTimeCoh, vFalseAlarm.FVD, 'Color', [0.7 0.7 0.7]);
    vOVS(vOVS == 0) = NaN;
    plot(stTime.vTimeCoh, 1.2*vOVS, 'ob', 'LineWidth', 1.5);
    lgd = legend('time signal', 'ground truth', 'hits', 'false alarm', 'ovs');
    lgd.Location = 'southwest';
    lgd.NumColumns = 2;
    title('Futher Voice Detection');
    xlabel('time in s \rightarrow');
    ylabel('amplitude \rightarrow');
    ylim([-1.3 1.3]);
    
    exportName = [path filesep 'Results_FVD_' subject '_config' num2str(config)];
    savefig(exportName);
end

% save results as mat file
save(['Results_OVD_FVD_Real_' subject], 'stResults');


% % display results as table
% F2 = [stResults.F2ScoreOVS_fix stResults.F2ScoreOVS_Bilert stResults.F2ScoreOVS_Schreiber]';
% prec = [stResults.precOVS_fix stResults.precOVS_Bilert stResults.precOVS_Schreiber]';
% rec = [stResults.recOVS_fix stResults.recOVS_Bilert stResults.recOVS_Schreiber]';
% 
% T = table(F2,prec,rec,'VariableNames',{'F2Score' 'precision' 'recall'},'RowNames',{'Bitzer et al. 2016' 'Bilert 2018' 'Schreiber 2019'});


% plot confusion matrix
vLabels = {'OVS', 'no OVS'};
plotConfusionMatrix(stResults.mConfusion_fix, vLabels);
plotConfusionMatrix(stResults.mConfusion_Bilert, vLabels);
plotConfusionMatrix(stResults.mConfusion_Schreiber, vLabels);

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
% Jade University of Applied Sciences
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


% eof