function [Data,TimeVec,NrOfParts]=getObjectiveDataOneDayOld(szBaseDir,szTestSubject,desiredDay, szFeature,PartNumberToLoad)
% function to load objective data of one day for one test subject
% Usage [Data,TimeVec]=getObjectiveDataOneDay(szTestSubject,desiredDay, szFeature)
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
% szTestSubjectDirList = dir(szBaseDir);
% szTestSubjectDir = [];
% for kk = 1:length(szTestSubjectDirList)
%     if szTestSubjectDirList(kk).isdir == 1
%         %            display(szProbandDirList(kk).name);
%         if ~isempty(strfind(szTestSubjectDirList(kk).name,szTestSubject))
%             szTestSubjectDir = szTestSubjectDirList(kk).name;
%             break;
%         end
%     end
% end
stSubject = getsubjectfolder(szBaseDir, szTestSubject);
if isempty(stSubject)
    Data = [];
    TimeVec = [];
    NrOfParts = [];
    return;

end
% check if the day has objective data
% build the full directory
szDir = [szBaseDir filesep stSubject.FolderName filesep stSubject.SubjectID '_AkuData' ];

AllFeatFiles = dir(szDir);
Counter = 1;
dateVecAll = datetime(zeros(length(AllFeatFiles),1),zeros(length(AllFeatFiles),1),zeros(length(AllFeatFiles),1));
FileIndex = zeros(length(AllFeatFiles),1);

% szCurFile = {AllFeatFiles.name};
% DateTimeValue = Filename2date(szCurFile,szFeature);
for kk = 1:length(AllFeatFiles)
    szCurFile = AllFeatFiles(kk).name;
    DateTimeValue = Filename2date(szCurFile,szFeature);
    if ~isempty(DateTimeValue)
        dateVecAll(Counter) = DateTimeValue;
        FileIndex(Counter) = kk;
        Counter = Counter +1;
    end
end



dateVecAll(Counter:end) = [];
FileIndex(Counter:end) = [];
[dateVecAll, SortIdx] = sort(dateVecAll);
FileIndex = FileIndex(SortIdx);
dateVecDayOnly= dateVecAll-timeofday(dateVecAll);
UniqueDays = unique(dateVecDayOnly);
idx = find(UniqueDays == desiredDay,1);
% read the data
if ~isempty(idx)
%     display('Data are available')
    FinalNonDataIdx = find(UniqueDays(idx) ~= dateVecDayOnly);
    FileIndex(FinalNonDataIdx) = [];
    dateVecAll(FinalNonDataIdx) = [];
    
    % Analysis how many parts are there at this day
    dtMinutes = minutes(diff(dateVecAll));
    idxPartBorders = find (dtMinutes> 1.1);
    idxPartBorders = [0; idxPartBorders; length(dtMinutes)];
    NrOfParts = length(idxPartBorders)-1;
%     display(sprintf('There are %d parts on this day', NrOfParts));
    
    % Added by Nils 06-Nov-2017
    % Only get the number of available parts for one day and return
    if PartNumberToLoad < 1
        Data = [];
        TimeVec = [];
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (PartNumberToLoad<=NrOfParts)
       PartStartIdx =  idxPartBorders(PartNumberToLoad)+1; 
       PartEndIdx = idxPartBorders(PartNumberToLoad+1); 
       
    else
%         warning('Desired Part does not exist: Intead I read the first part');
        PartStartIdx =  idxPartBorders(1)+1; 
        PartEndIdx = idxPartBorders(2); 
    end
    FileIndex = FileIndex(PartStartIdx:PartEndIdx);
    
    if isempty(FileIndex)
        Data = [];
        TimeVec = [];
%         if PartStartIdx > PartEndIdx
%             warning('Part start index is: %i and part end index is: %i',...
%                 PartStartIdx, PartEndIdx);
%             warning('Continuing with next part...')
%         end
        return;
    end
    dateVecAll = dateVecAll(PartStartIdx:PartEndIdx);
    
    
    
    % pre-allocation
    [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep AllFeatFiles(FileIndex(1)).name]);   
    AssumedBlockSize = size(FeatData,1);
    if (size(FeatData,2) > 100)
        AssumedBlockSize = AssumedBlockSize-1;
    end
    FullFeatData = repmat(zeros(AssumedBlockSize+1,size(FeatData,2)),length(FileIndex),1);
    FullTimeVec = datetime(zeros(length(FileIndex)*(AssumedBlockSize+1),1),...
        zeros(length(FileIndex)*(AssumedBlockSize+1),1),...
        zeros(length(FileIndex)*(AssumedBlockSize+1),1));

    Startindex = 1;
    for kk = 1:length(FileIndex)
       szFileName =  AllFeatFiles(FileIndex(kk)).name;
       [FeatData, ~,~]= LoadFeatureFileDroidAlloc([szDir filesep szFileName]);
       ActBlockSize = size(FeatData,1);
%        if (ActBlockSize ~= AssumedBlockSize)
%            display('Somethings wrong with this file')
%            display(sprintf('%s',szFileName));
%            display('I will try to compensate');
%        end
%        
       
       DateTimeValue = Filename2date(szFileName,szFeature);
%        ActTimeVec = linspace(DateTimeValue,DateTimeValue+minutes(1-1/AssumedBlockSize),AssumedBlockSize+1);
%        FullTimeVec(Startindex:Startindex+AssumedBlockSize) = ActTimeVec;
%        %ActBlockSize = size(FeatData,1);
%        FullFeatData(Startindex:Startindex+AssumedBlockSize-1,:) = FeatData(1:AssumedBlockSize,:);
%        Startindex = Startindex + AssumedBlockSize;
       ActTimeVec = linspace(DateTimeValue,DateTimeValue+minutes(1-1/ActBlockSize),ActBlockSize+1);
       FullTimeVec(Startindex:Startindex+ActBlockSize) = ActTimeVec;
       %ActBlockSize = size(FeatData,1);
       FullFeatData(Startindex:Startindex+ActBlockSize-1,:) = FeatData(1:ActBlockSize,:);
       Startindex = Startindex + ActBlockSize;
       FullFeatData(Startindex,:) = FullFeatData(Startindex-1,:);
       Startindex = Startindex+1;
    end
    Data = FullFeatData;
    TimeVec = FullTimeVec;
    
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