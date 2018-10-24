
szDir = '/media/nils/HDD/ObjectiveDataAnalysisToolbox/HALLO_EMA2016_all';
dateDays = getdates(szDir);
caAllSubjects = getallsubjects(szDir);

for subjectIdx = 1:numel(dateDays)

    correctIdx = 0;
    for allSubsIdx = 1:numel(caAllSubjects)
        if strcmpi(caAllSubjects{allSubsIdx}.SubjectID, dateDays.Properties.VariableNames{subjectIdx})
            correctIdx = allSubsIdx;
            break;
        end
    end
 
    szFolderName = caAllSubjects{correctIdx}.FolderName;
    
    for dateIdx = 1:numel(dateDays.(subjectIdx))
    
        % Get all available parts for each day and each subject
        % To do this, set desiredPart variable to zero (last variable)
        fprintf(1,'============= %s\t%s =============\n',dateDays.Properties.VariableNames{subjectIdx}, ...
                dateDays.(subjectIdx)(dateIdx));
        [~, ~, nParts] = getObjectiveDataOneDay(szDir, dateDays.Properties.VariableNames{subjectIdx}, ...
                                                dateDays.(subjectIdx)(dateIdx), szFeature,0);
        fprintf('\n');
    
        if ~isempty(nParts) && nParts ~= 0
            for partIdx = 1:nParts
                fullfileName = [szDir filesep szFolderName filesep 'Fingerprint_' dateDays.Properties.VariableNames{subjectIdx} ...
                            '_' num2str(day(dateDays.(subjectIdx)(dateIdx))) '_'...
                            num2str(month(dateDays.(subjectIdx)(dateIdx))) '_' ...
                            num2str(year(dateDays.(subjectIdx)(dateIdx))) ...
                            '_p' num2str(partIdx) '.pdf'];
                if exist(fullfileName,'file')      
                    delete(fullfileName);
                end
            end
        end
    end
end