% script for testing purpose
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 22-Oct-2019  Initials JP

clear;
close all;

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
    obj.szNoiseConfig = 'config1';

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
    nSec = 60;
    signal = signal(1:round(nSec*fs));
end
signal  = signal(:);
nLen    = length(signal); % length in samples
nDur    = nLen/fs; % length in sec 
timeVec = linspace(0, nDur, nLen);

blocksize = 2048;
Overlap   = blocksize/2;
freqVec   = linspace(0, fs/2, floor(blocksize / 2) + 1);
tFrame    = 0.125; % in sec
lFrame    = floor(tFrame*fs); % in samples
hopsize   = blocksize - Overlap;
nBlocks   = ceil((nLen-blocksize) / hopsize);
timeVecPitch = linspace(0, nDur, nBlocks);

% define base frequencies
stepSizeFreq = 1/2;
basefrequencies = 80:stepSizeFreq:450;

% magnitude domain feature - Bastian Bechtold
[correlation, spectrum] = magnitude_correlation(signal, fs, blocksize, hopsize, basefrequencies);


% plot results
hFig1 = figure;
if ~strcmp(ActSituation, 'all')
    hFig1.Position(4) = 1.5*hFig1.Position(4);
    hFig1.Position(2) = 0.7*hFig1.Position(2);
else
    hFig1.Position =  get(0,'ScreenSize');
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



% calculate and plot distribution of Magnitude Feature
% get labels for new blocksize
obj.fsVD = nBlocks/nDur;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

idxTrOVS = groundTrOVS == 1;
idxTrFVS = groundTrFVS == 1;
idxTrNone = ~idxTrOVS & ~idxTrFVS;

% % check labels
% figure;
% imagesc(1:nBlocks, basefrequencies, correlation');
% axis xy;
% colorbar;
% hold on;
% plot(200*groundTrOVS, 'r');
% plot(300*groundTrFVS, 'b');
% plot(400*idxTrNone, 'g');

% calculate mean on correlation for OVS | FVS | no VS
MeanCorrOVS = mean(correlation(idxTrOVS,:));
MeanCorrFVS = mean(correlation(idxTrFVS,:));
MeanCorrNone = mean(correlation(idxTrNone,:));

hFig2 = figure;
hFig2.Position = hFig1.Position;
subplot(3,1,1);
bar(basefrequencies, MeanCorrOVS, 'FaceColor', 'r');
title('Mean Magnitude Feature F^M_t(f_0) at OVS');
xlabel('Fundamental Frequency in Hz');
ylabel('Mean Magnitude Feature F^M_t(f_0)');

subplot(3,1,2);
bar(basefrequencies, MeanCorrFVS, 'FaceColor', 'b');
title('Mean Magnitude Feature F^M_t(f_0) at FVS');
xlabel('Fundamental Frequency in Hz');
ylabel('Mean Magnitude Feature F^M_t(f_0)');

subplot(3,1,3);
bar(basefrequencies, MeanCorrNone, 'FaceColor', [0 0.6 0.2]);
title('Mean Magnitude Feature F^M_t(f_0) at no VS');
xlabel('Fundamental Frequency in Hz');
ylabel('Mean Magnitude Feature F^M_t(f_0)');


% calculate maximum on correlation for OVS | FVS | no VS
MaxCorrOVS = max(correlation(idxTrOVS,:));
MaxCorrFVS = max(correlation(idxTrFVS,:));
MaxCorrNone = max(correlation(idxTrNone,:));

hFig4 = figure;
hFig4.Position = hFig1.Position;
subplot(3,1,1);
bar(basefrequencies, MaxCorrOVS, 'FaceColor', 'r');
title('Max Magnitude Feature F^M_t(f_0) at OVS');
xlabel('Fundamental Frequency in Hz');
ylabel('max(Magnitude Feature F^M_t(f_0))');

subplot(3,1,2);
bar(basefrequencies, MaxCorrFVS, 'FaceColor', 'b');
title('Max Magnitude Feature F^M_t(f_0) at FVS');
xlabel('Fundamental Frequency in Hz');
ylabel('max(Magnitude Feature F^M_t(f_0))');

subplot(3,1,3);
bar(basefrequencies, MaxCorrNone, 'FaceColor', [0 0.6 0.2]);
title('Max Magnitude Feature F^M_t(f_0) at no VS');
xlabel('Fundamental Frequency in Hz');
ylabel('max(Magnitude Feature F^M_t(f_0))');


% calculate p% percentile on correlation for OVS | FVS | no VS
p = 80;
PrcCorrOVS = prctile(correlation(idxTrOVS,:), p);
PrcCorrFVS = prctile(correlation(idxTrFVS,:), p);
PrcCorrNone = prctile(correlation(idxTrNone,:), p);

hFig3 = figure;
hFig3.Position = hFig1.Position;
subplot(3,1,1);
bar(basefrequencies, PrcCorrOVS, 'FaceColor', 'r');
title([num2str(p) '% percentile Magnitude Feature F^M_t(f_0) at OVS']);
xlabel('Fundamental Frequency in Hz');
ylabel([num2str(p) '% percentile Magnitude Feature F^M_t(f_0)']);

subplot(3,1,2);
bar(basefrequencies, PrcCorrFVS, 'FaceColor', 'b');
title([num2str(p) '% percentile Magnitude Feature F^M_t(f_0) at FVS']);
xlabel('Fundamental Frequency in Hz');
ylabel([num2str(p) '% percentile Magnitude Feature F^M_t(f_0)']);

subplot(3,1,3);
bar(basefrequencies, PrcCorrNone, 'FaceColor', [0 0.6 0.2]);
title([num2str(p) '% percentile Magnitude Feature F^M_t(f_0) at no VS']);
xlabel('Fundamental Frequency in Hz');
ylabel([num2str(p) '% percentile Magnitude Feature F^M_t(f_0)']);



% save figures
obj.szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch\figures';
szFolder_Output = [obj.szDir filesep obj.szCurrentFolder];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

if strcmp(ActSituation, 'all')
    exportName1 = [szFolder_Output filesep ...
        'OverviewPitch_' ActSituation num2str(nSec) 's_'  obj.szCurrentFolder '_' obj.szNoiseConfig];
else
    exportName1 = [szFolder_Output filesep ...
        'OverviewPitch_' ActSituation '_'  obj.szCurrentFolder '_' obj.szNoiseConfig];
end
savefig(hFig1, exportName1);

exportName2 = [szFolder_Output filesep ...
    'MeanCorr_' obj.szCurrentFolder '_' obj.szNoiseConfig];
savefig(hFig2, exportName2);

exportName3 = [szFolder_Output filesep ...
    'Prc' num2str(p) '_' obj.szCurrentFolder '_' obj.szNoiseConfig];
savefig(hFig3, exportName3);

exportName4 = [szFolder_Output filesep ...
    'MaxCorr_' num2str(p) '_' obj.szCurrentFolder '_' obj.szNoiseConfig];
savefig(hFig4, exportName4);


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