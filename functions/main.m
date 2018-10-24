function bSuccess = main(szSubjectID, obj)

% Check if subject exists and get the folder name

stSubject = struct('FolderName', obj.stSubject.Folder, 'SubjectID', obj.stSubject.Name);

if ~isempty(stSubject)
    
    if exist(['cache', filesep, szSubjectID, '.mat'],'file')
        load(['cache', filesep, szSubjectID, '.mat'], 'configStruct', 'stSubject');
        obj.cListQuestionnaire{end+1} = sprintf('\t.using cached data');
        obj.hListBox.Value = obj.cListQuestionnaire;
    else
        
        
        %% Generate questionnaires table
       
                
        obj.cListQuestionnaire{end+1} = sprintf('\t.importing questionnaires -');
        obj.hListBox.Value = obj.cListQuestionnaire;
        
        obj.hProgress.startTimer();
        import_EMA2018(obj);
        obj.hProgress.stopTimer();
        
        
        %% Validate data
        
        
        obj.cListQuestionnaire{end} = sprintf('\t.checking data integrity -');
        obj.hListBox.Value = obj.cListQuestionnaire;
        
        % First: Check for broken data
        obj.hProgress.startTimer();
        checkDataIntegrity(obj, szSubjectID);
        obj.hProgress.stopTimer();
        
        % These parameters are for the validation check
        % CHANGE PARAMETERS IF NECESSARY
        configStruct.lowerBinCohe = 1100;
        configStruct.upperBinCohe = 3000;
        configStruct.upperThresholdCohe = 0.9;
        configStruct.upperThresholdRMS = -6; % -6 dB
        configStruct.lowerThresholdRMS = -70; % -70 dB
        configStruct.errorTolerance = 0.05; % 5 percent
        
        obj.cListQuestionnaire{end} = sprintf('\t.validating subject -');
        obj.hListBox.Value = obj.cListQuestionnaire;
        
        obj.hProgress.startTimer();
        validatesubject(obj, configStruct);
        obj.hProgress.stopTimer();
        
        
        if ~exist('cache', 'dir')
            mkdir('cache');
        end
        
        if ~exist(['cache', filesep, szSubjectID], 'file')
            save(['cache', filesep, szSubjectID], 'configStruct', 'stSubject');
        end
        
        %% Overview
    end
    
    % Black/white printing
    isPrintMode = true;

    bSuccess = analyseSubjectsResponses(szSubjectID, isPrintMode, 1, obj);
    
end

% EOF