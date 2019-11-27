% Script to do something usefull (fill out)
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% run first: EvaluatePerformanceFVD.m and VD_RandomForest_TestData.m
% Version History:
% Ver. 0.01 initial create (empty) 25-Nov-2019 JP

    
% choose test data
mConfig.SB = 1:6;
mSubj.SB = [3 6 8];
mConfig.OD = {'CAR', 'CITY', 'STREET'};
mConfig.NS = [2 4 6];
mConfig.JP = [1 2 3 5];

% total number of measurement configuartions
nTotalConfigs = numel(mConfig.SB) * numel(mSubj.SB) + numel(mConfig.OD) + numel(mConfig.NS) + numel(mConfig.JP);

% preallocate confusion matrices etc and counter variable
mConfusion = zeros(2,2);
mF2Score = zeros(nTotalConfigs,1);
mPrecision = zeros(nTotalConfigs,1);
mRecall = zeros(nTotalConfigs,1);
mAccuracy = zeros(nTotalConfigs,1);
counter = 1;

% set FVD
% szCondition = 'FVD_Schreiber2019_';
% szCondition = 'FVD_Schreiber2019_pureFVS_';
% szCondition = 'FVD_AllwaysTrue_';
% szCondition = 'FVD_AllwaysFalse_';
szCondition = 'FVD_RandomForest_';


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
                szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep 'Pitch' filesep 'FVDMatFiles'];
                
                szFile = [szCondition obj.szCurrentFolder '_'  obj.szNoiseConfig];
            else
                szDir = [obj.szBaseDir filesep 'Pitch' filesep 'FVDMatFiles'];
                
                szFile = [szCondition obj.szNoiseConfig];
            end
            
            % load results from mat file
            load([szDir filesep szFile]);
            
            % append values
            mConfusion = mConfusion + stResults.mConfusion;
            
            mF2Score(counter) = stResults.F2ScoreFVS;
            mPrecision(counter) = stResults.precFVS;
            mRecall(counter) = stResults.recFVS;
            mAccuracy(counter) = stResults.accFVS;
            
            counter = counter + 1;
        end
    end
end

% call function to plot confusion matrix for all subjects and configs
vLabels = {'no FVS', 'FVS'};
[hFig] = plotConfusionMatrix(mConfusion, vLabels, strrep(szCondition, '_', ' '));

% calculate accuracy
accuracy = sum(diag(mConfusion))/sum(mConfusion(:));
% F2Score
F2Score = F1M([],[], 2, mConfusion(2,2)/(mConfusion(2,2)+mConfusion(2,1)), mConfusion(2,2)/(mConfusion(2,2)+mConfusion(1,2)));

% save figure
szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Results';
exportName = [szDir filesep 'ConfMatrix_' szCondition 'TestDataRF'];
savefig(hFig, exportName);

% save results as matfile
szFile = ['ResultScores_' szCondition 'TestDataRF'];
save([szDir filesep szFile], 'mConfusion', 'mF2Score', 'mPrecision', 'mRecall', 'mAccuracy');

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