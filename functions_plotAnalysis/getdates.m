function T = getdates(szDir)
%GETDATES Gets all available dates from all subjects

% Get the names of all subject in the given directory
caSubjectStructs = getallsubjects(szDir);

T = table();

for ii = 1:numel(caSubjectStructs)
    T.(caSubjectStructs{ii}.SubjectID) = ...
        getdatesonesubject(caSubjectStructs{ii}.SubjectID);   
end