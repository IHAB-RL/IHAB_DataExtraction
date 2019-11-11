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


%% lets start with reading objective data
stParam.privacy = true;
if isfield(obj, 'UseAudio') % NS data

    % build the full directory
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
    
    % read in audio signal
    audiofile = fullfile(szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
    [WavData, Fs] = audioread(audiofile);
    
    % set parameters for processing audio data
    samplerate          = Fs/2;
    stParam.fs          = samplerate;
    stParam.mSignal     = resample(WavData, stParam.fs, Fs);
    
    % calculate time vector
    nLen                = size(stParam.mSignal,1); % length in samples
    nDur                = nLen/stParam.fs; % duration in sec
    TimeVecWav          = linspace(0, nDur, nLen);
    
    stParam.tFrame      = 0.025; % block length in sec 
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
    alpha               = exp(-stParam.tFrame/stParam.tauCoh);

    [stData] = detectOVSRealCoherence(stParam);
    Pxx = stData.Pxx';
    Pyy = stData.Pyy';
    Cxy = stData.Cxy';
    
    stInfoPSD.nFrames = 480;
    stInfoRMS.nFrames = 4799;
    TimeVec = linspace(TimeVecWav(1), TimeVecWav(end), size(Pxx,1));
    
else % with feature files
    
    % desired feature PSD
    szFeature = 'PSD';

    % get all available feature file data
    [DataPSD,TimeVec,stInfoPSD] = getObjectiveDataBilert(obj, szFeature);

    if isempty(DataPSD)
        return;
    end

    version = 1; % JP modified get_psd
    [Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
    clear DataPSD;
    
    samplerate = stInfoPSD.fs;
    
% %     % get recorded audio signal for plotting
% %     [WavData, TimeVecWav, Fs] = getAudioSignal(obj);
end

isFreqLim = 0;
if isFreqLim
    % limit to 125 ... 8000 Hz for optical reasons
    stBandDef.StartFreq = 125;
    stBandDef.EndFreq = 8000;
    stBandDef.Mode = 'onethird';
    stBandDef.fs = samplerate;
    [stBandDef] = fftbin2freqband(stParam.nFFT/2+1,stBandDef);
    stBandDef.skipFrequencyNormalization = 1;
    [stBandDefCohe] = fftbin2freqband(stParam.nFFT/2+1,stBandDef);
    
    PxxShort = Pxx*stBandDefCohe.ReGroupMatrix;
    CoheShort = Cohe*stBandDefCohe.ReGroupMatrix;
    clear Cohe MeanCohe;
end

nFFT = (stInfoPSD.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);

%% VOICE DETECTION by Schreiber 2019
stDataOVD = OVD3(Cxy, Pxx, Pyy, samplerate);


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
obj.fsVD = ceil(stInfoPSD.nFrames / 60);
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
if ~isfield(obj, 'UseAudio') 
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
set(axPxx,'CLim',[-110 -55]);
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


%% RMS
axRMS = axes('Position',[nStartPos 0.3 PosVecPxx(3) nHeight]);
plot(TimeVec, stDataOVD.curRMSfromPxx, 'k');
hold on;
plot(TimeVec, stDataOVD.adapThreshRMS, 'r');
axRMS.YLabel = ylabel('RMS');
xlim([TimeVec(1) TimeVec(end)]);


%% RMS of Correlation with hannwin combs
axCorr = axes('Position',[nStartPos 0.075 PosVecPxx(3) nHeight]);
% plot(TimeVec, stDataPitch.CorrRMS);
plot(TimeVec, stDataPitch.PeaksCorr(:,1));
hold on;
% plot(TimeVec, stDataPitch.adapThreshCorr, 'r');
plot(TimeVec, stDataPitch.adapThreshPeakHeight, 'r');
plot(TimeVec, stDataPitch.TrackMin, 'b:');
plot(TimeVec, stDataPitch.TrackMean, 'c:');
% nScaling = max(stDataPitch.CorrRMS);
nScaling = max(stDataPitch.PeaksCorr(:,1));
hHit = plot(TimeVec, nScaling*vHitOVD_JP, 'rx', 'LineWidth', 1.25);
hMiss = plot(TimeVec, nScaling*vMissOVD_JP, 'mx', 'LineWidth', 1.25);
hFA = plot(TimeVec, nScaling*vFalseAlarmOVD_JP, 'x', 'Color', [0.65 0.65 0.65]);
% legend([hHit, hMiss, hFA], 'OVS hit', 'OVS miss', 'OVS false alarm','NumColumns',3);
if ~isfield(obj, 'UseAudio') 
    datetickzoom(axCorr,'x','HH:MM:SS');
end
axCorr.YLabel = ylabel('rms\{Correlation\}');
xlim([TimeVec(1) TimeVec(end)]);
set(axCorr ,'xlabel', xlabel('Time \rightarrow'));

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
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
    sDataFolder_Output = [szDir filesep 'Overviews'];
    if ~exist(sDataFolder_Output, 'dir')
        mkdir(sDataFolder_Output);
    end
    
    set(0,'DefaultFigureColor','remove');
    
    exportName = [szDir filesep 'Overviews' filesep ...
        'Fingerprint_PSD_Cohe_CorrRMS_' obj.szCurrentFolder '_' obj.szNoiseConfig];
    
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