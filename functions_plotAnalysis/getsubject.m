function stSubject = getsubject(szBaseDir, szSubjectFolder)

stSubject.FolderName = szSubjectFolder;
caSubjectID = regexpi(szSubjectFolder,'[_]','split');
stSubject.SubjectID = caSubjectID{1};

%% Check for existence
% Get all sub-directories from base directory
% subjectDirectories = dir(fullfile(pwd, 'IHAB_Rohdaten_EMA2018'));
subjectDirectories = dir(szBaseDir);

allSubjects = subjectDirectories([subjectDirectories.isdir]);

% Remove annoying '.'  and '..'
allSubjects = allSubjects(~ismember({allSubjects.name},{'.','..','.ipynb_checkpoints'}));

for ii = 1:length(allSubjects)
    szCurrentFolder = allSubjects(ii).name;
    
    if strcmpi(szCurrentFolder, stSubject.FolderName)
        return;    
    end
    
    if ii == length(allSubjects)
       error('Subject not found');
    end
    
    
end
