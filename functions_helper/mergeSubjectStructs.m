function mergeSubjectStructs(dataPath,szSubjectFolder)

stSubject = getsubject(dataPath,szSubjectFolder);
outputStructName = [stSubject.SubjectID '.mat'];

allDays = getdatesonesubject(stSubject.FolderName,dataPath);
numDays = numel(allDays.(stSubject.SubjectID));
numParts = zeros(numDays,1);
numFilesPerDay = zeros(numDays,1);
bigStruct = struct();
bigStruct.SubjectID = stSubject.SubjectID;
bigStruct.FolderName = stSubject.FolderName;
bigStruct.valid = struct();
bigStruct.valid.ErrorCode = {};
bigStruct.valid.FileName = {};
bigStruct.valid.PercentageError = {};
bigStruct.invalid = struct();
bigStruct.invalid.ErrorCode = {};
bigStruct.invalid.FileName = {};
bigStruct.invalid.PercentageError = {};
fnames = {'valid','invalid'};

for iDay = 1:numDays
    numParts(iDay,1) = getparts(dataPath,stSubject.FolderName,allDays.(stSubject.SubjectID)(iDay),0);
    numPartsOnDay = numParts(iDay);
    
    for iPart = 1:numPartsOnDay
        stSubjectFile = fullfile(dataPath,...
            stSubject.FolderName,...
            'validated_data',...
            datestr(allDays.(stSubject.SubjectID)(iDay),'yyyymmdd'),...
            ['part_' num2str(iPart)],...
            [datestr(allDays.(stSubject.SubjectID)(iDay),'yyyymmdd') '_' num2str(iPart) '.mat']);
        if exist(stSubjectFile,'file')
            load(stSubjectFile,'stSubject');
        else
            warning('File does not exist')
            continue;
        end
        
        for fieldIdx = 1:numel(fnames)
            bigStruct.(fnames{fieldIdx}).FileName(end+1) = {stSubject.(fnames{fieldIdx}).FileName};
            bigStruct.(fnames{fieldIdx}).ErrorCode(end+1) = {stSubject.(fnames{fieldIdx}).ErrorCode};
            bigStruct.(fnames{fieldIdx}).PercentageError(end+1) = {stSubject.(fnames{fieldIdx}).PercentageError};
        end
    end
end

for fieldIdx = 1:numel(fnames)
    bigStruct.(fnames{fieldIdx}).FileName = cat(1,bigStruct.(fnames{fieldIdx}).FileName{:});
    bigStruct.(fnames{fieldIdx}).ErrorCode = cat(1,bigStruct.(fnames{fieldIdx}).ErrorCode{:});
    bigStruct.(fnames{fieldIdx}).PercentageError = cat(1,bigStruct.(fnames{fieldIdx}).PercentageError{:});
end
stSubject = bigStruct;

save(fullfile(dataPath,stSubject.FolderName,[stSubject.SubjectID '.mat']),'stSubject');
% numFiles = sum(numFilesPerDay);
% for iDay = 1:numDays
%     numParts = getparts(dataPath,stSubject.FolderName,allDays.(stSubject.SubjectID)(iDay),0);
%     for iPart = 1:numParts
%
%         numFiles(iPart,1) =
%     end
% end