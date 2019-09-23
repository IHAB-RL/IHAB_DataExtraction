function [NrOfParts, featFilesWithoutCorrupt] = getparts(dataPath,subjectFolder,desiredDay,PartNumberToLoad)

stSubject = getsubject(dataPath,subjectFolder);

% check if the day has objective data
% build the full directory
szDir = [dataPath filesep stSubject.FolderName filesep stSubject.SubjectID '_AkuData' ];

% List all feat files
AllFeatFiles = listFiles(szDir,'*.feat');
AllFeatFiles = {AllFeatFiles.name}';

% Get names wo. path
[~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);

% Append '.feat' extension for comparison to corrupt file names
AllFeatFiles = strcat(AllFeatFiles,'.feat');

% Load txt file with corrupt file names
corruptTxtFile = fullfile(dataPath, stSubject.FolderName,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(stSubject.SubjectID);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);

% Textscan stores all lines into one cell array, so you need to unpack it
corruptFiles = corruptFiles{:};

% Delete names of corrupt files from the list with all feat file names
[featFilesWithoutCorrupt, ia] = setdiff(AllFeatFiles,corruptFiles,'stable');

% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,isFeatFile] = Filename2date(featFilesWithoutCorrupt);

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
    idxPartBorders = [0; idxPartBorders; length(dtMinutes)+1];
    NrOfParts = length(idxPartBorders)-1;
    
    % Added by Nils 06-Nov-2017
    % Only get the number of available parts for one day and return
    if nargout == 1
        featFilesWithoutCorrupt = [];
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (PartNumberToLoad<=NrOfParts)
        PartStartIdx =  idxPartBorders(PartNumberToLoad)+1;
        PartEndIdx = idxPartBorders(PartNumberToLoad+1);
        
    else
        PartStartIdx =  idxPartBorders(1)+1;
        PartEndIdx = idxPartBorders(2);
    end
    
    if PartStartIdx > PartEndIdx

        warning('Start index is greater than end index')
        return;
    end
    if nargout > 1 && PartNumberToLoad > 0
        featFilesWithoutCorrupt=featFilesWithoutCorrupt(PartStartIdx:PartEndIdx);
    end
else
    NrOfParts = 0;
end