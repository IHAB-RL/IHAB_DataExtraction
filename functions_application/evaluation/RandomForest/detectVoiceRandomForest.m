function [vPredictedVS,vTime,Cxy]=detectVoiceRandomForest(obj,stDate,szMode)
% function to predict voice sequences with a trained random forest
% Usage [vPredictedVS]=detectVoiceRandomForest(obj, stDate)
%
% Parameters
% ----------
% obj - class IHABdata, contains all informations
%
% stDate - struct which contains valid date informations about the time
%          informations: start and end day and time; this struct results
%          from calling checkInputFormat.m
%
% szMode - string: 'OVD' | 'FVD' 
%
% Returns
% -------
% vPredictedOVS - vector, contains frame based 1 (==voice) | 0 (==no voice)
%
% vTime - corresponding time vector
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019 JP

% load trained random forest (cave!)
szTreeDir = [obj.sFolderMain filesep 'functions_helper'];
if strcmp(szMode, 'OVD')
    
    szName = 'RandomForest_100Trees_OVD_PredictorSet4.mat';
    
elseif strcmp(szMode, 'FVD')
    
    szName = 'RandomForest_100Trees_FVD_PredictorSet6.mat';
    
else % tbd
    
    %     load('EnsembleTrees', 'RandomForest', 'szVarNames');
end

load([szTreeDir filesep szName], 'MRandomForest', 'szVarNames');

% extract features needed for VD
[mDataSet, vTime, Cxy] = FeatureExtraction(obj, stDate, szVarNames);

% if for the given time interval no data is available, return empty vector
if size(mDataSet, 1) == 1
    vPredictedVS = [];
    return;
end

% start prediction with trained ensemble of bagged classification trees
vPredictedVS = predict(MRandomForest, mDataSet);
vPredictedVS = str2num(cell2mat(vPredictedVS));


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