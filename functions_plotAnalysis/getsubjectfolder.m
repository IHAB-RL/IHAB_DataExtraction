function stSubject = getsubjectfolder(a,szSubject)

% Get all sub-directories from base directory
subjectDirectories = dir(fullfile(pwd, 'IHAB_Rohdaten_EMA2018'));
allSubjects = subjectDirectories([subjectDirectories.isdir]);

% Remove annoying '.'  and '..'
allSubjects = allSubjects(~ismember({allSubjects.name},{'.','..','.ipynb_checkpoints'}));

for ii = 1:length(allSubjects)
    szTestSubject = allSubjects(ii).name;
    
    if strfind(szTestSubject, szSubject)
 
        % Create struct with folder name and two lines below the subject ID
        stSubject.FolderName = szTestSubject;
        stSubject.SubjectID = szSubject;
        return;    
    end
    
    if ii == length(allSubjects)
        error('Subject not found');
    end
    
    
end
