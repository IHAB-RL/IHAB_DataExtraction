% script to analyse the distribution of the RMS of correlation (magnitude
% feature by Basti Bechtold)
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 08-Nov-2019  JP

clear;
% close all;

% choose between data from Bilert or Schreiber or Pohlhausen
isBilert = 1;
isSchreiber = 0;

% path to main data folder (needs to be customized)
if isBilert
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
    
    % number of first and last noise configuration
    nConfig = [1; 6];
    
    % labels of all noise configurations
    vLabels = {'Ruhe';'40 dB(A)';'50 dB(A)';'60 dB(A)';'65 dB(A)';'70 dB(A)'};
    
    % define maximum number of blocks
    nBlocksMax = 5*60/0.125; % 5 minutes recorded frames a 0.125 ms
    
elseif isSchreiber
    obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
    
    % number of first and last noise configuration
    nConfig = [0; 7];
    
    % labels of all noise configurations
    vLabels = {'friend';'car+friend';'car+friend';'kitchen';'conv.+music';'canteen';'silence';'canteen'};
    
    % define maximum number of blocks
    nBlocksMax = 25*60/0.125; % 25 minutes recorded frames a 0.125 ms
else
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
    
    % number of first and last noise configuration
    nConfig = [1; 3];
    
    % labels of all noise configurations
    vLabels = {'office';'canteen';'by foot'};
    
    % define maximum number of blocks
    nBlocksMax = 25*60/0.125; % 25 minutes recorded frames a 0.125 ms
    
end

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% number of subjects
nSubject = size(subjectDirectories, 1);

% preallocate result matrix
nValuesMax = nSubject * nBlocksMax;
mCorrRMSOVS = NaN(nValuesMax, nConfig(2));
mCorrRMSFVS = NaN(nValuesMax, nConfig(2));
mCorrRMSNone = NaN(nValuesMax, nConfig(2));

nCountVS = zeros(nConfig(2), nSubject, 3);

% loop over all noise configurations
for config = nConfig(1):nConfig(2)
    % choose noise configurations
    obj.szNoiseConfig = ['config' num2str(config)];
    
    StartIdx = ones(3,1);
    % loop over all subjects
    for subj = 1:nSubject
        
        % choose one subject directoy
        obj.szCurrentFolder = subjectDirectories(subj).name;
        
        % load analysed data
        szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep 'Pitch' filesep 'PeaksMatFiles'];
        szFile = ['CorrelationRMS_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
        
        if exist([szDir filesep szFile '.mat'], 'file')
            load([szDir filesep szFile], 'CorrRMS_OVS', 'CorrRMS_FVS', 'CorrRMS_None');
            
            % count number of specific voice sequences
            nCountVS(config, subj, 1) = size(CorrRMS_OVS,1);
            nCountVS(config, subj, 2) = size(CorrRMS_FVS,1);
            nCountVS(config, subj, 3) = size(CorrRMS_None,1);
            
            
            % construct matrix with pooled data
            mCorrRMSOVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = CorrRMS_OVS;
            mCorrRMSFVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = CorrRMS_FVS;
            mCorrRMSNone(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = CorrRMS_None;
            
            % adjust index
            StartIdx(1) = StartIdx(1) + nCountVS(config, subj, 1);
            StartIdx(2) = StartIdx(2) + nCountVS(config, subj, 2);
            StartIdx(3) = StartIdx(3) + nCountVS(config, subj, 3);
            
            clear CorrRMS_OVS CorrRMS_FVS CorrRMS_None
        end
    end
    
end

% get maximum of number of peak values
nPeakValues = max(max(sum(nCountVS(:, :, :), 2)));

% adjust peak vectors to one length
mCorrRMSOVS(nPeakValues+1:end, :) = [];
mCorrRMSFVS(nPeakValues+1:end, :) = [];
mCorrRMSNone(nPeakValues+1:end, :) = [];


% %% GroupedBoxplot(mCorrRMSOVS, mCorrRMSFVS, mCorrRMSNone, [nPeakValues config])
hFig = figure;
subplot(1,3,1);
boxplot(mCorrRMSOVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
title('RMS Correlation at OVS');
xlabel('noise configuration');
ylabel('RMS Correlation');
ylim([0 650]);

subplot(1,3,2);
boxplot(mCorrRMSFVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
title('RMS Correlation at FVS');
xlabel('noise configuration');
ylabel('RMS Correlation');
ylim([0 650]);

subplot(1,3,3);
boxplot(mCorrRMSNone,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
title('RMS Correlation at no VS');
xlabel('noise configuration');
ylabel('RMS Correlation');
ylim([0 650]);



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