function [Data,TimeVec,NrOfParts,stInfo]=getObjectiveDataOneDay(szBaseDir,szTestSubjectDir,desiredDay,szFeature,PartNumberToLoad,AllParts)
% function to load objective data of one day for one test subject
% Usage [Data,TimeVec]=getObjectiveDataOneDay(szTestSubject,desiredDay, szFeature)
%
% Parameters
% ----------
% szBaseDir : string
%    the path of the data folder
% szTestSubject :  string
%	 the "name" / pseudonym of the test subject
% desiredDay :  date/time
%	 the day of the desired data
% szFeature :  string
%	 name of the desired Feature default = 'PSD'
% PartNumberToLoad : number
%    the number of the part to load
% AllParts : logical
%    if 0 PartNumberToLoad acts, if 1 all parts of the desired day
%
% Returns
% -------
% Data :  a matrix containg the feature data
%
% TimeVec :  a date/time vector with the corresponding time information
%
% NrOfParts : number of parts at desired day
%
% stInfo : a struct containg infos about the feature files, e.g. fs, sample
%          size
%
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Source: If the function is based on a scientific paper or a web site,
%         provide the citation detail here (with equation no. if applicable)
% Version History:
% Ver. 0.01 initial create (empty) 15-May-2017  Initials (eg. JB)
% modified Sept 2019 (JP): get one or all parts of the desired day

if nargin < 4
    szFeature = 'PSD';
end
if nargin < 5
    PartNumberToLoad = 1;
end
if nargin < 6
    AllParts = 0;
end

% check if the test person exist
stSubject = getsubject(szBaseDir,szTestSubjectDir);
if isempty(stSubject)
    Data = [];
    TimeVec = [];
    NrOfParts = [];
    return;
end


% check if the day has objective data
% build the full directory
szDir = [szBaseDir filesep stSubject.FolderName filesep stSubject.SubjectID '_AkuData'];

% List all feat files
AllFeatFiles = listFiles(szDir,'*.feat');
AllFeatFiles = {AllFeatFiles.name}';

% Get names wo. path
[~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);

% Append '.feat' extension for comparison to corrupt file names
AllFeatFiles = strcat(AllFeatFiles,'.feat');

% Load txt file with corrupt file names
corruptTxtFile = fullfile(szBaseDir, stSubject.FolderName,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(stSubject.FolderName, szBaseDir);
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

% Get unique days only
dateVecDayOnly= dateVecAll-timeofday(dateVecAll);
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
    if ~AllParts
        if (PartNumberToLoad<=NrOfParts)
            PartStartIdx =  idxPartBorders(PartNumberToLoad)+1;
            PartEndIdx = idxPartBorders(PartNumberToLoad+1);
            
        else
            PartStartIdx =  idxPartBorders(1)+1;
            PartEndIdx = idxPartBorders(2);
        end
        
        if PartStartIdx > PartEndIdx
            Data = [];
            TimeVec = [];
            stInfo = [];
            warning('Start index is greater than end index')
            return;
        end
        dateVecAll = dateVecAll(PartStartIdx:PartEndIdx);
        featFilesWithoutCorrupt=featFilesWithoutCorrupt(PartStartIdx:PartEndIdx);
    end
    
    % pre-allocation
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