function [peaks,locs,hFig,peaksOVS,peaksFVS,peaksNone] = ...
    DeterminePeaksCorrelation(correlation,basefrequencies,nBlocks,idxTrOVS,idxTrFVS,idxTrNone)
% function to find peaks in the correlation (magnitude feature by Bechtold)
% If no peaks occur, NaNs are saved
% If no labels are given only the general peaks and locs are returned
% Usage [peaks,locs,hFig,peaksOVS,peaksFVS,peaksNone] = ...
%    DeterminePeaksCorrelation(correlation,basefrequencies,nBlocks,idxTrOVS,idxTrFVS,idxTrNone)
%
% Parameters
% ----------
% inParam :  
%   correlation - len(nBlocks) x len(basefrequencies) matrix, containing 
%                 the magnitude feature, calculated for a set of given 
%                 basefrequencies (cf. CalcCorrelation.m)
%
%   basefrequencies - vector, contains the basefrequencies, e.g. 200
%                     candidates between 50 and 450 Hz (logarithmic spaced)
%
%   nBlocks  - number of time frames
%
%   idxTrOVS - logical array len(nBlocks), 1 = OVS
%
%   idxTrFVS - logical array len(nBlocks), 1 = FVS
%
%   idxTrNone - logical array len(nBlocks), 1 = no VS
%
% Returns
% -------
% outParam :  
%   peaks     - matrix, contains the height of the three highest peaks for 
%               each time frame
%
%   locs      - matrix, contains the corresponding basefrequency of the 
%               three highest peaks for each time frame
%
%   hFig      - handle to figure
%
%   peaksOVS  - like peaks, just for OVS
%
%   peaksFVS  - like peaks, just for FVS
%
%   peaksNone - like peaks, just for no VS
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 04-Nov-2019  Initials JP

% supress warnings
warning('off','signal:findpeaks:largeMinPeakHeight');

% pre allocate output args
peaks = NaN(nBlocks, 3);
locs = NaN(nBlocks, 3);

% peak definition
MaxNrOfPeaks = 3; % find maximal 3 peaks
% MinPeakHeight = 1; % minimum peak height
MinPeakDistance = 20; % minimum peak distance in Hz

% determine peaks in magnitude feature
for blockidx = 1:nBlocks
    
    % determine % minimum peak prominence
    MinPeakProminence = max(0.1*max(correlation(blockidx,:)), 10^-8); 
    
    [peaksTemp, locsTemp] = findpeaks(correlation(blockidx,:), ...
        basefrequencies, 'NPeaks', MaxNrOfPeaks, 'MinPeakProminence', MinPeakProminence, ...
        'SortStr', 'descend', 'MinPeakDistance', MinPeakDistance);
    findpeaks(correlation(blockidx,:), ...
        basefrequencies, 'NPeaks', MaxNrOfPeaks, 'MinPeakProminence', MinPeakProminence, ...
        'SortStr', 'descend', 'MinPeakDistance', MinPeakDistance,'Annotate','extents');
    
    % actual number of peaks
    nPeaks = size(peaksTemp, 2);
    
    if ~isempty(nPeaks) && nPeaks > 0
        peaks(blockidx,1:nPeaks) = peaksTemp;
        locs(blockidx,1:nPeaks) = locsTemp;
    end
   
end

if nargin == 3
    hFig = []; 
    peaksOVS = []; 
    peaksFVS = []; 
    peaksNone = []; 
    return;
end

% plot peak results
peaksOVS = peaks(idxTrOVS, :);
peaksFVS = peaks(idxTrFVS, :);
peaksNone = peaks(idxTrNone, :);
locsOVS = locs(idxTrOVS, :);
locsFVS = locs(idxTrFVS, :);
locsNone = locs(idxTrNone, :);
% sum(isnan(peaksOVS))

% % adjust peak vectors to one length
% nPeakValues = max([size(peaksOVS,1), size(peaksFVS,1), size(peaksNone,1)]);
% peaksOVS(end+1:nPeakValues, :) = NaN;
% peaksFVS(end+1:nPeakValues, :) = NaN;
% peaksNone(end+1:nPeakValues, :) = NaN;

hFig = figure;
% GroupedBoxplot(peaksOVS, peaksFVS, peaksNone, [nPeakValues 3])
subplot(2,3,1);
boxplot(peaksOVS, 'Colors', 'r','Whisker', 1);
title('Peak Height at OVS');
xlabel('Number of Peak');
ylabel('Peak Height F^M_t(f_0)');
subplot(2,3,2);

boxplot(peaksFVS, 'Colors', 'b','Whisker', 1);
title('Peak Height at FVS');
xlabel('Number of Peak');
ylabel('Peak Height F^M_t(f_0)');

subplot(2,3,3);
boxplot(peaksNone, 'Colors', [0 0.6 0.2],'Whisker', 1);
title('Peak Height at no VS');
xlabel('Number of Peak');
ylabel('Peak Height F^M_t(f_0)');


subplot(2,3,4);
boxplot(locsOVS, 'Colors', 'r','Whisker', 1);
title('Frequency at Peak at OVS');
xlabel('Number of Peak');
ylabel('Fundamental Frequency in Hz');

subplot(2,3,5);
boxplot(locsFVS, 'Colors', 'b','Whisker', 1);
title('Frequency at Peak at FVS');
xlabel('Number of Peak');
ylabel('Fundamental Frequency in Hz');

subplot(2,3,6);
boxplot(locsNone, 'Colors', [0 0.6 0.2],'Whisker', 1);
title('Frequency at Peak at no VS');
xlabel('Number of Peak');
ylabel('Fundamental Frequency in Hz');



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