function [stParam]=setParamsFeatureExtraction(obj)
% function to set the constant parameters for feature extraction
% can be called by detectOVSRealCoherence.m
% Usage [stParam]=setParamsFeatureExtraction(obj)
%
% Parameters
% ----------
% obj - struct with specific informations about the current subject, data
%        folder etc.
%
% Returns
% -------
% stParam - struct with constant parameters for feature extraction and the
%           audio signal
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 12-Nov-2019  JP

% read in audiosignal
[mSignal, Fs]      = audioread(obj.audiofile);

% downsampling by factor 2
stParam.fs         = Fs/2;
stParam.mSignal    = resample(mSignal, stParam.fs, Fs);

 % calculate time vector
stParam.nSigLen    = size(stParam.mSignal,1); % length in samples
stParam.nSigDur    = stParam.nSigLen/stParam.fs; % duration in sec
stParam.TimeVec    = linspace(0, stParam.nSigDur, stParam.nSigLen);

% set parameters for processing audio data
% privacy option, just every 10th PSD frame is saved
stParam.privacy    = true;

% block length in sec
stParam.tFrame     = 0.025; 

% block length in samples
stParam.lFrame     = floor(stParam.tFrame*stParam.fs); 

% overlap of adjacent blocks in samples
stParam.lOverlap   = stParam.lFrame/2; 

% optimal frequency resolution of one frequency bin, e.g. for fs = 24 kHz
% and nFFT = 1024
stParam.nFreqRes   = 23.4375; 

% number of fast Fourier transform points, dependent on samplingrate and
% frequency resolution
nFFT               = stParam.fs/stParam.nFreqRes;
stParam.nFFT       = 2^nextpow2(nFFT); 
if nFFT-stParam.nFFT ~= 0 
    stParam.nFFT       = 2^(nextpow2(nFFT)-1); 
end

% normalized window length for PSD calculation
stParam.winLen     = floor(stParam.nFFT/10); 

% frequency range of interest in Hz
stParam.vFreqRange = [400 1000]; 

% frequency range in bins
stParam.vFreqBins  = round(stParam.vFreqRange./stParam.fs*stParam.nFFT);

% parameters for smoothing
stParam.tFrame     = 0.125; % Nils
stParam.tauCoh     = 0.1; % Nils

% constant threshold for the mean real coherence (Bitzer et al. 2016)
stParam.fixThresh  = 0.6; 

% window length for calculating the adaptive threshold (Bilert 2018)
stParam.adapThreshWin = 0.05*stParam.fs; 


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