function caSubjectList = getallsubjects(szDir)
%GETALLSUBJECTS Gets a list of all subjects in the base folder

% Get all sub-directories from base directory
subjectDirectories = dir(szDir);
allSubjects = subjectDirectories([subjectDirectories.isdir]);

% Remove annoying '.'  and '..'
allSubjects = allSubjects(~ismember({allSubjects.name},{'.','..','.ipynb_checkpoints'}));

% Allocate final cell array
caSubjectList = cell(length(allSubjects),1);

% Split the names of the sub-directories at '_' to get subject name
% and return the first part that should contain the actual name

for ii = 1:length(allSubjects)
    szTestSubject = allSubjects(ii).name;
    
    % Create struct with folder name and two lines below the subject ID
    stSubject.FolderName = szTestSubject;
    szTestSubject = split(szTestSubject,'_');
    stSubject.SubjectID = szTestSubject{1};
    
    % Store struct in cell array
    caSubjectList{ii} = stSubject;
end
