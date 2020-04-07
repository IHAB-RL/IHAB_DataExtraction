% Script to test the function analyseVSperDay.m
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 04-Feb-2020 	JP
% Ver. 1.0 new input options 6-Apr-2020 JP

% clear;
close all;

% path to data folder (needs to be customized!)
% szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';
szBaseDir = '/Volumes/Samsung_T5/IHAB_1_EMA2018/IHAB_Rohdaten_EMA2018';

% get current subject directoy
szCurrentFolder = 'NN07IS04_180611_ks';

% get object
[obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

% preallocate struct for date values
stDate = struct('StartTime', [], 'EndTime', [], 'StartDay', [], 'EndDay', []);


% adjust day in struct
stDate.StartDay = datetime(2018,6,13);
stDate.EndDay = stDate.StartDay;

% adjust time in struct
nStartTime = 10;
stDate.StartTime = duration(nStartTime, 0, 1);
stDate.EndTime = duration(nStartTime, 10, 0);

% duration of one block in sec
nDurBlock = 5;

% overlap of adjacent blocks
nOverlap = 0.5;

% threshold for decision voiced/unvoiced block, i.e. minimum ratio of
% detected voiced frames
nCritRatio = 0.2;
    
% call function to analyse distribution of VS
[vOVS, vTimeVD] = analyseVSperDay(obj,stDate,nDurBlock,nCritRatio,nOverlap);
    

%--------------------Licence ---------------------------------------------
% Copyright (c) <2020> J. Pohlhausen
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