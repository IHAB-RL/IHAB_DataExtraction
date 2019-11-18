% script to analyse the distribution of the rms
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 08-Nov-2019  JP

clear;
% close all;


% choose between data from Bilert or Schreiber or Pohlhausen
isBilert = 1;
isOutdoor = 0;
isSchreiber = 0;

% path to main data folder (needs to be customized)
if isBilert
    % path to main data folder (needs to be customized)
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB';
    
    if isOutdoor
        obj.szBaseDir = [obj.szBaseDir filesep 'OUTDOOR'];
        
        % list of measurement configurations
        nConfig = [1; 4];
        
        % labels of all noise configurations
        vLabels = {'CAR'; 'CITY'; 'COFFEE'; 'STREET'};
        
    else
        obj.szBaseDir = [obj.szBaseDir filesep 'PROBAND'];
        
        % number of first and last noise configuration
        nConfig = [1; 6];
        
        % labels of all noise configurations
        vLabels = {'Ruhe';'40 dB(A)';'50 dB(A)';'60 dB(A)';'65 dB(A)';'70 dB(A)'};
    end
    
elseif isSchreiber
    obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
    
    % number of first and last noise configuration
    nConfig = [1; 6];
    
    % labels of all noise configurations
    vLabels = {'CAR+friend';'car+friend';'kitchen';'conv.+music';'canteen';'silence'};
else
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
    
    % number of first and last noise configuration
    nConfig = [1; 3];
    
    % labels of all noise configurations
    vLabels = {'office';'canteen';'by foot'};
end

% define maximum number of blocks
nBlocksMax = 25*60/0.125; % 25 minutes recorded frames a 0.125 ms

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);
isDirectory = arrayfun(@(x)(x.isdir == 1), subjectDirectories);
subjectDirectories = subjectDirectories(isDirectory);

% number of subjects
nSubject = max(size(subjectDirectories, 1), 1);

% preallocate result matrix
nValuesMax = nSubject * nBlocksMax;
mZCR_OVS = NaN(nValuesMax, nConfig(2));
mZCR_FVS = NaN(nValuesMax, nConfig(2));
mZCR_None = NaN(nValuesMax, nConfig(2));
mZCR_diff_OVS = NaN(nValuesMax, nConfig(2));
mZCR_diff_FVS = NaN(nValuesMax, nConfig(2));
mZCR_diff_None = NaN(nValuesMax, nConfig(2));

nCountVS = zeros(nConfig(2), nSubject, 3);

% loop over all noise configurations
for config = nConfig(1):nConfig(2)
    % choose noise configurations
    if isOutdoor
        obj.szNoiseConfig = vLabels{config};
    else
        obj.szNoiseConfig = ['config' num2str(config)];
    end
    
    StartIdx = ones(3,1);
    % loop over all subjects
    for subj = 1:nSubject
        
        % choose one subject directoy
        if ~isempty(subjectDirectories)
            obj.szCurrentFolder = subjectDirectories(subj).name;
            
            % build the full directory
            obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
            
            % select audio file
            obj.audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
        else
            % build the full directory
            obj.szDir = [obj.szBaseDir filesep obj.szNoiseConfig];
            
            % select audio file
            obj.audiofile = fullfile(obj.szDir, ['IHAB_' obj.szNoiseConfig '.wav']);
        end
        
        
        % desired feature 
        szFeature = 'ZCR';
        
        % get all available feature file data
        [mZCR, ~, stInfo] = getObjectiveDataBilert(obj, szFeature);
        
        % set minimum time length in blocks
        nMinLen = 9600;

        % if no feature files are stored, extracted PSD from audio signals
        if isempty(mZCR) || size(mZCR, 1) <= nMinLen
            
            % read in audiosignal
            [mSignal, Fs_in] = audioread(obj.audiofile);

            % downsampling by factor 2
            Fs = Fs_in/2;
            mSignal = resample(mSignal, Fs, Fs_in);
            
            % just calculate for full minutes
            nRemain = rem(size(mSignal, 1), 60*Fs);
            if nRemain ~= 0
                mSignal(end-nRemain+1:end, :) = [];
            end
            nDur = size(mSignal, 1)/Fs; % duration in sec
            
            % calculate ZCR based on audio
            isPrivacy = true;
            [mZCR] = calcZCRframebased(mSignal, Fs, isPrivacy);
            
            % duration one frame in sec
            nLenFrame = nDur/size(mZCR, 1);
            
        else
            
            % duration one frame in sec
            nLenFrame = stInfo.HopSizeInSamples/stInfo.fs;
            
            % just calculate for full minutes
            nRemain = rem(size(mZCR, 1), 60/nLenFrame);
            if nRemain ~= 0
                mZCR(end-nRemain+1:end, :) = [];
            end
            
            % subsample by factor 10
            mZCR = mZCR(1:10:end, :);
        end
        
        % number of blocks
        nBlocks = size(mZCR, 1);
       
        
        mZCR_diff = mZCR(:, 3:4);
        mZCR(:, 3:4) = [];
        
        
        % get ground truth labels for voice activity
        obj.fsVD = 1/nLenFrame;
        obj.NrOfBlocks = nBlocks;
        [groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
        
        idxTrOVS = groundTrOVS == 1;
        idxTrFVS = groundTrFVS == 1;
        idxTrNone = ~idxTrOVS & ~idxTrFVS;
        
        % count number of specific voice sequences
        nCountVS(config, subj, 1) = 2*sum(idxTrOVS);
        nCountVS(config, subj, 2) = 2*sum(idxTrFVS);
        nCountVS(config, subj, 3) = 2*sum(idxTrNone);
        
        
        % construct matrix with pooled data
        mZCR_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = mZCR([idxTrOVS idxTrOVS]);
        mZCR_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = mZCR([idxTrFVS idxTrFVS]);
        mZCR_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = mZCR([idxTrNone idxTrNone]);
        mZCR_diff_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = mZCR_diff([idxTrOVS idxTrOVS]);
        mZCR_diff_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = mZCR_diff([idxTrFVS idxTrFVS]);
        mZCR_diff_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = mZCR_diff([idxTrNone idxTrNone]);
        
        
        % adjust index
        StartIdx(1) = StartIdx(1) + nCountVS(config, subj, 1);
        StartIdx(2) = StartIdx(2) + nCountVS(config, subj, 2);
        StartIdx(3) = StartIdx(3) + nCountVS(config, subj, 3);
        
    end
end

% get maximum of number of peak values
nValues = max(max(sum(nCountVS(:, :, :), 2)));

% adjust peak vectors to one length
mZCR_OVS(nValues+1:end, :) = [];
mZCR_FVS(nValues+1:end, :) = [];
mZCR_None(nValues+1:end, :) = [];
mZCR_diff_OVS(nValues+1:end, :) = [];
mZCR_diff_FVS(nValues+1:end, :) = [];
mZCR_diff_None(nValues+1:end, :) = [];


% ZCR
hFig1 = figure;
subplot(1,3,1);
boxplot(mZCR_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
% violinplot(mZCR_OVS,vLabels,'ViolinColor',[1 0 0]);
title('ZCR at OVS');
xlabel('noise configuration');
ylabel('ZCR');
ymax = 500;
ylim([0 ymax]);

subplot(1,3,2);
boxplot(mZCR_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
% violinplot(mZCR_FVS,vLabels,'ViolinColor',[0 0 1]);
title('ZCR at FVS');
xlabel('noise configuration');
ylabel('ZCR');
ylim([0 ymax]);

subplot(1,3,3);
boxplot(mZCR_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% violinplot(mZCR_None,vLabels,'ViolinColor',[0 0.6 0.2]);
title('ZCR at no VS');
xlabel('noise configuration');
ylabel('ZCR');
ylim([0 ymax]);


% ZCR difference signal
hFig2 = figure;
subplot(1,3,1);
boxplot(mZCR_diff_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
% violinplot(mZCR_diff_OVS,vLabels,'ViolinColor',[1 0 0]);
title('ZCR(diff) at OVS');
xlabel('noise configuration');
ylabel('ZCR');
ylim([0 ymax]);

subplot(1,3,2);
boxplot(mZCR_diff_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
% violinplot(mZCR_diff_FVS,vLabels,'ViolinColor',[0 0 1]);
title('ZCR(diff) at FVS');
xlabel('noise configuration');
ylabel('ZCR');
ylim([0 ymax]);

subplot(1,3,3);
boxplot(mZCR_diff_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% violinplot(mZCR_diff_None,vLabels,'ViolinColor',[0 0.6 0.2]);
title('ZCR(diff) at no VS');
xlabel('noise configuration');
ylabel('ZCR');
ylim([0 ymax]);


% logical to save figures
bPrint = 1;
if bPrint
    szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Distribution';
    
    exportNames = {[szDir filesep 'DistributionZCR'];...
        [szDir filesep 'DistributionZCR_diff']};
    if isSchreiber
        exportNames = strcat(exportNames, '_NS');
    elseif isOutdoor
        exportNames = strcat(exportNames, '_OD');
    elseif ~isBilert
        exportNames = strcat(exportNames, '_JP');
    end
    
    savefig(hFig1, exportNames{1});
    savefig(hFig2, exportNames{2});
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