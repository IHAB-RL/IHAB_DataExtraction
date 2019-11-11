function [stData]=OVD_Pitch(correlation, nFFT, movAvgSNR)
% function to estimate own voice sequences (OVS) based on "Pitch"
% work in progress
% Usage [stData]=OVD_Pitch(correlation, nFFT)
%
% Parameters
% ----------
% inParam :  
%   correlation
%   nFFT
%   movAvgSNR
%
% Returns
% -------
% outParam :  
%   stData
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 05-Nov-2019  JP
% Ver. 0.02 adaptive threshold rms(correlation) 08-Nov-2019  JP
% Ver. 0.03 add SNR dependency 09-Nov-2019  JP

% define window length for tracking minima and maxima
stData.winLen = floor(nFFT/25);

% number of blocks
nBlocks = size(correlation,1);

% define minimum threshold dependent on averaged SNR
MIN_CORR = ones(nBlocks, 1);
MIN_CORR(movAvgSNR <= 30) = 10;

% calculate the "RMS" of the correlation
stData.CorrRMS = sqrt(sum(correlation.^2, 2));

% Sliding max, mean and min
stData.TrackMax = movmax(stData.CorrRMS, stData.winLen);
stData.TrackMean = movmean(stData.CorrRMS, 2*stData.winLen);
stData.TrackMin = movmin(stData.CorrRMS, stData.winLen);

% Adaptive thresholds
% stData.adapThreshCorr = 0.1*stData.TrackMax + 0.9*stData.TrackMin;
stData.adapThreshCorr = 0.3*stData.TrackMean + 0.7*stData.TrackMin;
stData.adapThreshCorr = max(stData.adapThreshCorr, MIN_CORR);


%__________________________________________________________________________
% find peaks in the correlation matrix
basefrequencies = logspace(log10(50),log10(450),200);
[stData.PeaksCorr, stData.LocsPeak] = ...
    DeterminePeaksCorrelation(correlation, basefrequencies, nBlocks);

% define critical value for peak height, peaks heigher than this value 
% corresponds to ovs
stData.nCritHeight = 25;
stData.vCritHeight = stData.PeaksCorr(:,1) >= stData.nCritHeight;

% Sliding max, mean and min
stData.TrackMax = movmax(stData.PeaksCorr(:,1), stData.winLen);
stData.TrackMean = movmean(stData.PeaksCorr(:,1), stData.winLen);
stData.TrackMin = movmin(stData.PeaksCorr(:,1), stData.winLen);

% find NaNs in moving mean, and set at these blocks the threshold to the
% minimum value
idxNaN = isnan(stData.TrackMean);

% Adaptive thresholds
stData.adapThreshPeakHeight = 0.1*stData.TrackMean + 0.9*stData.TrackMin;
stData.adapThreshPeakHeight(idxNaN) = MIN_CORR(idxNaN);
stData.adapThreshPeakHeight = max(stData.adapThreshPeakHeight, MIN_CORR);
stData.adapThreshPeakHeight = min(stData.adapThreshPeakHeight, stData.nCritHeight);

%__________________________________________________________________________
% check threshold
stData.vEstOVS = stData.CorrRMS >= stData.adapThreshCorr; 
% stData.vEstOVS = stData.PeaksCorr(:,1) >= stData.adapThreshPeakHeight; 

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