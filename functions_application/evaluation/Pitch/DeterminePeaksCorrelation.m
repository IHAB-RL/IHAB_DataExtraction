function [peaks,locs,hFig,peaksOVS,peaksFVS,peaksNone] = ...
    DeterminePeaksCorrelation(correlation,basefrequencies,nBlocks,idxTrOVS,idxTrFVS,idxTrNone)
% function to do something usefull (fill out)
% Usage [outParam]=DeterminePeaksCorrelation(inParam)
%
% Parameters
% ----------
% inParam :  type
%	 explanation
%
% Returns
% -------
% outParam :  type
%	 explanation
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 04-Nov-2019  Initials JP

% determine peaks in magnitude feature
peaks = NaN(nBlocks, 3);
locs = NaN(nBlocks, 3);
for blockidx = 1:nBlocks
    [peaksTemp, locsTemp] = findpeaks(correlation(blockidx,:), ...
        basefrequencies, 'NPeaks', 3, 'MinPeakHeight', 1, ...
        'SortStr', 'descend', 'MinPeakDistance', 20);
    
    % actual number of peaks
    nPeaks = size(peaksTemp, 2);
    
    if ~isempty(nPeaks) && nPeaks > 0
        peaks(blockidx,1:nPeaks) = peaksTemp;
        locs(blockidx,1:nPeaks) = locsTemp;
    end
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