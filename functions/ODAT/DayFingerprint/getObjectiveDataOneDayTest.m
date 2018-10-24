% Script to test the function [Data,TimeVec]=getObjectiveDataOneDay(szTestSubject,desiredDay).m 
% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 15-May-2017 			 Initials (eg. JB)

clear;
close all;
clc;

%------------Your script starts here-------- 
%addpath('../Tools');
%addpath('../DroidFeatureTools');
%Define your parameters and adjust your function call
%szBaseDir = '../HALLO_EMA2016_all';
szBaseDir = fullfile(pwd,'IHAB_Rohdaten_EMA2018');
%szTestSubject =  'AS05EB18';%AS05EB18_161130_mh
%desiredDay = datetime(2016,10,27);
szTestSubject =  'JB11JB11';
desiredDay = datetime(2018,4,18);


szFeature = 'PSD';
tic
%[DataOld,TimeVecOld,NrOfPartsOld]=getObjectiveDataOneDayOld(szBaseDir,szTestSubject,desiredDay, szFeature,2);

[Data,TimeVec,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,2);

toc
%[Data,TimeVec,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,2);
%[Data,TimeVec,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,3);
%[Data,TimeVec,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,4);
%tic
%[Data,TimeVec,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,5);
%toc
%[Data,TimeVec,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,6);
rmpath('../Tools');
rmpath('../DroidFeatureTools');

%--------------------Licence ---------------------------------------------
% Copyright (c) <2017> J.Bitzer
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