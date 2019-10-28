% Script to compare the feature values with the calculated values based on
% the audio signal
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 26-Oct-2019  JP

clear;

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
nConfig = 2;

% choose noise configurations
obj.szNoiseConfig = ['config' num2str(nConfig)];
    
% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];


% desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,TimeVecPSD,stInfoFile] = getObjectiveDataBilert(obj, szFeature);

% get CPSD and the 2 APSD
version = 1; % JP modified get_psd
[Cxy, Pxx, Pyy] = get_psd(DataPSD, version);

nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);


% read in audio signal 
audiofile = fullfile(szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
[mSignal, fs] = audioread(audiofile);
stParam.mSignal = resample(mSignal, stInfoFile.fs, fs);

% calculate time vector
nLen    = size(stParam.mSignal,1); % length in samples
nDur    = nLen/stInfoFile.fs; % duration in sec
timeVec = linspace(0, nDur, nBlocks);

% calculate frequency vector
freqVec = linspace(0, stInfoFile.fs/2, specsize);

% set parameters for processing audio data
stParam.fs          = stInfoFile.fs;
stParam.privacy     = true;
stParam.tFrame      = 0.025; % block length in sec
stParam.lFrame      = floor(stParam.tFrame*stParam.fs); % block length in samples
stParam.lOverlap    = stParam.lFrame/2; % overlap adjacent blocks
stParam.nFFT        = nFFT; % number of fast Fourier transform points
stParam.vFreqRange  = [400 1000]; % frequency range of interest in Hz
stParam.vFreqBins   = round(stParam.vFreqRange./stParam.fs*stParam.nFFT);
stParam.tFrame      = 0.125; % Nils
stParam.tauCoh      = 0.1; % Nils
stParam.fixThresh   = 0.6; % fixed coherence threshold
stParam.adapThreshWin  = 0.05*stParam.fs; % window length for the adaptive threshold
stParam.winLen      = floor(stParam.nFFT/10); % normalized window length (Nils)

[stData] = detectOVSRealCoherence(stParam);
% [stData] = computeSpectraAndCoherence(stParam);
PxxAudio = stData.Pxx(:, 1:nBlocks);


% plot results
figure;
subplot(3,1,1);
imagesc(timeVec, freqVec, 10*log10(Pxx'));
axis xy;
c = colorbar;
title('Feature');
xlabel('Time in sec');
ylabel('Frequency in Hz');
ylabel(c, 'PSD Magnitude in dB');

subplot(3,1,2);
imagesc(timeVec, freqVec, 10*log10(PxxAudio));
axis xy;
c = colorbar;
title('Audio');
xlabel('Time in sec');
ylabel('Frequency in Hz');
ylabel(c, 'PSD Magnitude in dB');

vDiff = 10*log10(PxxAudio)-10*log10(Pxx');
vDiff(vDiff == Inf) = []; % 'gap' between two 60sec audio files 
vDiff(isnan(vDiff)) = []; % 'gap' between two 60sec audio files 
mean(vDiff(:)) % 19.5688 dB

subplot(3,1,3);
imagesc(timeVec, freqVec, vDiff);
axis xy;
c = colorbar;
title('Difference: Audio-Feature');
xlabel('Time in sec');
ylabel('Frequency in Hz');
ylabel(c, 'Magnitude Difference in dB');

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