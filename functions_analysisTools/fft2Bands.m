function [FreqTMatrix, MidFreqs, BandEdges] = fft2Bands(FFTSize,fs_Hz,resolution_halftones,MinMaxFreqs_Hz)
% function to build a matrix that sums up fft bins to bands given in
% halftones (3 = third octave, 12 = octave)
% The given matrix can be used in conjuction with your spectrum (positive half)
% USAGE: [FreqTMatrix, MidFreqs, BandEdges] = fft2Bands(FFTSize,fs,resolution_halftones,MinMaxFreqs)
%
% input paramter
% FFTSize:      The original fftsize (typical poer of two)
% fs:           the sampling frequency to determine which is the highest
%               freq in the spectrum
% resolution_halftones: the desired resolution of the bands, typical value
%                       would be 3 or 8 for third octave or octave
%                       resolution (3 = default)
% MinMaxFreq_Hz: a vector containing 2 frequencies the lowest and the
% highest that should be considered (default is 16 and 16000)
% 
% output parameters:
% FreqTMatrix:    a FFTSize/2+1  x NrOfBands matrix
% MidFreqs:       the mid frequencies of the bands
% BandEdges:      the band edge frequencies
%

% Version 1.0 Author: Joerg Bitzer @ TGM @ Jade Hochschule, Oldenburg
% this file is under the Apache license (more info EOF)
%     http://www.apache.org/licenses/LICENSE-2.0

if nargin < 4
   MinMaxFreqs_Hz = [16 16000];
end

if nargin < 3
    resolution_halftones = 3;
end

fr = 1000;

LowestFreqIdx = log2(MinMaxFreqs_Hz(1)/fr)*12; % index in halftone
HighestFreqIdx = log2(MinMaxFreqs_Hz(2)/fr)*12; % index in halfone

StartIdx = round(LowestFreqIdx/resolution_halftones)-1;
EndIdx = round(HighestFreqIdx/resolution_halftones)+1;


% Build FFT->Bandtransformation matrices
Bandidx = StartIdx:EndIdx; % one lower and one upper to get the right bandedges
MidFreqs = fr.*2.^(Bandidx*resolution_halftones/12);
BandEdges = sqrt(MidFreqs(1:end-1).*MidFreqs(2:end));
if BandEdges(end)>fs_Hz/2
    BandEdges(end) = fs_Hz/2;
end
% remove outer bands fm
MidFreqs(1) = [];
MidFreqs(end) = [];

FreqTMatrix = zeros(FFTSize/2+1,length(MidFreqs));

for kk = 1:length(MidFreqs)
    IdxLow = round(BandEdges(kk)/fs_Hz*FFTSize);
    IdxHigh = round(BandEdges(kk+1)/fs_Hz*FFTSize);
    FreqTMatrix(IdxLow:IdxHigh,kk) = 1;
end

% 
% Copyright [2018] [Joerg Bitzer @ Jade Hochschule]
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.