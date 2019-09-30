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

% default plot width in pixels
iDefaultPlotWidth = 560;

% set parameters for data compression
stControl.DataPointOverlap_percent = 0;
stControl.szTimeCompressionMode = 'mean';

p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isa(x,'IHABdata') && ~isempty(x));

p.addParameter('StartTime', 0, @(x) isduration(x) || isnumeric(x));
p.addParameter('EndTime', 24, @(x) isduration(x) || isnumeric(x));
p.addParameter('StartDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('EndDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('PlotWidth', iDefaultPlotWidth, @(x) isnumeric(x));
p.parse(obj,varargin{:});

% Re-assign values
iPlotWidth = p.Results.PlotWidth;

% call function to check input date format and plausibility
stInfo = checkInputFormat(obj, p.Results.StartTime, p.Results.EndTime, ...
    p.Results.StartDay, p.Results.EndDay);

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
    dateVecAll(~idxTime)= [];
    timeVecAll(~idxTime)= [];
    
    % get number of available feature files in current time frame
    NrOfFiles = numel(featFilesWithoutCorrupt);
    
    if ~isempty(featFilesWithoutCorrupt)
        
        % set static value for data resolution
        iStaticSamplesPerPixel = 5;
        iStaticNumSamples = ceil(iStaticSamplesPerPixel*iPlotWidth);
        
        % get infos about feature file for pre-allocation
        [FeatData, ~,stInfoFile]= LoadFeatureFileDroidAlloc([szDir filesep featFilesWithoutCorrupt{1}]);
        
        % get duration in sec of one feature file (i.e. 60 sec)
        LenOneFile_s = stInfoFile.nFrames * stInfoFile.FrameSizeInSamples / stInfoFile.fs;
        LenOneFile_s = seconds(timeVecAll(end)-timeVecAll(end-1)); % equivalent
        
        % get duration in sec of all feature files
        LenAllFiles_s = LenOneFile_s * NrOfFiles;
        
        % get length in samples of all feature files
        LenAllFilesSamples = stInfoFile.nFrames * NrOfFiles;
        
        % calculate samples per pixels
        iCurrentSamplesPerPixel = ceil(LenAllFilesSamples/iPlotWidth);
        
       
        % adjust compression params
        stControl.DataPointRepresentation_s = LenAllFiles_s/iStaticNumSamples;
        
        
        %         % get size of one file in compressed format
        %         NrOfDataPoints = ceil(LenOneFile_s/(stControl.DataPointRepresentation_s*(1-stControl.DataPointOverlap_percent)));
        

        % check whether to read in feature files file based or not
        if stControl.DataPointRepresentation_s > LenOneFile_s
            isFileBased = 0;
            
            % calculate number of needed files per loop
            NrOfFilesPerLoop = ceil(stControl.DataPointRepresentation_s/LenOneFile_s);
            NrOfLoops = ceil(NrOfFiles/NrOfFilesPerLoop);
            
            disp('Loops');
        else
            isFileBased = 1;
        end
        
        
        if isFileBased
            % pre-allocation of output arguments
            NrOfDataPoints = ceil(LenOneFile_s/(stControl.DataPointRepresentation_s*(1-stControl.DataPointOverlap_percent)));

            Data = zeros(NrOfDataPoints,size(FeatData,2));
            TimeVec = datetime(zeros(NrOfDataPoints,1),...
                zeros(NrOfDataPoints,1),...
                zeros(NrOfDataPoints,1));
            
            % loop over each feature file
            Startindex = 1;
            for fileIdx = 1:NrOfFiles
                szFileName =  featFilesWithoutCorrupt{fileIdx};
                
                % load data from feature file
                [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep szFileName]);
                
                ActBlockSize = size(FeatData,1);
                
                % calculate time vector
                DateTimeValue = dateVecAll(fileIdx);
                TimeVecIn = linspace(DateTimeValue,DateTimeValue+minutes(1-1/ActBlockSize),ActBlockSize);
                
                % compression
                [DataVecComp,TimeVecComp] = DataCompactor(FeatData,TimeVecIn,stControl);
                
                ActBlockSize = size(DataVecComp,1);
                
                TimeVec(Startindex:Startindex+ActBlockSize-1) = TimeVecComp;
                Data(Startindex:Startindex+ActBlockSize-1,:) = DataVecComp(1:ActBlockSize,:);
                Startindex = Startindex + ActBlockSize;
            end
            
        else
            % pre-allocation of output arguments
            Data = zeros(iStaticNumSamples,size(FeatData,2));
            TimeVec = datetime(zeros(iStaticNumSamples,1),...
                zeros(iStaticNumSamples,1),...
                zeros(iStaticNumSamples,1));
            
            % loop over several feature files
            StartindexComp = 1;
            for LoopIdx = 1:NrOfLoops
                Startindex = 1;
                
                % catch time gaps
                DateTimeValues = dateVecAll(LoopIdx + (1:NrOfFilesPerLoop));
                DateTimeGaps = DateTimeValues(2:end) - DateTimeValues(1:end-1);
                
                if any(DateTimeGaps > LenOneFile_s)
                    disp('Achtung');
                end
                
                for fileIdx = 1:NrOfFilesPerLoop
                    szFileName =  featFilesWithoutCorrupt{LoopIdx+fileIdx-1};

                    % load data from feature file
                    [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep szFileName]);

                    ActBlockSize = size(FeatData,1);
                    
                    FeatDataTemp(Startindex:Startindex+ActBlockSize-1,:) = FeatData;

                    % calculate time vector
                    DateTimeValue = DateTimeValues(fileIdx);
                    TimeVecTemp(Startindex:Startindex+ActBlockSize-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/ActBlockSize),ActBlockSize);
                    
                    Startindex = Startindex + ActBlockSize;
                end
                    % compression
                    [DataVecComp,TimeVecComp] = DataCompactor(FeatDataTemp,TimeVecTemp,stControl);

                    ActBlockSize = size(DataVecComp,1);

                    TimeVec(StartindexComp:StartindexComp+ActBlockSize-1) = TimeVecComp;
                    Data(StartindexComp:StartindexComp+ActBlockSize-1,:) = DataVecComp(1:ActBlockSize,:);
                    StartindexComp = StartindexComp + ActBlockSize;
            end
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