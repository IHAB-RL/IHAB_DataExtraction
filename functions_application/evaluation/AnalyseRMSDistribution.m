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
mRMS_std_OVS = NaN(nValuesMax, nConfig(2));
mRMS_std_FVS = NaN(nValuesMax, nConfig(2));
mRMS_std_None = NaN(nValuesMax, nConfig(2));
mRMS_eqd_OVS = NaN(nValuesMax, nConfig(2));
mRMS_eqd_FVS = NaN(nValuesMax, nConfig(2));
mRMS_eqd_None = NaN(nValuesMax, nConfig(2));
mRMS_env_OVS = NaN(nValuesMax, nConfig(2));
mRMS_env_FVS = NaN(nValuesMax, nConfig(2));
mRMS_env_None = NaN(nValuesMax, nConfig(2));

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
        
        
        % desired feature RMS
        szFeature = 'RMS';
        
        % get all available feature file data
        [mRMS, ~, stInfo] = getObjectiveDataBilert(obj, szFeature);
        
        % set minimum time length in blocks
        nMinLen = 960;

        % if no feature files are stored, extracted PSD from audio signals
        if isempty(mRMS) || size(mRMS, 1) <= nMinLen
            
            obj.isPrivacy = false;
            
            % call funtion to calculate PSDs
            stData = detectOVSRealCoherence([], obj);
            
            % re-assign values
            mRMS = stData.mRMS;
            
            % duration one frame in sec
            nLenFrame = stData.nSigDur/size(mRMS, 1);
        
            % new number of frames per minute
            nFrames = round(60/nLenFrame/10);
            
            clear stData
        else
            
            % duration one frame in sec
            nLenFrame = stInfo.HopSizeInSamples/stInfo.fs;
        
            % new number of frames per minute
            nFrames = round(stInfo.nFrames/10);
        end
        
        nRemain = rem(size(mRMS, 1), 10*nFrames);
        if nRemain ~= 0
            mRMS(end-nRemain+1:end, :) = [];
        end
        
        % number of blocks
        nBlocks = size(mRMS, 1)/10;
       
        
        % claculate std of signal envelope
        alpha = 0.2; % smoothing constant
        mPower_smooth = filter([1-alpha],[1 -alpha], mRMS.^2);

        % smooth envelope data
        mEnv_smooth = filter([1-alpha],[1 -alpha], mRMS);

        % calculate standard deviation of the signal envelope
        mSTD_Env = sqrt(mPower_smooth - mEnv_smooth.^2);
        
        % calculate standard deviation and Empirischer 
        % Quartilsdispersionskoeffizient of 10 adjacent blocks
        std_RMS = NaN(nBlocks, 2);
        std_Env = NaN(nBlocks, 2);
        eqd_RMS = NaN(nBlocks, 2);
        for iLoop = 1:nBlocks
            
            mBlockRMS = mRMS(1+(iLoop-1)*10:iLoop*10, :);
            
            std_RMS(iLoop, :) = std(mBlockRMS);
            
            eqd_RMS(iLoop, :) = ((prctile(mBlockRMS, 75)-prctile(mBlockRMS, 25))./ median(mBlockRMS))';
            
            std_Env(iLoop, :) = mean(mSTD_Env(1+(iLoop-1)*10:iLoop*10, :));
            
        end
       
        
        % get ground truth labels for voice activity
        obj.fsVD = round(1/(10*nLenFrame));
        obj.NrOfBlocks = nBlocks;
        [groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
        
        idxTrOVS = groundTrOVS == 1;
        idxTrFVS = groundTrFVS == 1;
        idxTrNone = ~idxTrOVS & ~idxTrFVS;
        
        % count number of specific voice sequences
        nCountVS(config, subj, 1) = 2*sum(idxTrOVS);
        nCountVS(config, subj, 2) = 2*sum(idxTrFVS);
        nCountVS(config, subj, 3) = 2*sum(idxTrNone);
        
        
        % construct matrix with pooled rms data
        mRMS_std_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = std_RMS([idxTrOVS idxTrOVS]);
        mRMS_std_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = std_RMS([idxTrFVS idxTrFVS]);
        mRMS_std_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = std_RMS([idxTrNone idxTrNone]);
        
        % construct matrix with pooled rms data
        mRMS_eqd_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = eqd_RMS([idxTrOVS idxTrOVS]);
        mRMS_eqd_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = eqd_RMS([idxTrFVS idxTrFVS]);
        mRMS_eqd_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = eqd_RMS([idxTrNone idxTrNone]);
        
        % construct matrix with pooled rms data
        mRMS_env_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = std_Env([idxTrOVS idxTrOVS]);
        mRMS_env_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = std_Env([idxTrFVS idxTrFVS]);
        mRMS_env_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = std_Env([idxTrNone idxTrNone]);
        
        
        % adjust index
        StartIdx(1) = StartIdx(1) + nCountVS(config, subj, 1);
        StartIdx(2) = StartIdx(2) + nCountVS(config, subj, 2);
        StartIdx(3) = StartIdx(3) + nCountVS(config, subj, 3);
        
    end
end

% get maximum of number of peak values
nValues = max(max(sum(nCountVS(:, :, :), 2)));

% adjust peak vectors to one length
mRMS_std_OVS(nValues+1:end, :) = [];
mRMS_std_FVS(nValues+1:end, :) = [];
mRMS_std_None(nValues+1:end, :) = [];
mRMS_eqd_OVS(nValues+1:end, :) = [];
mRMS_eqd_FVS(nValues+1:end, :) = [];
mRMS_eqd_None(nValues+1:end, :) = [];


% STD
hFig1 = figure;
subplot(1,3,1);
boxplot(mRMS_std_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
% violinplot(mRMS_std_OVS,vLabels,'ViolinColor',[1 0 0]);
title('std(RMS) at OVS');
xlabel('noise configuration');
ylabel('std(RMS)');
ylim([0 0.35]);

subplot(1,3,2);
boxplot(mRMS_std_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
% violinplot(mRMS_std_FVS,vLabels,'ViolinColor',[0 0 1]);
title('std(RMS) at FVS');
xlabel('noise configuration');
ylabel('std(RMS)');
ylim([0 0.35]);

subplot(1,3,3);
boxplot(mRMS_std_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% violinplot(mRMS_std_None,vLabels,'ViolinColor',[0 0.6 0.2]);
title('std(RMS) at no VS');
xlabel('noise configuration');
ylabel('std(RMS)');
ylim([0 0.35]);


% EQD
hFig2 = figure;
subplot(1,3,1);
boxplot(mRMS_eqd_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
% violinplot(mRMS_eqd_OVS,vLabels,'ViolinColor',[1 0 0]);
title('eqd(RMS) at OVS');
xlabel('noise configuration');
ylabel('eqd(RMS)');
ylim([0 30]);

subplot(1,3,2);
boxplot(mRMS_eqd_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
% violinplot(mRMS_eqd_FVS,vLabels,'ViolinColor',[0 0 1]);
title('eqd(RMS) at FVS');
xlabel('noise configuration');
ylabel('eqd(RMS)');
ylim([0 30]);

subplot(1,3,3);
boxplot(mRMS_eqd_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% violinplot(mRMS_eqd_None,vLabels,'ViolinColor',[0 0.6 0.2]);
title('eqd(RMS) at no VS');
xlabel('noise configuration');
ylabel('eqd(RMS)');
ylim([0 30]);


% std Envelope
hFig3 = figure;
subplot(1,3,1);
boxplot(mRMS_env_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
title('std(Env) at OVS');
xlabel('noise configuration');
ylabel('std(Env)');
ylim([0 0.1]);

subplot(1,3,2);
boxplot(mRMS_env_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
title('std(Env) at FVS');
xlabel('noise configuration');
ylabel('std(Env)');
ylim([0 0.1]);

subplot(1,3,3);
boxplot(mRMS_env_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
title('std(Env) at no VS');
xlabel('noise configuration');
ylabel('std(Env)');
ylim([0 0.1]);


% logical to save figures
bPrint = 1;
if bPrint
    szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Distribution';
    
    exportNames = {[szDir filesep 'DistributionSTDRMS'];...
        [szDir filesep 'DistributionEQDRMS'];...
        [szDir filesep 'DistributionSTDEnv_Kates2008']};
    if isSchreiber
        exportNames = strcat(exportNames, '_NS');
    elseif isOutdoor
        exportNames = strcat(exportNames, '_OD');
    elseif ~isBilert
        exportNames = strcat(exportNames, '_JP');
    end
    
    savefig(hFig1, exportNames{1});
    savefig(hFig2, exportNames{2});
    savefig(hFig3, exportNames{3});
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