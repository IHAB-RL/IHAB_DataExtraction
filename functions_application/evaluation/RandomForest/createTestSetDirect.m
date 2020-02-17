function [mDataSet,vVoiceLabels]=createTestSetDirect(szVarNames, isTraining, szMode, szSpecificFile)
% function to create a DATA Set with specified variables for classification
% works like createTestSet.m but for the recordings in the Gesture lab
% run first FeatureExtractionTestSet.m
% Usage [mDataSet,vVoiceLabels]=createTestSetDirect(szVarNames, isTraining, szMode, szSpecificFile)
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
%   szMode - optional string that specifies voice detection: 'OVD', 'FVD';
%            by default as well own as further voices are classified
% 
%   szSpecificFile - optional string that defines a specific audiofile
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
end

% build the full directory (needs to be customized)
szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\GestureLab\MixedSignals\FeatureExtraction';

% get all filenames
AllFiles = listFiles(szDir, '*.mat');
AllFiles = {AllFiles.name}';

% select training and test files dependent on SNR
if isTraining
%     useSNR = {'_0'; '_20'};
%     useSNR = {'_15'};
    useSNR = {'_10'};
else
%     useSNR = {'_5'; '_10'; '_15'};
%     useSNR = {'_10'; '_20'};
    useSNR = {'_5'; '_15'};
end

if nargin == 4
    AllFiles = {[szDir filesep szSpecificFile]};
end


% preallocate output data set
mDataSet = zeros(1, length(szVarNames));

% set row index
idxRow = 1;

for file = 1:numel(AllFiles)
    
    % set current feature file
    szFile = AllFiles{file};
    
    % check if current file belongs to training or test set
    if contains(szFile, useSNR)
        
        % load results from mat file
        load(szFile, szVarNames{:});
        
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


if ~exist('szMode', 'var')
    szMode = [];
end

% only OVD
if strcmp(szMode, 'OVD')
    vVoiceLabels(vVoiceLabels == 2) = 0;
    % only FVD
elseif strcmp(szMode, 'FVD')
    vVoiceLabels(vVoiceLabels == 1) = 0;
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