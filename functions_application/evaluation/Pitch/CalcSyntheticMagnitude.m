function [synthetic_magnitudes] = CalcSyntheticMagnitude(szDir, samplerate, specsize, basefrequencies)
% function to store synthetic magnitude spectra
% Usage: [synthetic_magnitudes] = CalcSyntheticMagnitude(szDir, samplerate, specsize, basefrequencies)
%
% Parameters
% ----------
% szDir           - The name of the folder, where the output data is stored. 
%
% samplerate      - The sampling rate of the tone complexes.
%
% specsize        - The length of each spectrum.
%
% basefrequencies - An ordered vector of tone complex base frequencies in Hz.
%
% Returns
% -------
% synthetic_magnitudes - An len(basefrequencies) x specsize matrix of tone 
%                        complex spectra.
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Source: magnitude_correlation.m - Bastian Bechtold
% Version History:
% Ver. 0.01 initial create 23-Oct-2019  Initials JP

if nargin <= 1 
    samplerate = 24000; 
    nfft       = 1024;
    specsize   = nfft/2 + 1;  
    basefrequencies = 80:0.5:450;
end

[synthetic_magnitudes] = synthetic_magnitude(samplerate, specsize, basefrequencies);

save([szDir filesep 'SyntheticMagnitudes'],'synthetic_magnitudes');

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