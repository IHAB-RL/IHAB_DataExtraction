% Script to  to compare the RMS values with the calculated values based on
% the audio signal
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 13-Nov-2019 	JP

clear;

% path to main data folder (needs to be customized)
obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% number of subjects
nSubject = size(subjectDirectories, 1);

% choose one subject directoy
obj.szCurrentFolder = subjectDirectories(nSubject).name;

% number of noise configuration
nConfig = 1;

% choose noise configurations
obj.szNoiseConfig = ['config' num2str(nConfig)];

% build the full directory
obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

% select audio file
obj.audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);


% based on PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD, TimePSD, stInfoFile] = getObjectiveDataBilert(obj, szFeature);

% extract PSD data
version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
stDataOVD = OVD3(Cxy, Pxx, Pyy, stInfoFile.fs);
RMSfromPxx = stDataOVD.curRMSfromPxx;


% desired feature PSD
szFeature = 'RMS';

% get all available feature file data
[RMS_feat0, Time0, stInfoFile] = getObjectiveDataBilert(obj, szFeature);

% % set compression on
% obj.isCompression = true;
% 
% % get all available feature file data
% [RMS_feat, Time] = getObjectiveDataBilert(obj, szFeature);
[RMS_feat] = compressData(RMS_feat0, stInfoFile.nFrames);


% based on audio
stData = detectOVSRealCoherence([], obj);
RMS_audio = stData.mRMS;


% load subject and system specific calibration constants
szFile = 'I:\IdentificationSystems\IdentificationProbandSystem.mat';
load(szFile, 'stSubject_3', 'stSystem');

% subject - system
idxSubj = strcmp({stSubject_3.ID}, obj.szCurrentFolder);
szSystem = stSubject_3(idxSubj).System;

% system - calib constant
Calib_RMS = stSystem(strcmp({stSystem.System}, szSystem)).Calib;


% number of time frames
nBlocks = size(RMS_feat0, 1);
nBlocksAudio = size(RMS_audio, 1);
nBlocksPxx = size(RMSfromPxx, 1);

% calculate time vector
TimeVec = linspace(stData.TimeVec(1), stData.TimeVec(end), nBlocks);
TimeVecAudio = linspace(stData.TimeVec(1), stData.TimeVec(end), nBlocksAudio);
TimeVecPxx = linspace(stData.TimeVec(1), stData.TimeVec(end), nBlocksPxx);

% plot results
figure;
% subplot(3,1,1);
plot(Time0, 20*log10(RMS_feat0(:,1)) + Calib_RMS(:,1));
hold on;
% subplot(3,1,2);
plot(TimePSD, 20*log10(RMS_feat(:,1)) + Calib_RMS(:,1));
% plot(TimeVecAudio, 20*log10(RMS_audio(:,1)) + Calib_RMS(:,1));
% % subplot(3,1,3);
% plot(TimeVecPxx, 20*log10(RMSfromPxx(:,1)) + Calib_RMS(:,1));


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