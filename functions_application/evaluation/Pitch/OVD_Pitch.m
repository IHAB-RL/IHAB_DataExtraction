function [stData]=OVD_Pitch(correlation, nFFT)
% function to estimate own voice sequences (OVS) based on "Pitch"
% work in progress
% Usage [stData]=OVD_Pitch(correlation, nFFT)
%
% Parameters
% ----------
% inParam :  
%   peaks - matrix, contains for each time frame the height of maximal 3 
%           detected peaks in the correlation of PSD and synthetic spectra
%
% Returns
% -------
% outParam :  
%   estimatedOVS - logical array, 1 = OVS
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 05-Nov-2019  JP
% Ver. 0.02 adaptive threshold rms(correlation) 08-Nov-2019  JP

% define window length for tracking minima and maxima
stData.winLen = floor(nFFT/10);

% define minimum value
MIN_CORR = 5;

% calculate the "RMS" of the correlation
stData.CorrRMS = sqrt(sum(correlation.^2, 2));

% Sliding max and min
stData.TrackMax = movmax(stData.CorrRMS, stData.winLen);
stData.TrackMin = movmin(stData.CorrRMS, stData.winLen);

% Adaptive thresholds
stData.adapThreshCorr = (stData.TrackMax + stData.TrackMin)/2;
stData.adapThreshCorr = max(stData.adapThreshCorr, MIN_CORR);

% check threshold
stData.vOVS = stData.CorrRMS >= stData.adapThreshCorr; 

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