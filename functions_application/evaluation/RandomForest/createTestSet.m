function [mDataSet,vVoiceLabels]=createTestSet(szVarNames, isTraining, isOnlyOVD)
% function to create a DATA Set with specified variables for classification
% requi
% Usage [mDataSet]=createTestSet(vVarNames, isTraining)
%
% Parameters
% ----------
%   szVarNames - cell array, contains the variable names; by default all
%                variables are selected: RMS, ZCR, mean real coherence, 
%                speech presence probability, EQD, CorrRMS, Pxx, Cxy,
%                ground truth labels
% 
%   isTraining - logical, whether the training or test data set should be
%                created; by default true
%
% Returns
% -------
%   mDataSet   - matrix, contains the data set for specified variables
%
%   vVoiceLabels - vector with ground truth voice labels; 
%                  1 == OVS, 2 == FVS, 0 == no VS
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 20-Nov-2019  JP

% set variable names (if not specified, take all)
if nargin == 0 
    szVarNames = {'mRMS', 'mZCR', 'mMeanRealCoherence', 'mMeanSPP', ...
        'mEQD', 'mCorrRMS', 'Pxx', 'Cxy', 'mfcc', 'vGroundTruthVS'};
    
    isTraining = true;
    
    isOnlyOVD = false;
end

% choose data
if isTraining
    % training data
    mConfig.SB = 1:6;
    mSubj.SB = [1 2 4 5 7];
    mConfig.OD = {'COFFEE'};
    mConfig.NS = [1 3 5];
    mConfig.JP = [4 5];
else
    % test data
    mConfig.SB = 1:6;
    mSubj.SB = [3 6 8];
    mConfig.OD = {'CAR', 'CITY', 'STREET'};
    mConfig.NS = [2 4 6];
    mConfig.JP = [1 2 3];
end

% preallocate output data set
mDataSet = zeros(1, length(szVarNames));

% set row index
idxRow = 1;


% loop through data from Bilert, Schreiber, Pohlhausen
vMeasurement = {'PROBAND', 'OUTDOOR', 'Schreiber', 'Pohlhausen'};

for ii = 1:length(vMeasurement)
    
    % make sure there is no obj in workspace
    clear obj
    
    switch vMeasurement{ii}
        case 'PROBAND'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
            
            % set config list
            vConfig = mConfig.SB;
            
        case 'OUTDOOR'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\OUTDOOR';
            
            % set config list
            vConfig = mConfig.OD;
            
        case 'Schreiber'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
            
            % set config list
            vConfig = mConfig.NS;
            
        case 'Pohlhausen'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
            
            % set config list
            vConfig = mConfig.JP;
    end
    
    
    % get all subject directories
    subjectDirectories = dir(obj.szBaseDir);
    
    % sort for correct subjects
    isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
    subjectDirectories = subjectDirectories(isValidLength);
    isDirectory = arrayfun(@(x)(x.isdir == 1), subjectDirectories);
    subjectDirectories = subjectDirectories(isDirectory);
    
    % if there are more than one test subject, select
    if strcmp(vMeasurement{ii}, 'PROBAND')
        subjectDirectories = subjectDirectories(mSubj.SB);
    end
    
    % number of subjects
    nSubject = max(size(subjectDirectories, 1), 1);
    
    
    % loop over all subjects
    for subj = 1:nSubject
        
        % choose one subject directoy
        if ~isempty(subjectDirectories)
            obj.szCurrentFolder = subjectDirectories(subj).name;
        end
        
        % loop over all noise configurations
        for config = 1:length(vConfig)
            
            % choose noise/ measurement configuration
            if strcmp(vMeasurement{ii}, 'OUTDOOR')
                obj.szNoiseConfig = vConfig{config};
            else
                obj.szNoiseConfig = ['config' num2str(vConfig(config))];
            end
            
            % build the full directory
            if isfield(obj, 'szCurrentFolder')
                szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep 'FeatureExtraction'];
                
                szFileEnd = [obj.szCurrentFolder '_'  obj.szNoiseConfig];
            else
                szDir = [obj.szBaseDir filesep 'FeatureExtraction'];
                
                szFileEnd = obj.szNoiseConfig;
            end
            
            % load results from mat file
            szFile = ['Features_' szFileEnd];
            load([szDir filesep szFile], szVarNames{:});
            
            
            % set column index
            idxColumn = 1;
            
            % add variables to data set
            for iVar = 1:length(szVarNames)
                
                % save temporary current variable
                mTemp = real(eval(szVarNames{iVar}));
                
                % current number of blocks
                nBlocks = size(mTemp, 1);
                
                % current dimension
                nDim = size(mTemp, 2);
                
                % append
                if strcmp(szVarNames{iVar}, 'vGroundTruthVS')
                    vVoiceLabels(idxRow:idxRow+nBlocks-1, :) = mTemp;
                else
                    mDataSet(idxRow:idxRow+nBlocks-1, idxColumn:idxColumn+nDim-1) = mTemp;
                end
                % adjust column index
                idxColumn = idxColumn + nDim;
            end
            
            % adjust row index
            idxRow = idxRow + nBlocks;
        end
    end
end

% only OVD
if isOnlyOVD
    vVoiceLabels(vVoiceLabels == 2) = 0;
end

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