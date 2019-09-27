function [Data,TimeVec,stInfo]=getObjectiveData(obj,szFeature,varargin)
% function to load objective data of one day for one test subject
% Usage [Data,TimeVec]=getObjectiveDataOneDay(szTestSubject,desiredDay, szFeature)
%
% Parameters
% ----------
% obj : struct, containing all informations
%
% varargin :  specifies optional parameter name/value pairs.
%             getObjectiveData(obj 'PARAM1', val1, 'PARAM2', val2, ...)
%     'StartTime'    duration to specify the start time of desired data
%                    syntax duration(H,MI,S)
%
%     'EndTime'      duration to specify the end time of desired data
%                    syntax duration(H,MI,S)
%
%     'StartDay'     to specify the start day of desired data, allowed
%                    formats are datetime, numeric (i.e. 1 for day one),
%                    char (i.e. 'last')
%
%     'EndDay'      to specify the end day of desired data, allowed
%                   formats are datetime, numeric (i.e. 1 for day one),
%                   char (i.e. 'last')
%
% Returns
% -------
% Data :  a matrix containg the feature data
%
% TimeVec :  a date/time vector with the corresponding time information
%
% stInfo : a struct containg infos about the feature files, e.g. fs, sample
%          size
%
% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Source: the function is based on getObjectiveDataOneDay.m
% Version History:
% Ver. 0.01 initial create (empty) 15-May-2017  Initials JB
% Ver. 1.0 object-based version, new input 26-Sept-2019 JP

% preallocate output paramters
Data = [];
TimeVec = [];

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isa(x,'IHABdata') && ~isempty(x));

p.addParameter('StartTime', 0, @(x) isduration(x) || isnumeric(x));
p.addParameter('EndTime', 24, @(x) isduration(x) || isnumeric(x));
p.addParameter('StartDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('EndDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.parse(obj,varargin{:});

% Re-assign values
StartTime = p.Results.StartTime;
EndTime = p.Results.EndTime;
StartDay = p.Results.StartDay;
EndDay = p.Results.EndDay;

% preallocate struct for date values
stInfo = struct('StartTime', [], 'EndTime', [], 'StartDay', [], 'EndDay', []);

% check time input parameters format
if ~isduration(StartTime) && StartTime >= 0 && StartTime <= 24
    stInfo.StartTime = duration(StartTime,0,0);
else
    stInfo.StartTime = StartTime;
end

if ~isduration(EndTime) && EndTime >= 0 && EndTime <= 24
    stInfo.EndTime = duration(EndTime,0,0);
else
    stInfo.EndTime = EndTime;
end

% check time input parameters plausibility
if stInfo.StartTime > stInfo.EndTime
    error('input EndTime must be greater than input StartTime');
end


% get all dates of one subject
caDates = getdatesonesubject(obj);

% check day input parameters format
if isdatetime(StartDay)
    if ~isnat(StartDay)
        stInfo.StartDay = StartDay;
    else
        stInfo.StartDay = caDates(1);
    end
    
elseif isnumeric(StartDay)
    
    if StartDay == -1 % i.e. get all days
        stInfo.StartDay = caDates(1);
        stInfo.EndDay = caDates(end);
        
    elseif StartDay <= length(caDates)
        stInfo.StartDay = caDates(StartDay);
        
    else
        error('input StartDay has an invalid value');
    end
    
elseif ischar(StartDay)
    
    switch StartDay
        case 'first'
            stInfo.StartDay = caDates(1);
        case 'last'
            stInfo.StartDay = caDates(end);
        case 'all'
            stInfo.StartDay = caDates(1);
            stInfo.EndDay = caDates(end);
    end
end


if isempty(stInfo.EndDay)
    if isdatetime(EndDay)
        if ~isnat(EndDay)
            stInfo.EndDay = EndDay;
        elseif isnat(EndDay) && isnat(StartDay)
            % if EndDay and StartDay are not assigned, StartDay = first day
            % EndDay = last day
            stInfo.EndDay = caDates(end);
        else
            % if EndDay is not assigned, EndDay = StartDay
            stInfo.EndDay = stInfo.StartDay;
        end
        
    elseif isnumeric(EndDay)
        
        if EndDay == -1 % i.e. get all days
            stInfo.StartDay = caDates(1);
            stInfo.EndDay = caDates(end);
            
        elseif EndDay <= length(caDates)
            stInfo.EndDay = caDates(EndDay);
            
        else
            error('input EndDay has an invalid value');
        end
        
    elseif ischar(EndDay)
        
        switch EndDay
            case 'first'
                stInfo.EndDay = caDates(1);
            case 'last'
                stInfo.EndDay = caDates(end);
            case 'all'
                stInfo.StartDay = caDates(1);
                stInfo.EndDay = caDates(end);
        end
    end
end

% check day input parameters plausibility
if stInfo.StartDay > stInfo.EndDay
    error('input EndDay must be greater than input StartDay ');
end


% check if the day has objective data
% build the full directory
szDir = [obj.stSubject.Folder filesep obj.stSubject.Name '_AkuData'];

% List all feat files
AllFeatFiles = listFiles(szDir,'*.feat');
AllFeatFiles = {AllFeatFiles.name}';

% Get names wo. path
[~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);

% Append '.feat' extension for comparison to corrupt file names
AllFeatFiles = strcat(AllFeatFiles,'.feat');

% Load txt file with corrupt file names
corruptTxtFile = fullfile(obj.stSubject.Folder,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(obj.stSubject.Folder);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);

% Textscan stores all lines into one cell array, so you need to unpack it
corruptFiles = corruptFiles{:};

% Delete names of corrupt files from the list with all feat file names
[featFilesWithoutCorrupt, ia] = setdiff(AllFeatFiles,corruptFiles,'stable');

% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,isFeatFile] = Filename2date(featFilesWithoutCorrupt,szFeature);

% Also filter the corresponding file list
featFilesWithoutCorrupt = featFilesWithoutCorrupt(logical(isFeatFile));

% split dateVecAll into times and dates
timeVecAll = timeofday(dateVecAll);
dateVecDayOnly = dateVecAll - timeVecAll;

% check for dates in desired start-end day interval
idxDay = dateVecDayOnly >= stInfo.StartDay & dateVecDayOnly <= stInfo.EndDay;

% read the data
if ~isempty(idxDay)
    % filter for desired start and end day
    dateVecAll(~idxDay) = [];
    timeVecAll(~idxDay) = [];
    featFilesWithoutCorrupt(~idxDay) = [];
    
    % check for times in desired start-end time interval
    idxTime = timeVecAll >= stInfo.StartTime & timeVecAll <= stInfo.EndTime;
    
    % filter for desired start and end time
    featFilesWithoutCorrupt(~idxTime) = [];
    
    % pre-allocation
    if ~isempty(featFilesWithoutCorrupt)
        [FeatData, ~,stInfo]= LoadFeatureFileDroidAlloc([szDir filesep featFilesWithoutCorrupt{1}]);
        AssumedBlockSize = size(FeatData,1);

        Data = repmat(zeros(AssumedBlockSize,size(FeatData,2)),length(dateVecAll),1);
        TimeVec = datetime(zeros(length(dateVecAll)*(AssumedBlockSize),1),...
            zeros(length(dateVecAll)*(AssumedBlockSize),1),...
            zeros(length(dateVecAll)*(AssumedBlockSize),1));

        Startindex = 1;
        for fileIdx = 1:numel(featFilesWithoutCorrupt)
            szFileName =  featFilesWithoutCorrupt{fileIdx};
            [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep szFileName]);
            ActBlockSize = size(FeatData,1);
            DateTimeValue = dateVecAll(fileIdx);
            TimeVec(Startindex:Startindex+ActBlockSize-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/ActBlockSize),ActBlockSize);
            Data(Startindex:Startindex+ActBlockSize-1,:) = FeatData(1:ActBlockSize,:);
            Startindex = Startindex + ActBlockSize;
        end
        
    else
        warning('For the given input day and time no feature files exist!');
    end
    
else
    
    return;
    
end


%--------------------Licence ---------------------------------------------
% Copyright (c) <2017> J.Bitzer
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