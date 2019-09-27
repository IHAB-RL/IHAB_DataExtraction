function splitdays(dataPath,subjectFolder)
%SPLITDAYS Based on dates and time inside the filenames this function 
% creates a directory 'validated_data' and inside of that direcory as many
% subdirectories respective to the number of days on which a subject
% measured with the IHAB mobile phone system. Each subdirectory can contain
% multiple subdirectories corresponding to the number of parts on a certain
% day. Again in this subdirectories there will be result files such as a
% fingerprint, a file list, a validation-result-mat-file and another
% mat-file containing the results of the fingerprint computation. All of
% these files are corresponding to the part.
%
% INPUT:
%
%   dataPath: string, root path to your data containing all subjects
%   subjectFolder: string, name of the directory for the respective subject
%
% OUTPUT:
%
%   none, creates multiple directories and file lists, see description 
%   above

% Version 0.1 initial functional creation
% Version 0.2 removed directory creation of 'valid' and 'invalid' and
%             take care of that in validatepart.m
%
% Author: Nils Schreiber at Jade Hochschule Oldenburg, 2018
% -------------------------------------------------------------------------
% Get ID
stSubject = getsubject(dataPath,subjectFolder);

validationDir = fullfile(dataPath,stSubject.FolderName,'validated_data');
% Create directory for validated data

% if exist(validationDir,'dir')
%     answer = inputdlg('Recreate directory? (y/n)','Directory already exists');
%     
%     if strcmpi(answer,'n') || isempty(answer)
%         warndlg('No directory will be created. Exit.')
%         return;
%     elseif strcmpi(answer,'y')
%         mkdir(validationDir);
%     end
% else
    mkdir(validationDir);
% end

% Get days and create directory per day
T = getdatesonesubject(stSubject.FolderName,dataPath);


% Get parts and create directory per part
numParts = zeros(numel(T.(stSubject.SubjectID)),1);
for kk = 1:numel(T.(stSubject.SubjectID))
    numParts(kk) = getparts(dataPath,stSubject.FolderName,T.(stSubject.SubjectID)(kk));
    
end

% If one day has zero parts it will get deleted
deleteIdxs = numParts == 0;
T.(stSubject.SubjectID)(:,deleteIdxs) = [];

% Create directory per day
dayDirectoryNames = cell(numel(T.(stSubject.SubjectID)),1);

% Update also numParts so that days with zero parts will not be included
numParts(deleteIdxs) = [];

for kk = 1:numel(T.(stSubject.SubjectID))
    dayDirectoryNames{kk,1} = fullfile(validationDir,datestr(T.(stSubject.SubjectID)(kk),'yyyymmdd'));
    mkdir(dayDirectoryNames{kk,1});
end

partDirectoryNames = cell(sum(numParts),1);
numFeatures = 3;
for kk = 1:numel(T.(stSubject.SubjectID))
    for ii = 1:numParts(kk)
        partDirectoryNames{ii,1} = fullfile(dayDirectoryNames{kk,1},['part_' num2str(ii)]);
        mkdir(partDirectoryNames{ii,1});
        
        [~,fileListPerPart] = getparts(dataPath,stSubject.FolderName,T.(stSubject.SubjectID)(kk),ii);
        fileListPerPart = cellfun(@(x) x(5:end),fileListPerPart,'UniformOutput',false);
        
        newfileList = cell(3*numel(fileListPerPart),1);
        listCounter = 0;
        for aa = 1:numel(fileListPerPart)
            newfileList(listCounter*numFeatures+1:(listCounter+1)*numFeatures,1) = strcat({'PSD_','RMS_','ZCR_'},fileListPerPart{aa});
            listCounter = listCounter +1;
        end
        fid = fopen(fullfile(partDirectoryNames{ii,1},'filelist.txt'),'w');
        fprintf(fid,'%s\n', newfileList{:});
        fclose(fid);
    end
end