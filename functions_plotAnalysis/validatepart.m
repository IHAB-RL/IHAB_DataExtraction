
function stSubject = validatepart(szSubjectDir, configStruct, dataPath, day, part)
%VALIDATESUBJECT returns whether the data of one subject are valid
%   The output struct is saved to the given path.
%
% INPUT:
%       szSubjectDir: string, full path of one subject directory
%
%       configStruct: struct, defines validation parameters
%               has to define:
%                       .lowerBinCohe: center frequency of the lower bin
%                                     of coherence which is used for averaging
%                                     over a number of bins
%                       .upperBinCohe: center frequency of the upper bin
%                                     of coherence which is used for averaging
%                                     over a number of bins
%                       .upperThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of coherence
%                                           that should not be exceeded
%                       .lowerThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of coherence
%                                           that should not be undercut
%                       .thresholdRMSforCohe: threshold of RMS that should
%                                            not be undercut for the
%                                            validation of the coherence
%                       .upperThresholdRMS: threshold of RMS that should
%                                           not be exceeded
%                       .lowerThresholdRMS: threshold of RMS that should
%                                           not be undercut
%                       .errorTolerance: percentage of allowed invalidity
%
% OUTPUT:
%       tableSubject: struct, contains:
%                       .FolderName: string, subject ID + extension
%                       .SubjectID: string
%                       .chunkID: struct, contains:
%                           .FileName: cell of strings
%                           .ErrorCode: cell, contais int/vector
%                                       respective error codes for each
%                                       file
%                                       Error codes can be:
%                            0: ok
%                           -1: at least one RMS value was too HIGH
%                           -2: at least one RMS value was too LOW
%                           -3: data is mono
%                           -4: Coherence (real part) is invalid
%                           -5: RMS feature file was not found

% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 14-Dec-2017 			 NS
% Ver. 0.02 first running version  04-Jan-2018 			 NS
% Ver. 0.03 added config struct    02-Feb-2018 			 NS
% Ver. 0.04 restructure of stSubject with 'valid' and 'invalid' as new 
%           fields                 07-Sep-2018           NS                 
% ---------------------------------------------------------

% Get name of subject without any postfix
stSubject = getsubject(dataPath, szSubjectDir);

% Get into respective '_AkuData'-directory
szAkuDataPath = fullfile(dataPath, stSubject.FolderName, [stSubject.SubjectID '_AkuData']);

if isdatetime(day)
    dayDirectory = datestr(day,'yyyymmdd');
elseif ischar(day)
    if length(day) ~= 8
        error('Wrong day format');
    end
end
szMatFile = fullfile(dataPath,...
                     stSubject.FolderName,...
                     'validated_data',...
                     dayDirectory,...
                     ['part_' num2str(part)],...
                     [dayDirectory '_' num2str(part) '.mat']);

if ~exist(szAkuDataPath, 'dir')
    error('%s: Sub-directory ''_AkuData'' does not exist',stSubject.SubjectID)
end

% Get all .feat-file names
%listFeatFiles = listFiles(szAkuDataPath, '*.feat', 1);

listTxtFile = fullfile(dataPath,...
                     stSubject.FolderName,...
                     'validated_data',...
                     dayDirectory,...
                     ['part_' num2str(part)],...
                     'filelist.txt');
fid = fopen(listTxtFile,'r');
listFeatFiles = textscan(fid,'%s\n');
fclose(fid);
listFeatFiles= listFeatFiles{:};

splitNames = regexpi(listFeatFiles, '_', 'split');
numFilenameParts = numel(splitNames{1});


if numFilenameParts < 4
    isOldFormat = true;
else
    isOldFormat = false;
end

% Get dates of corrupt files to delete all features with that specific time stamp
%corruptFiles = listFeatFiles(cellfun(@(x) (strcmpi(x(1),'a')), listFeatFiles));
corruptTxtFile = fullfile(dataPath, stSubject.FolderName,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(stSubject.FolderName, dataPath);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);
corruptFiles = corruptFiles{:};

[listFeatFiles, ia] = setdiff(listFeatFiles,corruptFiles,'stable');
if isOldFormat
    validNameLength = 21;
else
    validNameLength = 28;
end
isValidNameLength = cellfun(@(x) (length(x) > validNameLength), corruptFiles);

if all(isValidNameLength == true)
    
    if isOldFormat
        corruptFiles = cellfun(@(x) (regexp(x,'\d+_\d+','match')), corruptFiles,'UniformOutput',false);
    else
        corruptFiles = cellfun(@(x) (regexp(x,'\d+_\d+_\d+','match')), corruptFiles,'UniformOutput',false);
    end
    corruptFiles = [corruptFiles{:}];
else
    errorFID = fopen(fullfile(stSubject.FolderName,'error.txt'),'w');
    fprintf(errorFID,'There were files with an invalid name length. Therefore no mat-file was created.');
    fclose(errorFID);
    warning('%s: Files with invalid name length found. Returning and continuing with next subject ...', stSubject.SubjectID);
    return;
end

datenumCorruptFiles = [];
if ~isempty(corruptFiles)
    if isOldFormat
        datenumCorruptFiles = datenum(cellfun(@(x) x(1:end), corruptFiles, 'UniformOutput',false), 'yyyymmdd_HHMMSSFFF');
    else
        datenumCorruptFiles = datenum(cellfun(@(x) x(8:end), corruptFiles, 'UniformOutput',false), 'yyyymmdd_HHMMSSFFF');
    end
end

% Get all features
caFeatures = unique(cellfun(@(x) (x(1:3)), listFeatFiles, 'UniformOutput', false));
numFeatures = numel(caFeatures);

if isOldFormat
    partNumber = '';
    % Get only the dates from the file names
    listFeatFiles = cellfun(@(x) x(5:22), listFeatFiles, 'UniformOutput', false);
else
    partNumber = cellfun(@(x) x(5:10), listFeatFiles, 'UniformOutput', false);
    % Get only the dates from the file names
    listFeatFiles = cellfun(@(x) x(12:29), listFeatFiles, 'UniformOutput', false);
end


listFeatFiles = datenum(listFeatFiles,'yyyymmdd_HHMMSSFFF');

% Get indexes of all 'corrupt time stamps'
if ~isempty(datenumCorruptFiles)
    corruptIndexes = [];
    for corruptFile = 1:numel(datenumCorruptFiles)
        for idxList = 1:numel(listFeatFiles)
            if datenumCorruptFiles(corruptFile) == listFeatFiles(idxList)
                corruptIndexes = [corruptIndexes idxList];

            end
        end
    end
    
    % Delete 'corrupt time stamps'
    listFeatFiles(corruptIndexes) = [];
    
    if ~isOldFormat
        partNumber(corruptIndexes) = [];
    end
end

% Get time stamps only once regardless of the feature (short feature names will be put in front later on)
[uniqueDays,uniIdx,~] = unique(listFeatFiles);

if ~isOldFormat
    partNumber = partNumber(uniIdx)';
    partNumber = strcat('_', partNumber)';
end
uniqueDatesAsStrings = cellstr(datestr(uniqueDays,'yyyymmdd_HHMMSSFFF'));

% Append file extension again
listFeatFiles = strcat(szAkuDataPath, filesep, 'RMS', partNumber, '_', uniqueDatesAsStrings, '.feat');

NumFeatFiles = numel(listFeatFiles);

if isOldFormat
    partNumber = cell(NumFeatFiles,1);
end

% Check each chunk for validity via validatechunk.m
listCounterValid = 0;
listCounterInvalid = 0;

stSubject.valid.FileName = cell(numFeatures*NumFeatFiles,1);
stSubject.valid.ErrorCode = cell(numFeatures*NumFeatFiles,1);
stSubject.valid.PercentageError = cell(numFeatures*NumFeatFiles,1);
stSubject.invalid.FileName = cell(numFeatures*NumFeatFiles,1);
stSubject.invalid.ErrorCode = cell(numFeatures*NumFeatFiles,1);
stSubject.invalid.PercentageError = cell(numFeatures*NumFeatFiles,1);

% tic;
for fileIdx = 1:NumFeatFiles
    
%     clc; progress_bar(fileIdx, NumFeatFiles, 3, 5)
    [iErrorCode, percentErrors] = validatechunk(listFeatFiles{fileIdx}, configStruct);

    if length(iErrorCode{:}) == 1 && all([iErrorCode{:}] == 0)
        stSubject.valid.FileName(listCounterValid*numFeatures+1:(listCounterValid+1)*numFeatures,1) = strcat(caFeatures, partNumber{fileIdx}, '_', uniqueDatesAsStrings{fileIdx}, '.feat');
        stSubject.valid.ErrorCode(listCounterValid*numFeatures+1:(listCounterValid+1)*numFeatures) = iErrorCode;
        stSubject.valid.PercentageError(listCounterValid*numFeatures+1:(listCounterValid+1)*numFeatures) = percentErrors;
        listCounterValid = listCounterValid +1;
    else
        stSubject.invalid.FileName(listCounterInvalid*numFeatures+1:(listCounterInvalid+1)*numFeatures,1) = strcat(caFeatures, partNumber{fileIdx}, '_', uniqueDatesAsStrings{fileIdx}, '.feat');
        stSubject.invalid.ErrorCode(listCounterInvalid*numFeatures+1:(listCounterInvalid+1)*numFeatures) = iErrorCode;
        stSubject.invalid.PercentageError(listCounterInvalid*numFeatures+1:(listCounterInvalid+1)*numFeatures) = percentErrors;
        listCounterInvalid = listCounterInvalid +1;
    end
    
end

% Remove empty cells left over from allocation
fieldNames = fieldnames(stSubject.valid);

for fName = 1:numel(fieldNames)
    stSubject.valid.(fieldNames{fName})(cellfun(@isempty, stSubject.valid.(fieldNames{fName}))) = [];
    stSubject.invalid.(fieldNames{fName})(cellfun(@isempty, stSubject.invalid.(fieldNames{fName}))) = [];
end

save(szMatFile,'stSubject');
     
% EOF validatesubject.m