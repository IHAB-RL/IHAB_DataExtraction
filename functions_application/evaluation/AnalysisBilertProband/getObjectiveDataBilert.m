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


% List all feat files
AllFeatFiles = listFiles(obj.szDir,'*.feat');
AllFeatFiles = {AllFeatFiles.name}';

if isempty(AllFeatFiles)
    return;
end

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
    [~,~,stInfoFile]=LoadFeatureFileDroidAlloc([obj.szDir filesep AllFeatFiles{1}]);
    
    % number of time frames
    if strcmp(szFeature, 'PSD')
        nFrames = stInfoFile.nFrames - 1;
    else
        nFrames = stInfoFile.nFrames;
    end
    
    % pre-allocation of output arguments
    Data = repmat(zeros(nFrames,stInfoFile.nDimensions-2),length(dateVecAll),1);
    TimeVec = datetime(zeros(length(dateVecAll)*nFrames,1),...
        zeros(length(dateVecAll)*nFrames,1),...
        zeros(length(dateVecAll)*nFrames,1));
    
    % loop over each feature file
    Startindex = 1;
    for fileIdx = 1:NrOfFiles
        
        szFileName =  AllFeatFiles{fileIdx};
        
        % load data from feature file
        [FeatData, ~,stInfo] = LoadFeatureFileDroidAlloc([obj.szDir filesep szFileName]);
        
        % number of current time frames
        if strcmp(szFeature, 'PSD')
            nCurrentFrames = stInfo.nFrames - 1;
        else
            nCurrentFrames = stInfo.nFrames;
        end
        
        if nCurrentFrames < nFrames
            % sometimes the last recorded feature file contains fewer values
            Data(Startindex:Startindex+nCurrentFrames-1,:) = FeatData(1:nCurrentFrames,:);
            
            Data(Startindex+nCurrentFrames:end,:) = [];
            
            % calculate time vector
            DateTimeValue = dateVecAll(fileIdx);
            TimeVec(Startindex:Startindex+nCurrentFrames-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/nCurrentFrames),nCurrentFrames);
            
            TimeVec(Startindex+nCurrentFrames:end) = [];
        else
            
            Data(Startindex:Startindex+nFrames-1,:) = FeatData(1:nFrames,:);
            
            % calculate time vector
            DateTimeValue = dateVecAll(fileIdx);
            TimeVec(Startindex:Startindex+nFrames-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/nFrames),nFrames);
        end
        
        Startindex = Startindex + nFrames;
    end
    
    
    
    % compression
    if isfield(obj, 'isCompression')
        % set parameters for data compression
        stControl.DataPointOverlap_percent = 0;
        stControl.szTimeCompressionMode = 'mean';
        stControl.DataPointRepresentation_s = 0.125;
        
        % new number of frames per minute
        nFrames = floor(nFrames/10);
        
        nRemain = rem(size(Data, 1), 10*nFrames);
        if nRemain ~= 0
            Data(end-nRemain+1:end, :) = [];
            TimeVec(end-nRemain+1:end) = [];
        end
        stControl.DataLen_min = size(Data, 1)/(10*nFrames);
        stControl.DataLen_s = stControl.DataLen_min*60;
        stControl.NrOfDataPoints = stControl.DataLen_min * nFrames;
        
        [Data, TimeVec] = DataCompactor(Data, TimeVec, stControl);
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