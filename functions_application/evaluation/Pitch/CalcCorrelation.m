function [correlation, correlationPSD, synthetic_PSD] = CalcCorrelation(spectrum, samplerate, specsize)
% function to calculate the correlation between a complex spectrum and a
% series of synthetic magnitude spectra
% Usage: [correlation] = CalcCorrelation(spectrum, samplerate, specsize)
%
% Parameters
% ----------
% spectrum    - The Short-time Fourier Transform of a signal, 
%               format blocks x specsize. 
%
% samplerate  - The sampling rate of the signal.
%
% specsize    - The length of each spectrum.
%
% Returns
% -------
% correlation - An len(blocks) x len(basefrequencies) matrix of correlation 
%               values.
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Source: magnitude_correlation.m - Bastian Bechtold
% Version History:
% Ver. 0.01 initial create 23-Oct-2019  Initials JP

if ~exist('synthetic_magnitudes', 'var') 
    szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch';
    basefrequencies = 80:0.5:450;
    [synthetic_magnitudes] = CalcSyntheticMagnitude(szDir, samplerate, specsize, basefrequencies);
end

% weight differences according to perception:
f = linspace(0, samplerate/2, specsize);
log_f_weight =  1 ./ (samplerate/2).^(f / (samplerate/2));

% number of blocks
nBlocks = size(spectrum, 1);

% % calculate power spetral density
% synthetic_PSD = synthetic_magnitudes.*conj(synthetic_magnitudes);

freqs = linspace(0, samplerate/2, specsize);
% figure;
% plot(freqs, synthetic_magnitudes(101,:));
% hold on;
% plot(freqs, synthetic_PSD(101,:));

% pre allocation
correlation = zeros(nBlocks, size(synthetic_magnitudes, 1));
correlationPSD = zeros(nBlocks, size(synthetic_magnitudes, 1));

for iBlock = 1:nBlocks
    correlation(iBlock, :) = sum(abs(spectrum(iBlock, :)) .* synthetic_magnitudes .* log_f_weight, 2)';
%     correlationPSD(iBlock, :) = sum(abs(spectrum(iBlock, :)) .* synthetic_PSD .* log_f_weight, 2)';
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