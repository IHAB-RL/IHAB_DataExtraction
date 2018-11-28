
function stSubject = validatesubject(obj, configStruct)
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
% Ver. 0.02 first running version 04-Jan-2018 			 NS
% Ver. 0.03 added config struct 02-Feb-2018 			 NS
% ---------------------------------------------------------

% Parameters for version check
%yearNewData = 2018;
%monthNewData = 4;

% Get name of subject without any postfix
% [szFilePath, szName] = fileparts(szSubjectDir);
% szSubjectID = split(szName,'_');
stSubject.FolderName = obj.stSubject.Folder;
% szSubjectID = szSubjectID{1};
stSubject.SubjectID = obj.stSubject.Name;

% Get into respective '_AkuData'-directory
% tempDir = fullfile(pwd, 'IHAB_Rohdaten_EMA2018');
% tempDir = fullfile(pwd, 'IHAB_Rohdaten_EMA2018');
szAkuDataPath = fullfile(obj.stSubject.Folder, [obj.stSubject.Name '_AkuData']);

szMatFile = fullfile(obj.stSubject.Folder, [obj.stSubject.Name '.mat']);

if ~exist(szAkuDataPath, 'dir')
    error('%s: Sub-directory ''_AkuData'' does not exist',obj.stSubject.Name)
end

% Get all .feat-file names
listFeatFiles = listFiles(szAkuDataPath, '*.feat', 1);

% Store names in a cell array
listFeatFiles = {listFeatFiles.name};

% Get names without paths
[~,listFeatFiles] = cellfun(@fileparts, listFeatFiles, 'UniformOutput', false);
listFeatFiles = strcat(listFeatFiles,'.feat');

splitNames = regexpi(listFeatFiles, '_', 'split');
numFilenameParts = numel(splitNames{1});


if numFilenameParts < 4
    isOldFormat = true;
else
    isOldFormat = false;
end

% Get dates of corrupt files to delete all features with that specific time stamp
%corruptFiles = listFeatFiles(cellfun(@(x) (strcmpi(x(1),'a')), listFeatFiles));
corruptTxtFile = fullfile(obj.stSubject.Folder, 'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(obj.stSubject.Name);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);
corruptFiles = corruptFiles{:};

[listFeatFiles, ia] = setdiff(listFeatFiles',corruptFiles,'stable');
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
    errorFID = fopen(fullfile(szSubjectDir,'error.txt'),'w');
    fprintf(errorFID,'There were files with an invalid name length. Therefore no mat-file was created.');
    fclose(errorFID);
    warning('%s: Files with invalid name length found. Returning and continuing with next subject ...', obj.stSubject.Name);
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
%listFeatFiles = cellfun(@(x) [szAkuDataPath filesep x '.feat'], uniqueDatesAsStrings, 'UniformOutput', false);

NumFeatFiles = numel(listFeatFiles);

if isOldFormat
    partNumber = cell(NumFeatFiles,1);
end
% fullfile(tempDir, szSubjectDir, [stSubject.SubjectID '.mat']);
% Check each chunk for validity via validatechunk.m
caErrorCodes = cell(numFeatures*NumFeatFiles,1);
caPercentErrors = cell(numFeatures*NumFeatFiles,1);
finalList = cell(numFeatures*NumFeatFiles,1);
listCounter = 0;
% tic;
for ii = 1:NumFeatFiles
    
    %clc; %progress_bar(ii, NumFeatFiles, 3, 5)
    [iErrorCode, percentErrors] = validatechunk(listFeatFiles{ii}, configStruct);
    finalList(listCounter*numFeatures+1:(listCounter+1)*numFeatures,1) = [strcat(caFeatures, partNumber{ii}, '_', uniqueDatesAsStrings{ii}, '.feat')];
    caErrorCodes(listCounter*numFeatures+1:(listCounter+1)*numFeatures) = iErrorCode;
    caPercentErrors(listCounter*numFeatures+1:(listCounter+1)*numFeatures) = percentErrors;
    listCounter = listCounter +1;
end
stSubject.chunkID = struct('FileName',{finalList},'ErrorCode',{caErrorCodes}, 'PercentageError', {caPercentErrors});

save(szMatFile,'stSubject');
     
% EOF validatesubject.m