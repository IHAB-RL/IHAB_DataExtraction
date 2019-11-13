function plotFingerprintAnalysis(obj)
% function to plot fingerprint an analysis overview for objective data
% figure displays PSD, Re(Cohe), RMS, Correlation
% Usage: plotFingerprintAnalysis(obj)
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version histogramory:
% Ver. 0.01 initial create 08-Nov-2019  JP


% reading objective data, desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD, TimeVec, stInfoFile] = getObjectiveDataBilert(obj, szFeature);

% extract PSD data
version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);

% set minimum time length in blocks
nMinLen = 960;

% if no feature files are stored, extracted PSD from audio signals
if isempty(DataPSD) || size(Cxy, 1) <= nMinLen
    
    if size(Cxy, 1) <= nMinLen
        DataPSD = [];
    end
    
    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);
    
    % re-assign values
    Pxx = stData.Pxx';
    Pyy = stData.Pyy';
    Cxy = stData.Cxy';
    mRMS = stData.mRMS;
    nFFT = stData.nFFT;
    samplerate = stData.fs;
    
    % number of time frames
    nBlocks = size(Pxx, 1);
    
    % adjust time vector
    TimeVec = linspace(stData.TimeVec(1), stData.TimeVec(end), nBlocks);
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;
    
else
    
    % sampling frequency in Hz
    samplerate = stInfoFile.fs;
    
    % number of fast Fourier transform points
    nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
    
    % number of time frames
    nBlocks = size(Pxx, 1);
    
    % duration one frame in sec
    nLenFrame = 60/stInfoFile.nFrames;
    
    % desired feature PSD
    szFeature = 'RMS';

    % set compression on
    obj.isCompression = true;

    % get all available feature file data
    mRMS = getObjectiveDataBilert(obj, szFeature);
end

% size of frequency bins
specsize = nFFT/2 + 1;

isFreqLim = 0;
if isFreqLim
    % limit to 125 ... 8000 Hz for optical reasons
    stBandDef.StartFreq = 125;
    stBandDef.EndFreq = 8000;
    stBandDef.Mode = 'onethird';
    stBandDef.fs = samplerate;
    [stBandDef] = fftbin2freqband(nFFT/2+1,stBandDef);
    stBandDef.skipFrequencyNormalization = 1;
    [stBandDefCohe] = fftbin2freqband(nFFT/2+1,stBandDef);
    
    PxxShort = Pxx*stBandDefCohe.ReGroupMatrix;
    CoheShort = Cohe*stBandDefCohe.ReGroupMatrix;
    clear Cohe
end


% load subject and system specific calibration constants
szFile = 'I:\IdentificationSystems\IdentificationProbandSystem.mat';
load(szFile, 'stSubject_3', 'stSystem');

% subject - system
if isfield(obj, 'szCurrentFolder')
    idxSubj = strcmp({stSubject_3.ID}, obj.szCurrentFolder);
    szSystem = stSubject_3(idxSubj).System;
else
    % Outdoor by SB
    szSystem = 'SystemSB';
end

% system - calib constant
Calib_RMS = stSystem(strcmp({stSystem.System}, szSystem)).Calib;

% transfer to dB SPL
mRMS_dBSPL = 20*log10(mRMS(:,1)) + Calib_RMS(:,1);


%% VOICE DETECTION by Schreiber 2019
stDataOVD = OVD3(Cxy, Pxx, Pyy, samplerate, mRMS_dBSPL);


%% calculate RMS of Correlation with hannwin combs
[correlation] = CalcCorrelation(Pxx.*10^5, samplerate, specsize);


%% PITCH FEATURE
[stDataPitch] = OVD_Pitch(correlation, nFFT, stDataOVD.movAvgSNR);

%% estimate ovs by combining coherence and pitch
vOVS_JP = stDataOVD.meanCoheTimesCxy >= stDataOVD.adapThreshCohe & stDataPitch.vEstOVS;

% critical value for peak height, peaks heigher than this value corresponds
% to ovs
vOVS_JP(stDataPitch.vCritHeight) = 1;


%% get ground truth labels for voice activity
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

% look for hits, misses and false alarms
vOVS = double(stDataOVD.vOVS)';
vOVS_JP = double(vOVS_JP)';

vHitOVD = double(groundTrOVS == 1 & vOVS == 1);
vMissOVD = double(groundTrOVS == 1 & vOVS == 0);
vFalseAlarmOVD = double(groundTrOVS == 0 & vOVS == 1);

vHitOVD_JP = double(groundTrOVS == 1 & vOVS_JP == 1);
vMissOVD_JP = double(groundTrOVS == 1 & vOVS_JP == 0);
vFalseAlarmOVD_JP = double(groundTrOVS == 0 & vOVS_JP == 1);


% % % get recorded audio signal for plotting
% % [WavData, TimeVecWav, Fs] = getAudioSignal(obj);
% % nLen = length(WavData);
% % WavData = WavData(1:100:end,1);
% % TimeVecWav = linspace(0, nLen/samplerate, length(WavData));
% % Time = linspace(TimeVecWav(1),TimeVecWav(end), nBlocks);
% % figure;
% % plot(TimeVecWav, WavData);
% % hold on;
% % plot(Time, groundTrFVS, 'b');
% % plot(Time, groundTrOVS, 'r');


% for optical reasons replace 0 with NaN
vHitOVD(vHitOVD == 0) = NaN;
vMissOVD(vMissOVD  == 0) = NaN;
vFalseAlarmOVD(vFalseAlarmOVD  == 0) = NaN;
vHitOVD_JP(vHitOVD_JP == 0) = NaN;
vMissOVD_JP(vMissOVD_JP  == 0) = NaN;
vFalseAlarmOVD_JP(vFalseAlarmOVD_JP  == 0) = NaN;
groundTrFVS(groundTrFVS == 0) = NaN;


% get screen size of current device
vScreenSize = get(0,'ScreenSize');

%% plot objective Data
hFig = figure;
hFig.Position = vScreenSize;
nStartPos = 0.05;
nWidth = 0.95;
nHeight = 0.21;
mTextTitle = uicontrol(gcf,'style','text');
szTitle = [obj.szCurrentFolder ' ' obj.szNoiseConfig];
set(mTextTitle,'Units','normalized','Position', [0.2 0.95 0.6 0.05], 'String', szTitle,'FontSize',16);

%% Pxx
axPxx = axes('Position',[nStartPos 0.74 nWidth nHeight]);
if isFreqLim
    nFreqBins = size(PxxShort,2);
    freqVec = 1:nFreqBins;
    
    PxxLog = 10*log10(PxxShort)';
else
    freqVec = 0 : samplerate/nFFT : samplerate/2;
    
    PxxLog = 10*log10(Pxx)';
end
if ~isempty(DataPSD)
    TimeVec = datenum(TimeVec);
end
imagesc(TimeVec, freqVec, PxxLog);
axis xy;
colorbar;
title('');
if isFreqLim
    psdText=text(TimeVec(5),freqVec(end-10),'PSD (left)','Color',[1 1 1]);
    set(axPxx,'YTick',1:3:size(PxxShort,2));
    yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
    set(axPxx,'YTickLabel',yaxisLables);
else
    psdText=text(TimeVec(5),7500,'PSD (left)','Color',[1 1 1]);
    ylim([freqVec(1) 8000]);
end
psdText.FontSize = 12;
set(axPxx ,'ylabel', ylabel('frequency in Hz'))
% set(axPxx,'CLim',[-110 -55]);
drawnow;
PosVecPxx = get(axPxx,'Position');


%% mean real Coherence
axCohe = axes('Position',[nStartPos 0.52 PosVecPxx(3) nHeight]);
plot(TimeVec, stDataOVD.meanCoheTimesCxy, 'k');
hold on;
plot(TimeVec, stDataOVD.adapThreshCohe, 'r');
hFVS = plot(TimeVec, groundTrFVS, 'bx');
hHit = plot(TimeVec, vHitOVD, 'rx', 'LineWidth', 1.25);
hMiss = plot(TimeVec, vMissOVD, 'mx', 'LineWidth', 1.25);
hFA = plot(TimeVec, vFalseAlarmOVD, 'x', 'Color', [0.65 0.65 0.65]);
legend([hHit, hMiss, hFA, hFVS], 'OVS hit', 'OVS miss', 'OVS false alarm', 'FVS','Location','southeast','NumColumns',4);
set(axCohe ,'ylabel', ylabel('mean Re\{Coherence\}'));
xlim([TimeVec(1) TimeVec(end)]);
ylim([-0.2 1]);


%% RMS
axRMS = axes('Position',[nStartPos 0.3 PosVecPxx(3) nHeight]);
plot(TimeVec, mRMS_dBSPL, 'k');
hold on;
plot(TimeVec, stDataOVD.adapThreshRMS, 'r');
axRMS.YLabel = ylabel('RMS in dB SPL');
xlim([TimeVec(1) TimeVec(end)]);
ylim([20 110]);


%% RMS of Correlation with hannwin combs
useRMS = 1;
axCorr = axes('Position',[nStartPos 0.075 PosVecPxx(3) nHeight]);
if useRMS
    plot(TimeVec, stDataPitch.CorrRMS);
    hold on;
    plot(TimeVec, stDataPitch.adapThreshCorr, 'r');
    nScaling = max(stDataPitch.CorrRMS);
else
    plot(TimeVec, stDataPitch.PeaksCorr(:,1));
    hold on;
    plot(TimeVec, stDataPitch.adapThreshPeakHeight, 'r');
    nScaling = max(stDataPitch.PeaksCorr(:,1));
end
plot(TimeVec, stDataPitch.TrackMin, 'b:');
plot(TimeVec, stDataPitch.TrackMean, 'c:');
hHit = plot(TimeVec, nScaling*vHitOVD_JP, 'rx', 'LineWidth', 1.25);
hMiss = plot(TimeVec, nScaling*vMissOVD_JP, 'mx', 'LineWidth', 1.25);
hFA = plot(TimeVec, nScaling*vFalseAlarmOVD_JP, 'x', 'Color', [0.65 0.65 0.65]);
% legend([hHit, hMiss, hFA], 'OVS hit', 'OVS miss', 'OVS false alarm','NumColumns',3);
if ~isempty(DataPSD)
    datetickzoom(axCorr,'x','HH:MM:SS');
    set(axCorr, 'xlabel', xlabel('Time \rightarrow'));
else
    set(axCorr, 'xlabel', xlabel('Time in sec \rightarrow'));
end
axCorr.YLabel = ylabel('rms\{Correlation\}');
xlim([TimeVec(1) TimeVec(end)]);

set(axPxx,'XTickLabel',[]);
set(axCohe,'XTickLabel',[]);
set(axRMS,'XTickLabel','');

set(gcf,'PaperPositionMode', 'auto');

linkaxes([axRMS, axCorr, axPxx, axCohe], 'x');
% dynamicDateTicks([axRMS,axCorrRMS,axPxx,axCohe],'linked');


%% plot confusion matrix
vLabels = {'OVS', 'no OVS'};
plotConfusionMatrix([], vLabels, groundTrOVS, vOVS);
plotConfusionMatrix([], vLabels, groundTrOVS, vOVS_JP);

% logical to save figure
bPrint = 0;
if bPrint
    if isfield(obj, 'szCurrentFolder')
        szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
    else
        szDir = obj.szBaseDir;
    end
    sDataFolder_Output = [szDir filesep 'Overviews'];
    if ~exist(sDataFolder_Output, 'dir')
        mkdir(sDataFolder_Output);
    end
    
    set(0,'DefaultFigureColor','remove');
    
    
    if isfield(obj, 'szCurrentFolder')
        exportName = [sDataFolder_Output filesep ...
            'Fingerprint_PSD_Cohe_CorrRMS_' obj.szCurrentFolder '_' obj.szNoiseConfig];
    else
        exportName = [sDataFolder_Output filesep ...
            'Fingerprint_PSD_Cohe_CorrRMS_' obj.szNoiseConfig];
    end
    
    savefig(hFig, exportName);
end

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