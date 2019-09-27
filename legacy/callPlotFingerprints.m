
%close all;
%clearvars;

%szBaseDir = '/media/nils/HDD/ObjectiveDataAnalysisToolbox/HALLO_joerg';
%szQuestionnaireName = 'QuestionnairesTable_jb.mat';
%szQuestionnaireName = 'Questionnaires_all_out.mat';
%szSubject = 'CK09LM19';
dateDays = getdates(szBaseDir);
caAllSubjects = getallsubjects(szBaseDir);

% This is only needed for 'getObjectiveDataOneDay' and could also be PSD or anything else
szFeature = 'RMS';
bPrint = 1;

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
        [~, ~, nParts] = getObjectiveDataOneDay(szBaseDir, dateDays.Properties.VariableNames{subjectIdx}, ...
                                                dateDays.(subjectIdx)(dateIdx), szFeature,0);
        fprintf('\n');
    
        if ~isempty(nParts) && nParts ~= 0
            for partIdx = 1:nParts
                
                if ~exist([szBaseDir filesep szFolderName filesep 'Fingerprint_' dateDays.Properties.VariableNames{subjectIdx} ...
                            '_' num2str(day(dateDays.(subjectIdx)(dateIdx))) '_'...
                            num2str(month(dateDays.(subjectIdx)(dateIdx))) '_' ...
                            num2str(year(dateDays.(subjectIdx)(dateIdx))) ...
                            '_p' num2str(partIdx) '.pdf'],'file')
                            
                    plotAllDayFingerprints(szBaseDir, ...
                                           szQuestionnaireName, ...
                                           dateDays.Properties.VariableNames{subjectIdx}, ...
                                           dateDays.(subjectIdx)(dateIdx), partIdx, bPrint)
                end
            end
        end
    end
end