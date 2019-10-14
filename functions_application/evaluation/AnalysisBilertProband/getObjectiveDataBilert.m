function [Data,TimeVec,stInfoFile]=getObjectiveDataBilert(obj,szFeature)
% function to load objective data of one test subject
% Usage [Data,TimeVec,stInfoFile]=getObjectiveDataOneDay(obj,szFeature,varargin)
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% szFeature : string, specifies which feature data should be read in
%             possible: 'PSD', 'RMS', 'ZCR'
%
% Returns
% -------
% Data :  a matrix containg the feature data
%
% TimeVec :  a date/time vector with the corresponding time information
%
% stInfoFile : a struct containg infos about the feature files, e.g. fs,
%              frame size in samples...
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: the function is based on getObjectiveData.m
% Version History:
% Ver. 0.01 initial create 14-Oct-2019  JP

% preallocate output parameters
Data = [];
TimeVec = [];
stInfoFile = [];

% check for valid feature data
vFeatureNames = {'RMS', 'PSD', 'ZCR'};
szFeature = upper(szFeature); % convert to uppercase characters
if ~any(strcmp(vFeatureNames,szFeature))
    error('input feature string should be RMS, PSD or ZCR');
end

% parse input arguments
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isstruct(x) && ~isempty(x));
p.parse(obj);

% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

% List all feat files
AllFeatFiles = listFiles(szDir,'*.feat');
AllFeatFiles = {AllFeatFiles.name}';

% Get names wo. path
[~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);

% Append '.feat' extension for comparison to corrupt file names
AllFeatFiles = strcat(AllFeatFiles,'.feat');

% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,isFeatFile] = Filename2date(AllFeatFiles,szFeature);

% Also filter the corresponding file list
AllFeatFiles = AllFeatFiles(logical(isFeatFile));


%% read the data

% get number of available feature files in current time frame
NrOfFiles = numel(AllFeatFiles);

if ~isempty(AllFeatFiles)
    
    % get infos about feature file for pre-allocation
    [~,~,stInfoFile]=LoadFeatureFileDroidAlloc([szDir filesep AllFeatFiles{1}]);
    
    
    % pre-allocation of output arguments
    Data = repmat(zeros(stInfoFile.nFrames,stInfoFile.nDimensions-2),length(dateVecAll),1);
    TimeVec = datetime(zeros(length(dateVecAll)*stInfoFile.nFrames,1),...
        zeros(length(dateVecAll)*stInfoFile.nFrames,1),...
        zeros(length(dateVecAll)*stInfoFile.nFrames,1));
    
    % loop over each feature file
    Startindex = 1;
    for fileIdx = 1:NrOfFiles
        
        szFileName =  AllFeatFiles{fileIdx};
        
        % load data from feature file
        [FeatData, ~,stInfo] = LoadFeatureFileDroidAlloc([szDir filesep szFileName]);
        
        if stInfo.nFrames < stInfoFile.nFrames
            % sometimes the last recorded feature file contains fewer values
            Data(Startindex:Startindex+stInfo.nFrames-1,:) = FeatData(1:stInfo.nFrames,:);
            
            Data(Startindex+stInfo.nFrames:end,:) = [];
            
            % calculate time vector
            DateTimeValue = dateVecAll(fileIdx);
            TimeVec(Startindex:Startindex+stInfo.nFrames-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/stInfo.nFrames),stInfo.nFrames);
            
            TimeVec(Startindex+stInfo.nFrames:end) = [];
        else
            Data(Startindex:Startindex+stInfoFile.nFrames-1,:) = FeatData(1:stInfoFile.nFrames,:);
            
            % calculate time vector
            DateTimeValue = dateVecAll(fileIdx);
            TimeVec(Startindex:Startindex+stInfoFile.nFrames-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/stInfoFile.nFrames),stInfoFile.nFrames);
        end
        
        Startindex = Startindex + stInfoFile.nFrames;
    end
    
end % if: ~isempty(AllFeatFiles)


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