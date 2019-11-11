% Test script belonging to getVoiveLabels.m
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 29-Oct-2019 JP

clear;

% path to main data folder (needs to be customized)
% obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\OUTDOOR';
% obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
% obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);
isDirectory = arrayfun(@(x)(x.isdir == 1), subjectDirectories);
subjectDirectories = subjectDirectories(isDirectory);

% number of subjects
nSubject = 1;

% choose one subject directoy
% obj.szCurrentFolder = subjectDirectories(nSubject).name;

% number of noise configuration
nConfig = 3;

% choose noise configurations
% obj.szNoiseConfig = ['config' num2str(nConfig)];
obj.szNoiseConfig = 'STREET';

% build the full directory
% obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
obj.szDir = [obj.szBaseDir filesep obj.szNoiseConfig];

% read in audio signal
% audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
audiofile = fullfile(obj.szDir, ['IHAB_' obj.szNoiseConfig '.wav']);
[WavData, Fs_in] = audioread(audiofile);

% set parameters for processing audio data
Fs = Fs_in/2;
mSignal = resample(WavData, Fs, Fs_in);

% calculate time vector
nLen = size(mSignal,1);           % signal length in samples
nDur = nLen/Fs;                   % signal duration in sec
nBlockSize = 0.125;               % duration one block in sec
nBlocks = floor(nDur/nBlockSize); % number of blocks
timeVec = linspace(0, nDur, nLen);
timeVecBlock = linspace(0, nDur, nBlocks);
    
% get labels 
obj.fsVD = nBlocks/nDur;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

% plot time signal with labels
figure;
plot(timeVec(1:100:end), mSignal(1:100:end, 1));
hold on;
plot(timeVecBlock, groundTrOVS, 'r');
plot(timeVecBlock, groundTrFVS, 'b');
xlabel('Time in sec');
xlim([timeVec(1) timeVec(end)]);

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