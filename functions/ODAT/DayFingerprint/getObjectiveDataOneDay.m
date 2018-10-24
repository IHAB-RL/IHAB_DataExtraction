function [Data, TimeVec, NrOfParts] =...
    getObjectiveDataOneDay(obj, desiredDay, szFeature, PartNumberToLoad)
% function to load objective data of one day for one test subject
% Usage [Data,TimeVec]=getObjectiveDataOneDay(szTestSubject,desiredDay, szFeature)
%
% GUI IMPLEMENTATION UK
%
% Parameters
% ----------
% szTestSubject :  string
%	 the "name" / pseudonym of the test subject
% desiredDay :  date/time
%	 the day of the desired data
% szFeature :  string
%	 name of the desired Feature default = 'PSD'
%
% Returns
% -------
% Data :  a matrix containg the feature data
%
% TimeVec :  a date/time vector with the corresponding time information
%
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Source: If the function is based on a scientific paper or a web site,
%         provide the citation detail here (with equation no. if applicable)
% Version History:
% Ver. 0.01 initial create (empty) 15-May-2017  Initials (eg. JB)

%------------Your function implementation here---------------------------

if nargin < 3
    szFeature = 'PSD';
    PartNumberToLoad = 1;
end
if nargin < 4
    PartNumberToLoad = 1;
end

% check if the test person exist
% stSubject = getsubjectfolder(szBaseDir,szTestSubject);

if isempty(obj.stSubject.Folder)
    Data = [];
    TimeVec = [];
    NrOfParts = [];
    return;
    
end

% check if the day has objective data
% build the full directory
szDir = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '_AkuData' ];

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
    CheckDataIntegrety(obj.stSubject.Name);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);

% Textscan stores all lines into one cell array, so you need to unpack it
corruptFiles = corruptFiles{:};

% Delete names of corrupt files from the list with all feat file names
[featFilesWithoutCorrupt, ia] = setdiff(AllFeatFiles, corruptFiles, 'stable');

% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,isFeatFile] = Filename2date(featFilesWithoutCorrupt, szFeature);

% Also filter the corresponding file list
featFilesWithoutCorrupt = featFilesWithoutCorrupt(logical(isFeatFile));

% Get unique days only
dateVecDayOnly = dateVecAll - timeofday(dateVecAll);
UniqueDays = unique(dateVecDayOnly);
idx = find(UniqueDays == desiredDay,1);

% read the data
if ~isempty(idx)
    FinalNonDataIdx = UniqueDays(idx) ~= dateVecDayOnly;
    dateVecAll(FinalNonDataIdx) = [];
    featFilesWithoutCorrupt(FinalNonDataIdx) = [];
    % Analysis how many parts are there at this day
    dtMinutes = minutes(diff(dateVecAll));
    idxPartBorders = find (dtMinutes> 1.1);
    idxPartBorders = [0; idxPartBorders; length(dtMinutes)];
    NrOfParts = length(idxPartBorders)-1;
    
    % Added by Nils 06-Nov-2017
    % Only get the number of available parts for one day and return
    if PartNumberToLoad < 1
        Data = [];
        TimeVec = [];
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (PartNumberToLoad <= NrOfParts)
        PartStartIdx = idxPartBorders(PartNumberToLoad)+1;
        PartEndIdx = idxPartBorders(PartNumberToLoad+1);
    else
        PartStartIdx = idxPartBorders(1)+1;
        PartEndIdx = idxPartBorders(2);
    end
    
    if PartStartIdx > PartEndIdx
        Data = [];
        TimeVec = [];
        warning('Start index is greater than end index')
        return;
    end
    dateVecAll = dateVecAll(PartStartIdx:PartEndIdx);
    featFilesWithoutCorrupt = featFilesWithoutCorrupt(PartStartIdx:PartEndIdx);
    
    
    % pre-allocation
    [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep featFilesWithoutCorrupt{1}]);
    AssumedBlockSize = size(FeatData,1);
    
    if (size(FeatData,2) > 100)
        AssumedBlockSize = AssumedBlockSize-1;
    end
    
    Data = repmat(zeros(AssumedBlockSize+1,size(FeatData,2)),length(dateVecAll),1);
    TimeVec = datetime(zeros(length(dateVecAll)*(AssumedBlockSize+1),1),...
        zeros(length(dateVecAll)*(AssumedBlockSize+1),1),...
        zeros(length(dateVecAll)*(AssumedBlockSize+1),1));
    
    Startindex = 1;
    for fileIdx = 1:numel(featFilesWithoutCorrupt)
        
        szFileName =  featFilesWithoutCorrupt{fileIdx};
        [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep szFileName]);
        ActBlockSize = size(FeatData,1);
        DateTimeValue = dateVecAll(fileIdx);
        TimeVec(Startindex:Startindex+ActBlockSize) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/ActBlockSize),ActBlockSize+1);
        Data(Startindex:Startindex+ActBlockSize-1,:) = FeatData(1:ActBlockSize,:);
        Startindex = Startindex + ActBlockSize;
        Data(Startindex,:) = Data(Startindex-1,:);
        Startindex = Startindex+1;
        
    end
    
else
    Data = [];
    TimeVec = [];
    NrOfParts = [];
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