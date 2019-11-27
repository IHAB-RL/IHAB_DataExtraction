% Script to evaluate performance of OVD with Random Forest
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% analog: EvaluatePerformanceOVDPitch.m
% Version History:
% Ver. 0.01 initial create (empty) 25-Nov-2019 JP
% Ver. 1.0 added FVD 27-Nov-2019 JP

clear;

% choose mode of voice detection: OVD || FVD
szMode = 'FVD';

% choose test data
mConfig.SB = 1:6;
mSubj.SB = [3 6 8];
mConfig.OD = {'CAR', 'CITY', 'STREET'};
mConfig.NS = [2 4 6];
mConfig.JP = [1 2 3 5];

% total number of measurement configuartions
nTotalConfigs = numel(mConfig.SB) * numel(mSubj.SB) + numel(mConfig.OD) + numel(mConfig.NS) + numel(mConfig.JP);

% set condition
if strcmp(szMode, 'OVD')
    szCondition = 'OVD_RandomForest_';
    
    % set labels, OVS == 1
    vUniqueNums = [0 1];
    
    % load trained random forest (cave!)
    load('EnsembleTrees', 'RandomForest_OVD', 'szVarNames');
    RandomForest = RandomForest_OVD;
    
else
    szCondition = 'FVD_RandomForest_';
    
    % set labels, FVS == 2
    vUniqueNums = [0 2];
    
    % load trained random forest (cave!)
    load('EnsembleTrees', 'RandomForest_FVD', 'szVarNames');
    RandomForest = RandomForest_FVD;
end


% loop through data from Bilert, Schreiber, Pohlhausen
vMeasurement = {'PROBAND', 'OUTDOOR', 'Schreiber', 'Pohlhausen'};

for ii = 1:length(vMeasurement)
    
    % make sure there is no obj in workspace
    clear obj
    
    switch vMeasurement{ii}
        case 'PROBAND'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
            
            % number of configs
            nConfigs = numel(mConfig.SB);
            
        case 'OUTDOOR'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\OUTDOOR';
            
            % number of configs
            nConfigs = numel(mConfig.OD);
            
        case 'Schreiber'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
            
            % number of configs
            nConfigs = numel(mConfig.NS);
            
        case 'Pohlhausen'
            % path to main data folder (needs to be customized)
            obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
            
            % number of configs
            nConfigs = numel(mConfig.JP);
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
        
        % empty struct for subjects
        mSubject = struct('SB', []);
        if strcmp(vMeasurement{ii}, 'PROBAND')
            mSubject.SB = mSubj.SB(subj);
        end
        
        % loop over all noise configurations
        for config = 1:nConfigs
            
            % empty struct for measurement configurations
            mConfiguration = struct('SB', [], 'OD', [], 'NS', [], 'JP', []);
            
            % get only one measurement configuration per loop
            switch vMeasurement{ii}
                case 'PROBAND'
                    mConfiguration.SB = mConfig.SB(config);
                    obj.szNoiseConfig = ['config' num2str(mConfig.SB(config))];
                case 'OUTDOOR'
                    mConfiguration.OD = mConfig.OD(config);
                    obj.szNoiseConfig = mConfig.OD{config};
                case 'Schreiber'
                    mConfiguration.NS = mConfig.NS(config);
                    obj.szNoiseConfig = ['config' num2str(mConfig.NS(config))];
                case 'Pohlhausen'
                    mConfiguration.JP = mConfig.JP(config);
                    obj.szNoiseConfig = ['config' num2str(mConfig.JP(config))];
            end
            
            % build the full directory
            if isfield(obj, 'szCurrentFolder')
                szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
                
                szFile = [szCondition obj.szCurrentFolder '_'  obj.szNoiseConfig];
            else
                szDir = obj.szBaseDir;
                
                szFile = [szCondition obj.szNoiseConfig];
            end
            
            % create test data set
            isTraining = false;
            [mTestDataSet, vGroundTruthVS] = createTestSet(szVarNames, isTraining, szMode, mConfiguration, mSubject);
            
            % start prediction with trained ensemble of bagged classification trees
            vPredictedVS = predict(RandomForest, mTestDataSet);
            vPredictedVS = str2num(cell2mat(vPredictedVS));
            
            fBeta = 2;
            if strcmp(szMode, 'OVD')
                
                % calculate and plot confusion matrix for VD
                stResults.mConfusion_Pitch = getConfusionMatrix(vPredictedVS, vGroundTruthVS, vUniqueNums);
                
                % calculate F2-Score, precision and recall
                [stResults.F2ScoreOVS_Pitch,stResults.precOVS_Pitch,...
                    stResults.recOVS_Pitch,stResults.accOVS_Pitch] = F1M(vPredictedVS, vGroundTruthVS, fBeta);
                
                szFolder_Output = [szDir filesep 'Pitch' filesep 'OVDPitchMatFiles'];
            else
                
                % calculate and plot confusion matrix for VD
                stResults.mConfusion = getConfusionMatrix(vPredictedVS, vGroundTruthVS, vUniqueNums);
                
                % set 2 to 1
                vPredictedVS(vPredictedVS == 2) = 1;
                vGroundTruthVS(vGroundTruthVS == 2) = 1;
                
                % calculate F2-Score, precision and recall
                [stResults.F2ScoreFVS,stResults.precFVS, ...
                    stResults.recFVS,stResults.accFVS] = F1M(vPredictedVS, vGroundTruthVS, fBeta);
                
                szFolder_Output = [szDir filesep 'Pitch' filesep 'FVDMatFiles'];
            end
            
            
            if ~exist(szFolder_Output, 'dir')
                mkdir(szFolder_Output);
            end
            
            % save results as mat file
            save([szFolder_Output filesep szFile], 'stResults');
            
        end
    end
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