function [hFig] = plotConfusionMatrix(mConfusion, vLabels, vGroundTruth, vPredicted)
%% function to plot a confusion matrix
% Usage : [hFig] = plotConfusionMatrix(mConfusion, vLabels, szTitle)
% Usage2 : [hFig] = plotConfusionMatrix([], vLabels, vGroundTruth, vPredicted)
%
% Parameters
% ----------
% inParam :  mConfusion : NxN matrix, contains the confusion matrix to be
%                         plotted with absolute values
%            vLabels    : string array, containing N class labels
%            vGroundTruth :  vector, containing ground truth data (1 || 0)
%            vPredicted   :  vector, containing predicted data (1 || 0)
%
% outParam : hFig : handle to confusion plot figure 
%------------------------------------------------------------------------
% Example 1: confmat = magic(3);
%            labels = {'Dog', 'Cat', 'Horse'};
%            plotConfusionMatrix(confmat, labels);
%
% Example 2: vGroundTruth = [0 0 0 1 1 0 1 1 1 0 0 1];
%            vPredicted = [1 0 0 1 1 0 1 0 0 0 1 1];
%            vLabels = {'OVS', 'no OVS'};
%            plotConfusionMatrix([], vLabels, vGroundTruth, vPredicted);
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: https://stackoverflow.com/questions/33451812/plot-confusion-matrix
% Version History:
% Ver. 0.01 initial create 23-Sep-2019  JP

if nargin == 4
    % calculate confusion matrix
    tp = sum((vPredicted == 1) & (vGroundTruth == 1));
    tn = sum((vPredicted == 0) & (vGroundTruth == 0));
    fp = sum((vPredicted == 1) & (vGroundTruth == 0));
    fn = sum((vPredicted == 0) & (vGroundTruth == 1));
    
    mConfusion = [tp fp; fn tn];
end

stTitle = [];
if nargin == 3
    stTitle = [': ' vGroundTruth];
end

% number of labels
numlabels = size(mConfusion, 1);

% calculate the percentage accuracies
confpercent = 100*mConfusion./repmat(sum(mConfusion, 1),numlabels,1);

% plotting the colors
hFig = figure;
imagesc(confpercent);
title(['Confusion Matrix' stTitle]);
ylabel('Predicted Values'); xlabel('Actual Values');

% set the colormap
colormap(flipud(autumn));

% Create strings from the matrix values and remove spaces
textStrings = num2str([confpercent(:), mConfusion(:)], '%.1f%%\n%d\n');
textStrings = strtrim(cellstr(textStrings));

% Create x and y coordinates for the strings and plot them
[x,vPredicted] = meshgrid(1:numlabels);
hStrings = text(x(:),vPredicted(:),textStrings(:), ...
    'HorizontalAlignment','center');

% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));

% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(confpercent(:) > midValue,1,3);
set(hStrings,{'Color'},num2cell(textColors,2));

% Setting the axis labels
set(gca,'XTick',1:numlabels,...
    'XTickLabel',vLabels,...
    'YTick',1:numlabels,...
    'YTickLabel',vLabels,...
    'TickLength',[0 0]);

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

% eof