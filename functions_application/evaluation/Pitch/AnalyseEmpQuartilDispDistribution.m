% script to analyse the distribution of the Empirischer 
% Quartilsdispersionskoeffizient of correlation (magnitude feature by Basti 
% Bechtold)
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
    vLabels = {'CAR+friend';'car+friend';'kitchen';'conv.+music';'canteen';'silence';};
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
mEmpQuartilDispOVS = NaN(nValuesMax, nConfig(2));
mEmpQuartilDispFVS = NaN(nValuesMax, nConfig(2));
mEmpQuartilDispNone = NaN(nValuesMax, nConfig(2));

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
            
            szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep 'Pitch' filesep 'PeaksMatFiles'];
            
            szFile = ['EmpQuartilDisp_PP_Cxy_scaled_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
        else
            szDir = [obj.szBaseDir filesep 'Pitch' filesep 'PeaksMatFiles'];
            
            szFile = ['EmpQuartilDisp_PP_Cxy_scaled_'  obj.szNoiseConfig];
        end
        
        
        if exist([szDir filesep szFile '.mat'], 'file')
            load([szDir filesep szFile], 'EmpQuartilDisp_OVS', 'EmpQuartilDisp_FVS', 'EmpQuartilDisp_None');
            
            % count number of specific voice sequences
            nCountVS(config, subj, 1) = size(EmpQuartilDisp_OVS,2);
            nCountVS(config, subj, 2) = size(EmpQuartilDisp_FVS,2);
            nCountVS(config, subj, 3) = size(EmpQuartilDisp_None,2);
            
            
            % construct matrix with pooled data
            mEmpQuartilDispOVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = EmpQuartilDisp_OVS;
            mEmpQuartilDispFVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = EmpQuartilDisp_FVS;
            mEmpQuartilDispNone(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = EmpQuartilDisp_None;
            
            % adjust index
            StartIdx(1) = StartIdx(1) + nCountVS(config, subj, 1);
            StartIdx(2) = StartIdx(2) + nCountVS(config, subj, 2);
            StartIdx(3) = StartIdx(3) + nCountVS(config, subj, 3);
            
            clear EmpQuartilDisp_OVS EmpQuartilDisp_FVS EmpQuartilDisp_None
        end
    end
    
end

% get maximum of number of peak values
nPeakValues = max(max(sum(nCountVS(:, :, :), 2)));

% adjust peak vectors to one length
mEmpQuartilDispOVS(nPeakValues+1:end, :) = [];
mEmpQuartilDispFVS(nPeakValues+1:end, :) = [];
mEmpQuartilDispNone(nPeakValues+1:end, :) = [];


% %% GroupedBoxplot(mEmpQuartilDispOVS, mEmpQuartilDispFVS, mEmpQuartilDispNone, [nPeakValues config])
hFig = figure;
subplot(1,3,1);
boxplot(mEmpQuartilDispOVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
title('EmpQuartilDisp at OVS');
xlabel('noise configuration');
ylabel('EmpQuartilDisp');
ylim([-100 100]);

subplot(1,3,2);
boxplot(mEmpQuartilDispFVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
title('EmpQuartilDisp at FVS');
xlabel('noise configuration');
ylabel('EmpQuartilDisp');
ylim([-100 100]);

subplot(1,3,3);
boxplot(mEmpQuartilDispNone,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
title('EmpQuartilDisp at no VS');
xlabel('noise configuration');
ylabel('EmpQuartilDisp');
ylim([-100 100]);


% logical to save figure
bPrint = 1;
if bPrint
    szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Distribution';
    
    exportName = {[szDir filesep 'DistributionEmpQuartilDispMagnitudeFeature']};
    if isSchreiber
        exportName = strcat(exportName, '_NS');
    elseif isOutdoor
        exportName = strcat(exportName, '_OD');
    elseif ~isBilert
        exportName = strcat(exportName, '_JP');
    end
    
    savefig(hFig, exportName{1});
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