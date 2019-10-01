% test script belonging to getObjectiveData.m
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 26-Sep-2019 	JP

% clear;
close all;

% path to data folder (needs to be customized)
szBaseDir = '/Volumes/Samsung_T5/IHAB_1_EMA2018/IHAB_Rohdaten_EMA2018';
szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% get one subject directoy
szCurrentFolder = subjectDirectories(4).name;

% get object
% [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

szFeature = 'PSD';

% define figure width full screen in pixels
stRoots = get(0);

% get plot width
iPlotWidth = stRoots.ScreenSize(3);

[Data,TimeVec,stInfo] = getObjectiveData(obj, szFeature, ...
    'startDay','first','ENdDay','last', ...
    'StartTime',duration(8,0,0),'EndTime',duration(13,0,0), ...
    'PlotWidth',iPlotWidth);


% [Data,TimeVec,stInfo] = getObjectiveData(obj, szFeature, ...
%     'startDay','first', 'ENdDay', 'first', ...
%     'PlotWidth',iPlotWidth);

% [Data,TimeVec,stInfo] = getObjectiveData(obj, szFeature, ...
%     'StartTime',22,'EndTime',23);


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