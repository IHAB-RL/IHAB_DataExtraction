function stSubject = getsubject(szBaseDir, szSubjectFolder)
% function to get the name and path to the data folder of one subject
% Usage stSubject = getsubject(szBaseDir, szSubjectFolder)
%
% Parameters
% ----------
% szBaseDir : string, contains path to base directory with all subjects
%
% szSubjectFolder : string, contains name of desired subject folder
%                   if szBaseDir contains already the name of the subject 
%                   folder, than szSubjectFolder must not be assigned
% Returns
% -------
% stSubject : struct array with fields FolderName and SubjectID
%
% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 
% Ver. 1.0 new input convention and some comments 27-Sept-2019 JP

if nargin == 1
    caDir = regexpi(szBaseDir,'\','split');
    szBaseDir = fullfile(caDir{1:end-1});
    szSubjectFolder = caDir{end};
end

stSubject.FolderName = szSubjectFolder;
caSubjectID = regexpi(szSubjectFolder,'[_]','split');
stSubject.SubjectID = caSubjectID{1};

%% Check for existence
% Get all sub-directories from base directory
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
