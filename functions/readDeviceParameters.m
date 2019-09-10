function [] = readDeviceParameters(obj, varargin)

% Read the Device Id, App version and Survey URI from first Questionnaire
% file in Quest Folder. -> Every participant used a single device during
% the study (phone UUID) and the same questionnaire is applied.

fprintf('\t.reading device parameters -');
obj.hProgressCommandLine.startTimer();

sFolder = obj.stSubject.Folder;

if obj.isHallo % Data results from "HALLO" study
    
    sFolderQuest = [sFolder, filesep, obj.stSubject.Name,'_Mobeval'];
    
    % Two different structures exist in HALLO - this tackles both of them
    stDir = rdir([sFolderQuest, filesep, '**\*.xml']);
    sProfile = '(\w){8}-(\w){4}-(\w){4}-(\w){4}-(\w){12}.xml';
    
    for iDir = 1:length(stDir)
        
        cContents = regexp(stDir(iDir).name, sProfile, 'tokens');
        if ~isempty(cContents)
            sFolderQuest = stDir(iDir).folder;
            continue;
        end
    end
    
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
        
        % Jump to beginning of the file
        fseek(fid,0,-1);
        
        % Extracting Device ID
        
        sDeviceId = '';
        while isempty(sDeviceId)
            sContents = fgetl(fid);
            sProfile = '(\w)*question_id="10816">(\w)*</value>(\w)*';
            cContents = regexp(sContents, sProfile, 'tokens');
            sDeviceId = cContents{1}{2};
        end
        
        if isempty(sDeviceId)
            sDeviceId = 'HalloDevice';
        end
        
        % No App Version included in HALLO design
        sAppVersion = '';
        
    else
        sDeviceId = '';
        sAppVersion = '';
        sQuestionnaireURI = '';
    end
    
    % Close file
    fclose(fid);
    
else % Data results from "IHAB" study
    
    sFolderQuest = [sFolder, filesep, obj.stSubject.Name, '_Quest'];
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
        
        % Jump to beginning of the file
        fseek(fid,0,-1);
        
        % Extracting Device ID
        
        if nargin == 2 % Explicit EMA run is given for tabular system ID
            
            iEMA = varargin{1};
            if iEMA > 2 || iEMA < 1
               error('EMA parameter out of bounds.');
            end
            
            stContents = load('IdentificationProbandSystem_Maps.mat');
            
            sName = obj.stSubject.Name;
            if iEMA == 1
                if isKey(stContents.mapSubject_1, sName)
                    sDeviceId = stContents.mapSubject_1(sName);
                else
                    sDeviceId = 'Subject not in table';
                end
            else
                if isKey(stContents.mapSubject_2, sName)
                    sDeviceId = stContents.mapSubject_2(sName);
                else
                    sDeviceId = 'Subject not in table';
                end
            end
            
        else % No explicit EMA run is given so system ID resorts from AndroidID
            
            % Jump to beginning of the file
            fseek(fid,0,-1);
            
            sDeviceId = '';
            while isempty(sDeviceId)
                sContents = fgetl(fid);
                if contains(sContents, 'device_id="')
                    vPos = strfind(sContents, '"');
                    sDeviceId = sContents(vPos(1)+1:vPos(2)-1);
                end
            end
        end
        
        % Jump to beginning of the file
        fseek(fid,0,-1);
        
        % Extracting App Version
        
        sAppVersion = '';
        
        while isempty(sAppVersion)
            sContents = fgetl(fid);
            if contains(sContents, 'app_version="')
                vPos = strfind(sContents, '"');
                sAppVersion = sContents(vPos(1)+1:vPos(2)-1);
            end
        end
        
    else
        
        sDeviceId = '';
        sAppVersion = '';
        sQuestionnaireURI = '';
        
    end
    
    % Close file
    fclose(fid);
    
end

obj.stAnalysis.DeviceID = sDeviceId;
obj.stAnalysis.AppVersion = sAppVersion;
obj.stAnalysis.QuestionnaireURI = sQuestionnaireURI;

obj.hProgressCommandLine.stopTimer();

% EOF