
%szBaseDir = fullfile('..','HALLO_joerg')
stAllSubjects = getallsubjects(szBaseDir);
caDates = getdates(szBaseDir);
isDebug = 0;
szFeature = 'RMS';

for subjectIdx = 1:numel(stAllSubjects)
    szSubject = stAllSubjects{subjectIdx};
    
    for dateIdx = 1:numel(caDates.(subjectIdx))
        dateDay = caDates.(subjectIdx)(dateIdx);
        
        % Get all available parts for each day and each subject
        % To do this, set desiredPart variable to zero (last variable)
        [~, ~, iNrOfParts] = getObjectiveDataOneDay(szBaseDir, szSubject.SubjectID, dateDay, szFeature,0);
            
        if isempty(iNrOfParts)
            warning('No valid parts found. Continuing ...')
            continue;
        end
            
        % Loop over all parts of one day for one subject
        for jj = 1:iNrOfParts
            computeDayFingerprintData(szBaseDir,szSubject.SubjectID,dateDay,jj,isDebug);
        end
    end
end