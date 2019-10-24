% Script to plot the objective data recorded by Nils Schreiber (2019) in
% real life
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 21-Oct-2019  JP

clear;
clc;
close all;

% define figure width full screen in pixels
stRoots = get(0);
% get plot width
iPlotWidth = stRoots.ScreenSize(3);

% path to main data folder (needs to be customized)
obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
isSubject = isValidLength & [subjectDirectories.isdir]';
subjectDirectories = subjectDirectories(isSubject);

% number of subjects
nSubject = size(subjectDirectories, 1);

% number of measurement configurations
nConfig = 7;

% use audio signal for analysis
obj.UseAudio = 1;

% loop over all subjects
for subj = 1:nSubject

    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(subj).name;

    % preallocate variables
    obj.stdRMSOVS = [];
    obj.stdRMSFVS = [];
    obj.stdRMSNone = [];
    
    % loop over all noise configurations
    for config = 1:nConfig
        close all;
        % choose noise configurations
        obj.szNoiseConfig = ['config' num2str(config)];

        obj = plotPROBANDData(obj, 'PlotWidth', iPlotWidth);

    end
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
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