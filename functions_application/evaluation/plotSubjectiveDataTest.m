% test script belongigng to plotSubjectiveData.m
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 01-Oct-2019 	JP


% clear; 
close all;

% path to data folder (needs to be customized)
szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% get one subject directoy
szCurrentFolder = subjectDirectories(10).name;

% get object
% [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

iPlotWidth = 800;
iPlotHeight = 1122.5;

figure('PaperPosition',[0 0 1 1],'Position',[0 0 iPlotWidth iPlotHeight]);
GUI_xStart = 0.1300;
GUI_xAxesWidth = 0.7750;

axCoher = axes('Position',[GUI_xStart 0.6 GUI_xAxesWidth 0.18]);
PosVecCoher = get(axCoher,'Position');

bPrint = 1;

% call function to check input date format and plausibility
stInfo = checkInputFormat(obj, 0, 24, 2, 2);

[hasSubjectiveData, axQ] = plotSubjectiveData(obj, stInfo, bPrint, GUI_xStart, PosVecCoher);

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> Jule Pohlhausen
% Institute for Hearing Technology and Audiology
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