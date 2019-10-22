% script for testing purpose
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 22-Oct-2019  Initials JP

clear;
close all;

audiofile = 'olsa_male_full_3_0.wav';
[signal, fs] = audioread(audiofile);

signal = signal(round(5.95*fs):round(8.3*fs));
nLen   = size(signal, 1);
nDur   = nLen/fs;
timeVec = linspace(0, nDur, nLen);

blocksize = 2048;
Overlap   = blocksize/2;
tFrame    = 0.025; % in sec
lFrame    = floor(tFrame*fs); % in samples
hopsize   = lFrame - Overlap;
basefrequencies = 80:0.5:450;
freqVec = linspace(0, fs/2, floor(blocksize / 2) + 1);

% magnitude domain feature
[correlation, spectrum] = magnitude_correlation(signal, fs, blocksize, hopsize, basefrequencies);

nBlocks = size(correlation, 1);
timeVecPitch = linspace(0, nDur, nBlocks);

% plot results
hFig = figure;
hFig.Position(4) = 1.5*hFig.Position(4);
hFig.Position(2) = 0.7*hFig.Position(2);
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
plot(timeVec, signal);
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