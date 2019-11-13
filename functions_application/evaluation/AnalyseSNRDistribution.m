% script to analyse the distribution of the calculated a priori SNR
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 08-Nov-2019  JP

clear;
% close all;


% choose between data from Bilert or Schreiber or Pohlhausen
isBilert = 0;
isOutdoor = 0;
isSchreiber = 1;

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
mSNR_OVS = NaN(nValuesMax, nConfig(2));
mSNR_FVS = NaN(nValuesMax, nConfig(2));
mSNR_None = NaN(nValuesMax, nConfig(2));
mSPP_OVS = NaN(nValuesMax, nConfig(2));
mSPP_FVS = NaN(nValuesMax, nConfig(2));
mSPP_None = NaN(nValuesMax, nConfig(2));

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
        
        % desired feature PSD
        szFeature = 'PSD';
        
        % get all available feature file data
        [DataPSD,TimeVec,stInfoPSD] = getObjectiveDataBilert(obj, szFeature);
        
        % if no feature files are stored, extracted PSD from audio signals
        if isempty(DataPSD)
            
            % call funtion to calculate PSDs
            stData = detectOVSRealCoherence([], obj);
            
            % re-assign values
            Pxx = stData.Pxx';
            Pyy = stData.Pyy';
            Cxy = stData.Cxy';
            nFFT = stData.nFFT;
            samplerate = stData.fs;
            
            % duration one frame in sec
            nLenFrame = stData.tFrame;
            
            clear stData
        else
            
            % extract PSD data
            version = 1; % JP modified get_psd
            [Cxy, Pxx, Pyy] = get_psd(DataPSD, version);
            
            clear DataPSD
            
            % sampling frequency in Hz
            samplerate = stInfoPSD.fs;
            
            % number of fast Fourier transform points
            nFFT = (stInfoPSD.nDimensions - 2 - 4)/2;
            
            % duration one frame in sec
            nLenFrame = 60/stInfoPSD.nFrames;
        end
        
        
        
        %% VOICE DETECTION by Schreiber 2019
        stDataOVD = OVD3(Cxy, Pxx, Pyy, samplerate);
        
        % a posteriori speech presence probability
        vFreqRange = [120 1000];
        vFreqBins = round(vFreqRange./samplerate*nFFT);
        meanSPP = mean(stDataOVD.PH1(vFreqBins(1):vFreqBins(2),:),1);
        
        
        %% get ground truth labels for voice activity
        obj.fsVD = 1/nLenFrame;
        obj.NrOfBlocks = size(Pxx, 1);
        [groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
        
        idxTrOVS = groundTrOVS == 1;
        idxTrFVS = groundTrFVS == 1;
        idxTrNone = ~idxTrOVS & ~idxTrFVS;
        
        % count number of specific voice sequences
        nCountVS(config, subj, 1) = sum(idxTrOVS);
        nCountVS(config, subj, 2) = sum(idxTrFVS);
        nCountVS(config, subj, 3) = sum(idxTrNone);
        
        
        % construct matrix with pooled data: SNR
        mSNR_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = stDataOVD.movAvgSNR(idxTrOVS);
        mSNR_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = stDataOVD.movAvgSNR(idxTrFVS);
        mSNR_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = stDataOVD.movAvgSNR(idxTrNone);
        
        % construct matrix with pooled data: SPP
        mSPP_OVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = meanSPP(idxTrOVS);
        mSPP_FVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = meanSPP(idxTrFVS);
        mSPP_None(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = meanSPP(idxTrNone);
        
        % adjust index
        StartIdx(1) = StartIdx(1) + nCountVS(config, subj, 1);
        StartIdx(2) = StartIdx(2) + nCountVS(config, subj, 2);
        StartIdx(3) = StartIdx(3) + nCountVS(config, subj, 3);
        
    end
end


% SNR
hFig1 = figure;
subplot(1,3,1);
boxplot(mSNR_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
% violinplot(mSNR_OVS,vLabels,'ViolinColor',[1 0 0]);
title('a priori SNR at OVS');
xlabel('noise configuration');
ylabel('a priori SNR in dB');
ylim([0 100]);

subplot(1,3,2);
boxplot(mSNR_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
% violinplot(mSNR_FVS,vLabels,'ViolinColor',[0 0 1]);
title('a priori SNR at FVS');
xlabel('noise configuration');
ylabel('a priori SNR in dB');
ylim([0 100]);

subplot(1,3,3);
boxplot(mSNR_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% violinplot(mSNR_None,vLabels,'ViolinColor',[0 0.6 0.2]);
title('a priori SNR at no VS');
xlabel('noise configuration');
ylabel('a priori SNR in dB');
ylim([0 100]);


% SPP
hFig2 = figure;
subplot(1,3,1);
boxplot(mSPP_OVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
title('a posteriori SPP at OVS');
xlabel('noise configuration');
ylabel('speech presence probability');
ylim([0 1]);

subplot(1,3,2);
boxplot(mSPP_FVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
title('a posteriori SPP at FVS');
xlabel('noise configuration');
ylabel('speech presence probability');
ylim([0 1]);

subplot(1,3,3);
boxplot(mSPP_None,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
title('a posteriori SPP at no VS');
xlabel('noise configuration');
ylabel('speech presence probability');
ylim([0 1]);


% logical to save figures
bPrint = 1;
if bPrint
    szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Distribution';
    
    exportNames = {[szDir filesep 'DistributionPrioriSNR'];...
        [szDir filesep 'DistributionPosterioriSPP']};
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