function [L_OVS,L_FVS,L_noVS]=calcSNR(obj)
% function to calculate the SNR
% Usage [outParam]=calcSNR(inParam)
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% Returns
% -------
% L_OVS : mean RMS in dB SPL at OVS
% 
% L_FVS : mean RMS in dB SPL at FVS
% 
% L_noVS: mean RMS in dB SPL at no VS
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 08-Jan-2020  JP

% check whether the number of feature files is valid or not
obj = checkNrOfFeatFiles(obj);

% if no or not all feature files are stored, extract data from audio
if obj.UseAudio
    
    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);
    
    % re-assign values
    mRMS = stData.mRMS;
    SampleRate = stData.fs;
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;
    
else
    
    % desired feature RMS
    szFeature = 'RMS';
    
    % set compression on
    obj.isCompression = true;
    
    % get all available feature file data
    [mRMS, ~, stInfo] = getObjectiveDataBilert(obj, szFeature);
    
    % sampling frequency in Hz
    SampleRate = stInfo.fs;
    
    % duration one frame in sec
    nLenFrame = 10*stInfo.HopSizeInSamples/SampleRate;
end


% number of time frames
nBlocks = size(mRMS, 1);


% load subject and system specific calibration constants
szFile = 'I:\IdentificationSystems\IdentificationProbandSystem.mat';
load(szFile, 'stSubject_3', 'stSystem');

% subject - system
if isfield(obj, 'szCurrentFolder')
    idxSubj = strcmp({stSubject_3.ID}, obj.szCurrentFolder);
    szSystem = stSubject_3(idxSubj).System;
else
    % Outdoor by SB
    szSystem = 'SystemSB';
end

% system - calib constant
Calib_RMS = stSystem(strcmp({stSystem.System}, szSystem)).Calib;

% transfer to dB SPL
mRMS_dBSPL = 20*log10(mRMS) + Calib_RMS;


% get ground truth voice labels
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get voice labels
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
groundTrOVS = logical(groundTrOVS);
groundTrFVS = logical(groundTrFVS);

noVS = ~groundTrFVS & ~groundTrOVS;

vRMS_OVS = mRMS(groundTrOVS, :);

L_OVS = mean(20*log10(mean(vRMS_OVS))+Calib_RMS);
L_OVS = 20*log10(prctile(vRMS_OVS(:), 25))+Calib_RMS(1);
L_FVS = mean(20*log10(mean(mRMS(groundTrFVS, :)))+Calib_RMS);
L_noVS = mean(20*log10(mean(mRMS(noVS, :)))+Calib_RMS);

% SNR = L_FVS - L_noVS;
% 
% % build the full directory
% if isfield(obj, 'szCurrentFolder')
%     szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
% 
%     szFile = ['SPL_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
% else
%     szDir = obj.szBaseDir;
%     
%     szFile = ['SPL_'  obj.szNoiseConfig];
% end
% szFolder_Output = [szDir filesep 'FeatureExtraction'];
% if ~exist(szFolder_Output, 'dir')
%     mkdir(szFolder_Output);
% end
% 
% % save results as mat file
% save([szFolder_Output filesep szFile], 'L_OVS', 'L_FVS', 'L_noVS', 'SNR');

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