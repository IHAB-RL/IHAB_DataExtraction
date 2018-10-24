function T = getdatesonesubject(obj)
%GETDATESONESUBJECT Gets all available dates from one subject

% Set os specific file separator once
IFS = filesep;

szDir = fullfile(pwd, 'IHAB_Rohdaten_EMA2018');

% Get the names of all subject in the given directory
% stSubject = getsubjectfolder(szDir,szSubject);
% stSubject = struct('FolderName', obj.stSubject.Folder, 'SubjectID', obj.stSubject.Name);

% if isempty(stSubject)
%     error('Subject %s not found', szSubject);
% end

% List the whole content in the subject directory
stFeatFiles = dir([obj.stSubject.Folder, filesep, ...
    obj.stSubject.Name  '_AkuData']);

% Get rid of '.' and '..'
stFeatFiles(1:2) = [];

% Get files only
stFeatFiles = stFeatFiles(~[stFeatFiles.isdir]);
caFileNames = {stFeatFiles.name};

% Filter for .feat-files
stFeatFiles = stFeatFiles(cellfun(@(x) ~isempty(regexpi(x,'.feat')), caFileNames));
caFileNames = {stFeatFiles.name};

% Delete filenames belonging to corrupt files ...
% (see ../Tools/CheckDataIntegrety.m)
corruptTxtFile = fullfile(obj.stSubject.Folder,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(stSubject.SubjectID);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);
corruptFiles = corruptFiles{:};

[caFileNames, ~] = setdiff(caFileNames,corruptFiles,'stable');

% Get all numeric content of each name that correspond to date and time
caDatesWithTime = cellfun(@(x) regexpi(x,'\d+', 'match'), caFileNames,...
    'UniformOutput',false);

% Only take the date -> second last entry in each cell
caDatesWithoutTime = cellfun(@(x) x(end-1), caDatesWithTime);

% Filter for unique dates
caUniqueDates = unique(caDatesWithoutTime);

% Convert them to desired output format
caDates = datetime(caUniqueDates,'InputFormat','yyyyMMdd');
T = table();
T.(obj.stSubject.Name) = caDates;