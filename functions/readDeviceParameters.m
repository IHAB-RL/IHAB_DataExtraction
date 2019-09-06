function [] = readDeviceParameters(obj)

% Read the Device Id, App version and Survey URI from first Questionnaire 
% file in Quest Folder. -> Every participant used a single device during 
% the study (phone UUID) and the same questionnaire is applied.

fprintf('\t.reading device parameters -');
obj.hProgressCommandLine.startTimer();

sFolder = obj.stSubject.Folder;
sFolderQuest = [sFolder, filesep, obj.stSubject.Name, '_Quest'];

% Get contents of Quest folder
stDir = dir(sFolderQuest);
stDir(1:2) = [];
if ~isempty(stDir)
    sFileQuest = [sFolderQuest, filesep, stDir(1).name];
    
    fid = fopen(sFileQuest, 'r');
    
    % Extracting Survey URI
    sQuestionnaireURI = '';
    while isempty(sQuestionnaireURI)
        sContents = fgetl(fid);
        if contains(sContents, 'survey_uri="')
            vPos = strfind(sContents, '"');
            sQuestionnaireURI = sContents(vPos(1)+1:vPos(2)-1);
        end
    end
    
    % Extracting Device ID
    sDeviceId = '';
    while isempty(sDeviceId)
        sContents = fgetl(fid);
        if contains(sContents, 'device_id="')
            vPos = strfind(sContents, '"');
            sDeviceId = sContents(vPos(1)+1:vPos(2)-1);
        end
    end
    
    % Extracting App Version
    sAppVersion = '';
    while isempty(sAppVersion)
        sContents = fgetl(fid);
        if contains(sContents, 'app_version="')
            vPos = strfind(sContents, '"');
            sAppVersion = sContents(vPos(1)+1:vPos(2)-1);
        end
    end
    
    fclose(fid);
    
else
    
    sDeviceId = '';
    sAppVersion = '';
    sQuestionnaireURI = '';
    
end

obj.stAnalysis.DeviceID = sDeviceId;
obj.stAnalysis.AppVersion = sAppVersion;
obj.stAnalysis.QuestionnaireURI = sQuestionnaireURI;

obj.hProgressCommandLine.stopTimer();

end

% EOF