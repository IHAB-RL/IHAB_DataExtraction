% script for testing purpose
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 22-Oct-2019  Initials JP

clear;
% close all;

% choose testsignal; OLSA sentence or real measured speech
useOLSA = 0;

if ~useOLSA
    % path to main data folder (needs to be customized)
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

    % get all subject directories
    subjectDirectories = dir(obj.szBaseDir);

    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(18).name;

    % number of noise configuration
    obj.szNoiseConfig = 'config3';

    % build the full directory
    obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

    % select audio file
    audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
    
    % choose bewtween male, female, background sequence
    ActSituation = 'all';
    switch ActSituation
        case 'male'
            tStart = 242.1;
            tEnd = 244.5;
        
        case 'female'
            tStart = 254.4;
            tEnd = 255.7;
        
        case 'quiet'
            tStart = 252.4;
            tEnd = 253;
            
        case 'noise'
            switch obj.szNoiseConfig
                case 'config2'
                    tStart = 144;
                    tEnd = 145.7;
%                     tStart = 232.6 ;
%                     tEnd = 233.5;
                    
                case 'config3'
                    tStart = 296.5 ;
                    tEnd = 297.5;
            end
    end
else
    audiofile = 'olsa_male_full_3_0.wav';
    ActSituation = 'mOLSA';
    tStart = 5.95;
    tEnd = 8.3;
end


% read in signal
[signal, fs] = audioread(audiofile);
if ~strcmp(ActSituation, 'all')
    % one sentence
    signal = signal(round(tStart*fs):round(tEnd*fs));
else
    % take first 60 sec conversation
    signal = signal(1:round(60*fs));
end
signal = signal(:);
nLen   = length(signal); % length in samples
nDur   = nLen/fs; % length in sec 
timeVec = linspace(0, nDur, nLen);

blocksize = 2048;
Overlap   = blocksize/2;
tFrame    = 0.125; % in sec
lFrame    = floor(tFrame*fs); % in samples
hopsize   = lFrame - Overlap;
stepSizeFreq = 1/2;
basefrequencies = 80:stepSizeFreq:450;
freqVec = linspace(0, fs/2, floor(blocksize / 2) + 1);

% magnitude domain feature
[correlation, spectrum] = magnitude_correlation(signal, fs, blocksize, hopsize, basefrequencies);

nBlocks = size(correlation, 1);
timeVecPitch = linspace(0, nDur, nBlocks);

% plot results
hFig = figure;
if ~strcmp(ActSituation, 'all')
    hFig.Position(4) = 1.5*hFig.Position(4);
    hFig.Position(2) = 0.7*hFig.Position(2);
else
    hFig.Position =  get(0,'ScreenSize');
end
nStartPos = 0.1;
nWidth = 0.85;
nHeight = 0.27;

% Magnitude Feature
axCorr = axes('Position',[nStartPos 0.06 nWidth nHeight]);
imagesc(timeVecPitch, basefrequencies, correlation');
axis xy;
c = colorbar;
set(axCorr,'ylabel', ylabel('Fundamental Frequency in Hz'));
set(axCorr,'xlabel', xlabel('Time in sec'));
ylabel(c, 'Magnitude Feature F^M_t(f_0)');
xlim([timeVec(1) timeVec(end)]);
drawnow;
PosVecCorr = get(axCorr,'Position');

% time signal
axAudio = axes('Position',[nStartPos 0.72 PosVecCorr(3) nHeight]);
if ~strcmp(ActSituation, 'all')
    plot(timeVec, signal);
else
    subsample = 10;
    signal =  signal(1:subsample:end);
    timeVec = timeVec(1:subsample:end);
    nLen   = length(signal); % length in samples
    plot(timeVec, signal);
    hold on;
    % get and plot labels
    obj.fsVD = 1/tFrame;
    obj.NrOfBlocks = round(nDur/tFrame);
    [groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
    
    timeVec = linspace(timeVec(1), timeVec(end), obj.NrOfBlocks);
    plot(timeVec, groundTrOVS, 'r');
    plot(timeVec, groundTrFVS, 'b');
    legend('time signal', 'OVS', 'FVS');
end
set(axAudio,'ylabel', ylabel('Amplitude'));
set(axAudio,'xlabel', xlabel('Time in sec'));
xlim([timeVec(1) timeVec(end)]);

% Short-time Fourier Transform of the signal
axPxx = axes('Position',[nStartPos 0.39 nWidth nHeight]);
imagesc(timeVecPitch, freqVec, 10*log10(abs(spectrum))');
axis xy;
c = colorbar;
set(axPxx,'ylabel', ylabel('Frequency in Hz'));
set(axPxx,'xlabel', xlabel('Time in sec'));
ylabel(c, 'STFT Magnitude in dB');
xlim([timeVec(1) timeVec(end)]);
ylim([freqVec(1) 5000]);

linkaxes([axCorr, axAudio, axPxx],'x');

% save figure
obj.szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch';
exportName = [obj.szDir filesep ...
        'OverviewPitch_' ActSituation '_'  obj.szCurrentFolder '_' obj.szNoiseConfig];
savefig(hFig, exportName);