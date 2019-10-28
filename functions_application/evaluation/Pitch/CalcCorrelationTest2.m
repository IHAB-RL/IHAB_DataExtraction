% Script belonging to CalcCorrelation.m
% calculation of PSD is based on audio
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 24-Oct-2019  JP

clear;
% close all;


% path to main data folder (needs to be customized)
obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% number of subjects
nSubject = size(subjectDirectories, 1);

% choose one subject directoy
obj.szCurrentFolder = subjectDirectories(nSubject).name;

% number of noise configuration
nConfig = 1;

% choose noise configurations
obj.szNoiseConfig = ['config' num2str(nConfig)];


% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

% read in audio signal
audiofile = fullfile(szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
[WavData, Fs] = audioread(audiofile);

% set parameters for processing audio data
stParam.fs          = Fs/2;
stParam.mSignal     = resample(WavData, stParam.fs, Fs);

stParam.privacy     = true;
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

[stData] = detectOVSRealCoherence(stParam);
Pxx = stData.Pxx';

specsize = stParam.nFFT/2 + 1;
nBlocks = size(Pxx, 1);

matfile = 'SyntheticMagnitudes.mat';
szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch';
load([szDir filesep matfile]);

% % norm spectrum to maximum value
% MaxValuesPxx = max(Pxx'); % block based
% PxxNorm = Pxx./MaxValuesPxx(:);


% calculate correlation
[correlation, correlationPSD, synthetic_PSD] = CalcCorrelation(Pxx, stParam.fs, specsize);

% calculate time vector
nLen    = size(stParam.mSignal,1); % length in samples
nDur    = nLen/stParam.fs; % duration in sec
timeVec = linspace(0, nDur, nBlocks);

% plot results
figure;
subplot(2,1,1);
imagesc(timeVec, basefrequencies, correlation');
axis xy;
c = colorbar;
title('feat PSD x syn Spec');
ylabel('Fundamental Frequency in Hz');
xlabel('Time in sec');
ylabel(c, 'Magnitude Feature F^M_t(f_0)');
xlim([timeVec(1) timeVec(end)]);

subplot(2,1,2);
imagesc(timeVec, basefrequencies, correlationPSD');
axis xy;
c = colorbar;
title('feat PSD x syn PSD');
ylabel('Fundamental Frequency in Hz');
xlabel('Time in sec');
ylabel(c, 'Magnitude Feature F^M_t(f_0)');
xlim([timeVec(1) timeVec(end)]);


freqs = linspace(0, stParam.fs/2, specsize);

FundFreq = [130 200];
idxFundFreq(1) = find(basefrequencies >= FundFreq(1), 1);
idxFundFreq(2) = find(basefrequencies >= FundFreq(2), 1);


blockidx = find(timeVec >= 18.88, 1);
Pxx_abs =  abs(Pxx(blockidx,:)./max(Pxx(blockidx,:)))';
figure;
plot(freqs, Pxx(blockidx,:), 'k');
hold on;
plot(freqs, synthetic_magnitudes(idxFundFreq(1),:), 'r');
plot(freqs, synthetic_magnitudes(idxFundFreq(2),:), 'g');
plot(freqs, synthetic_PSD(idxFundFreq(1),:), 'b');
plot(freqs, synthetic_PSD(idxFundFreq(2),:), 'c');
legend('Pxx', 'T^M(f, 130)', 'T^M(f, 200)', 'PSD(T^M(f, 130))', 'PSD(T^M(f, 200))');
xlim([0 4000]);
xlabel('Frequency in Hz');
ylabel('STFT Magnitude');

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