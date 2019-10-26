% script for testing purpose
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 16-Oct-2019  Initials JP

% path to main data folder (needs to be customized)
szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% choose one subject directoy
szCurrentFolder = subjectDirectories(18).name;

% number of noise configuration
szNoiseConfig = '1';

% build the full directory
szDir = [szBaseDir filesep szCurrentFolder filesep 'config' szNoiseConfig];

% set parameters
stParam.fs          = 24000;
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

% read in audio signal
audiofile = fullfile(szDir, [szCurrentFolder '_config' szNoiseConfig '.wav']);
audiofile = 'olsa_male_full_3_0.wav';
[audioIn, fs] = audioread(audiofile);
audioIn = audioIn(round(5.9*fs):round(8.3*fs));
stParam.mSignal = resample(audioIn, stParam.fs, fs);
nSamples = size(stParam.mSignal, 1);
nLen = nSamples/stParam.fs;
timeVec = linspace(0, nLen, nSamples);
freqVec = 0:stParam.fs/stParam.nFFT:stParam.fs/2;

% estimate pitch via PEF Matlab
[f0, idx] = pitch(stParam.mSignal, stParam.fs, ...
    'Method', 'PEF', ...
    'Range', [50 800], ...
    'WindowLength', round(stParam.fs*0.08), ...
    'OverlapLength', round(stParam.fs*0.05));

% estimate pitch via S.Gonzalez and M. Brookes
[fx,tx,pv,fv] = v_fxpefac(stParam.mSignal, stParam.fs,0.01,'G');

% [stData] = detectOVSRealCoherence(stParam);
lFeed       = stParam.lFrame - stParam.lOverlap;
nFrames     = floor((nSamples-stParam.lOverlap)/(lFeed));
Pxx = zeros(stParam.nFFT/2+1, nFrames);
mRMS = zeros(nFrames,1);

% smoothing factor PSD
alphaPSD    = exp(-stParam.tFrame./stParam.tauCoh);

win         = repmat((hanning(stParam.lFrame,'periodic')),1,size(stParam.mSignal,2));
%Add by Nils
winNorm = stParam.lFrame*sum(win.^2)./stParam.nFFT;

tmpX        = 0;

for iFrame = 1:nFrames
    
    vIDX    = ((iFrame-1)*lFeed+1):((iFrame-1)*lFeed+stParam.lFrame);
    
    mSpec   = fft(stParam.mSignal(vIDX,:).*win,stParam.nFFT,1);
    mSpec   = mSpec(1:stParam.nFFT/2+1,:)./winNorm;
    
    curX    = mSpec.*conj(mSpec);
    tmpX    = alphaPSD*tmpX+(1-alphaPSD)*curX;

    Pxx(:,iFrame) = tmpX(:,1);
    mRMS(iFrame) = rms(stParam.mSignal(vIDX,:));
    
end 

PxxLog = 10*log10(Pxx);

% plot results
figure;
subplot(3,1,1);
plot(timeVec, stParam.mSignal);
ylabel('Amplitude');
xlabel('Time in sec');
xlim([timeVec(1) timeVec(end)]);

timeVecPSD = linspace(timeVec(1), timeVec(end), nFrames);
subplot(3,1,2);
spectrogram(stParam.mSignal,stParam.lFrame,stParam.lOverlap,stParam.nFFT,stParam.fs,'yaxis');
% imagesc(timeVecPSD, freqVec, PxxLog);
% axis xy;
% colorbar;
xlabel('Time in sec');
ylabel('Frequency in Hz');
xlim([timeVec(1) timeVec(end)]);

subplot(3,1,3);
plot(idx/stParam.fs, f0);
ylabel('Pitch in Hz');
xlabel('Time in sec');
xlim([timeVec(1) timeVec(end)]);

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