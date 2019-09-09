
classdef IHABdata < handle
    
    properties
        
        stSubject;
        sFolderMain = pwd;
        sFolder_Latex = [pwd, filesep, 'functions', filesep, 'latex'];
        sFileName_Preferences = 'preferences.txt';
        sLogFile = 'log2.txt';
        stPreferences;
        stAnalysis;
        stComparison;
        stPrint;
        stLaTeXCommands;
        bIncludeObjectiveData = false;
        bTitles = false;
        nCompare_Run;
        
        isParallel = true;
        isBatch = false;
        
        sTitleFig1 = 'IHAB data';
        sTitleFig2 = 'Legend';
        sTitleFig3 = 'Change Minimum Part Length';
        sLabelDate = 'Date [yymmdd]:';
        sLabelExperimenter = 'Experimenter:';
        sLabelSubject = 'Subject:';
        sLabelLogData = 'Log data:';
        sLabelFeatureData = 'Feature data:'
        sLabelQuestionnaires = 'Questionnaires:';
        sLabelMinPartLength = 'Min. part length:';
        
        sLabel_Button_Compare = 'Compare';
        sLabel_Button_Open = 'Open';
        sLabel_Button_Clear = 'Clear';
        sLabel_Button_Load = 'Load Data';
        sLabel_Button_Kill = 'Kill App';
        sLabel_Button_Reboot = 'Reboot';
        sLabel_Button_Erase = 'Erase Data';
        sLabel_Button_Create = 'Create';
        sLabel_Button_Analyse = 'Analyse';
        
        sLabelTab1 = 'Statistics';
        sLabelTab2 = 'User data';
        sLabelTab3 = 'Phone actions';
        sLabelTab4 = 'Output';
        sLabelTab5 = 'Activity';
        
        sStateCharging = 'Charging';
        sStateConnecting = 'Connecting';
        sStateError = 'Error';
        sStateProposing = 'Proposing';
        sStateQuest = 'Questionnaire';
        sStateRunning = 'Running';
        cStates = {'Charging', 'Error', 'Proposing',...
            'Connecting', 'Running', 'Quest'};
        
        sMessage_Calculating = 'calculating';
        
        sLabelButton_Legend_Close = 'Close';
        sLabelButton_PartLength_Close = 'Enter';
        
        nDivision_Horizontal = 20;
        nDivision_Vertical = 10;
        nTextHeight = 20;
        nTitleHeight = 20;
        nButtonHeight = 30;
        nButtonWidth = 76;
        nStatHeight = 30;
        nStatWidth = 116;
        nPatchHeight = 40;
        nPatchWidth = 40;
        nLegendLabelWidth = 140;
        nLegendLabelHeight = 28;
        nCalculatingWidth = 60;
        nCalculatingHeight = 20;
        
        mColors;
        
        hProgress;
        hProgressCommandLine;
        
        vProportions = zeros(6,1);
        vProportions_Sorted;
        vStateNum = 1:6;
        vStateNumSorted;
        
        hFig1;
        hFig2;
        hFig3;
        hTab1;
        hTab2;
        hTab3;
        hTab4;
        hTab5;
        hOverview;
        
        % Tab 1
        hStat_Log;
        hStat_Features;
        hStat_Quests;
        hLabel_Log;
        hLabel_Features;
        hLabel_Quests;
        
        % Tab 2
        hButton_Open;
        hButton_Clear;
        hEditSubject;
        hEditDate;
        hEditExperimenter;
        hLabelSubject;
        hLabelDate;
        hLabelExperimenter;
        hLabel_MinPartLength;
        hButton_Create;
        hButton_Analyse;
        hButton_MinPartLength;
        hButton_Compare;
        
        % Tab 3
        hButton_Load;
        hButton_KillApp;
        hButton_Reboot;
        hButton_Erase;
        
        % Tab 4
        hListBox;
        
        % Tab 5
        hAxes;
        hLabel_Calculating;
        hHotspot_Legend;
        
        % Legend Figure
        hButton_Legend_Close;
        hPatch_Legend_Charging;
        hPatch_Legend_Connecting;
        hPatch_Legend_Error;
        hPatch_Legend_Proposing;
        hPatch_Legend_Quest;
        hPatch_Legend_Running;
        hLabel_Legend_Charging;
        hLabel_Legend_Connecting;
        hLabel_Legend_Error;
        hLabel_Legend_Proposing;
        hLabel_Legend_Quest;
        hLabel_Legend_Running;
        
        % Part Length Figure
        hButton_PartLength_Enter;
        hEditText_PartLength;
        hLabel_PartLength;
        sLabel_MinPartLength_Text = ...
            sprintf('Please enter minimum\npart length [min] (-1 -> n/a):');
        sLabel_MinPartLength_Enter = 'Enter';
        
        cListQuestionnaire = {' '};
        
        hButtonClose;
        hButtonCloseFig2;
        
        hDialogData;
        
        vScreenSize;
        nHeightFig1 = 480;
        nWidthFig1 = 640;
        nHeightLegend = 400;
        nWidthLegend = 300;
        nHeight_PartLength;
        nWidth_PartLength;
        
        stEditText;
        
        bNewFolder = 0;
        bLog = 0;
        bFeatures = 0;
        bQuest = 0;
        bClear = 1;
        isDone;
        prefix;
    end
    
    methods
        function [obj] = IHABdata(varargin)
            
            checkPrerequisites();
            
            if obj.isParallel && isempty(gcp('nocreate'))
                myCluster = parcluster();
                myCluster.NumWorkers = 12;
                myPool = parpool(myCluster);
            end
            
            obj.nHeight_PartLength = 3*obj.nDivision_Vertical + 2*obj.nButtonHeight;
            obj.nWidth_PartLength = 3*obj.nDivision_Horizontal + 2*obj.nButtonWidth;
            
            addpath(genpath('functions'));
            
            if ismac
                obj.prefix = '/usr/local/bin/';
            else
                obj.prefix = '';
            end
            
            set(0,'Units','Pixels') ;
            obj.vScreenSize = get(0,'screensize');
            
            obj.stSubject = struct( ...
                'Name', [], ...
                'Date', [], ...
                'Experimenter', [], ...
                'Folder', [], ...
                'Appendix', '-', ...
                'Code', []);
            
            obj.stEditText = struct( ...
                'EditSubject', [],...
                'EditDate', [],...
                'EditExperimenter', []);
            
            obj.stPreferences = struct( ...
                'MinPartLength', [], ...
                'Test', []);
            
            obj.stAnalysis = struct( ...
                'NumberOfDays', [], ...
                'Dates', [], ...
                'TimePerDay', [], ...
                'NumberOfParts', [], ...
                'NumberOfQuestionnaires', []);
            
            obj.stLaTeXCommands = struct( ...
                'termSubject', 'TeilnehmerIn', ...
                'termUpdated', 'Stand', ...
                'termComments', 'Bemerkungen', ...
                'termComparison', 'Vergleich', ...
                'termPage', 'Seite', ...
                'termProfile', 'Persönliches Hörprofil', ...
                'termInstitute', 'Projekt IHAB-rl');
            
            obj.stPrint = struct( ...
                'Width', [6, 6]/2.54, ...
                'Height', [15, 3.5]/2.54, ...
                'AxesLineWidth', 0.75, ...
                'FontSize', 9, ...
                'LineWidth', 1.5, ...
                'MarkerSize', 8, ...
                'InvertHardcopy', 'on', ...
                'PaperUnits', 'inches', ...
                'DPI', 300, ...
                'MaxCharactersInLabel', 20);
            
            obj.stComparison = struct( ...
                'Folder', [], ...
                'Analysis' , []);
            
            obj.mColors = getColors();
            
            obj.getPreferencesFromFile();
            
            if nargin > 0
                
                try 
                    
                    obj.hProgressCommandLine = BlindProgressCommandLine();

                    sFolder = varargin{1};

                    openSubjectFolderCommandLine(obj, sFolder);

                    examineObjectiveData(obj);

                    generateOverviewCommandLine(obj);

                    if (nargin == 2)
                        iEMA = varargin{2};
                        readDeviceParameters(obj, iEMA);
                    else
                        readDeviceParameters(obj);
                    end

                    fprintf('\nFinished\n\n');
                    fprintf(['Information on available objective data is ',...
                        'found in {obj}.stAnalysis\n']);
                
                catch Exception
                    fprintf('Exception %s caught.', Exception); 
                end
                
                obj.hProgressCommandLine.killTimer();
                
            else
                
                % Create the GUI
                obj.gui();
                
            end
            
        end
        
        function [] = gui(obj)
            
            % Main Window
            
            obj.hFig1 = uifigure();
            obj.hFig1.Position = [(obj.vScreenSize(3)-obj.nWidthFig1)/2,...
                (obj.vScreenSize(4)-obj.nHeightFig1)/2, obj.nWidthFig1, obj.nHeightFig1];
            obj.hFig1.Name = obj.sTitleFig1;
            obj.hFig1.Resize = 'Off';
            
            % Tabs
            
            obj.hTab1 = uipanel(obj.hFig1);
            obj.hTab1.Units = 'Pixel';
            obj.hTab1.Position = [0,5/6*obj.nHeightFig1-6,...
                2/3*obj.nWidthFig1,1/6*obj.nHeightFig1+6];
            obj.hTab1.Title = obj.sLabelTab1;
            
            obj.hTab3 = uipanel(obj.hFig1);
            obj.hTab3.Units = 'Pixel';
            obj.hTab3.Position = [2/3*obj.nWidthFig1-1, 0,...
                1/3*obj.nWidthFig1+2,...
                2*obj.nButtonHeight + 3*obj.nDivision_Vertical + obj.nTitleHeight];
            obj.hTab3.Title = obj.sLabelTab3;
            
            obj.hTab4 = uipanel(obj.hFig1);
            obj.hTab4.Units = 'Pixel';
            obj.hTab4.Position = [0,0,...
                2/3*obj.nWidthFig1, 2/6*obj.nHeightFig1];
            obj.hTab4.Title = obj.sLabelTab4;
            
            obj.hTab2 = uipanel(obj.hFig1);
            obj.hTab2.Units = 'Pixel';
            obj.hTab2.Position = [2/3*obj.nWidthFig1-1,...
                obj.hTab3.Position(4)-1, 1/3*obj.nWidthFig1+2,...
                obj.hFig1.Position(4) - obj.hTab3.Position(4)+1];
            obj.hTab2.Title = obj.sLabelTab2;
            
            obj.hTab5 = uipanel(obj.hFig1);
            obj.hTab5.Units = 'Pixel';
            obj.hTab5.Position = [0, obj.nHeightFig1/3-1,...
                2/3*obj.nWidthFig1, 3/6*obj.nHeightFig1];
            obj.hTab5.Title = obj.sLabelTab5;
            
            % Statistics Tab 1
            
            obj.hLabel_Log = uilabel(obj.hTab1);
            obj.hLabel_Log.Position = [obj.nDivision_Horizontal,...
                obj.nDivision_Vertical + obj.nStatHeight,...
                obj.nStatWidth, obj.nTextHeight];
            obj.hLabel_Log.Text = obj.sLabelLogData;
            
            obj.hStat_Log = uieditfield(obj.hTab1);
            obj.hStat_Log.Position = [obj.nDivision_Horizontal,...
                obj.nDivision_Vertical,...
                obj.nStatWidth, obj.nStatHeight];
            obj.hStat_Log.Editable = 'Off';
            obj.hStat_Log.Value = '';
            
            obj.hLabel_Features = uilabel(obj.hTab1);
            obj.hLabel_Features.Position = [2*obj.nDivision_Horizontal+obj.nStatWidth,...
                obj.nDivision_Vertical + obj.nStatHeight,...
                obj.nStatWidth, obj.nTextHeight];
            obj.hLabel_Features.Text = obj.sLabelFeatureData;
            
            obj.hStat_Features = uieditfield(obj.hTab1);
            obj.hStat_Features.Position = [2*obj.nDivision_Horizontal+obj.nStatWidth,...
                obj.nDivision_Vertical, obj.nStatWidth, obj.nStatHeight];
            obj.hStat_Features.Editable = 'Off';
            obj.hStat_Features.Value = '';
            
            obj.hLabel_Quests = uilabel(obj.hTab1);
            obj.hLabel_Quests.Position = [3*obj.nDivision_Horizontal+2*obj.nStatWidth,...
                obj.nDivision_Vertical + obj.nStatHeight,...
                obj.nStatWidth, obj.nTextHeight];
            obj.hLabel_Quests.Text = obj.sLabelQuestionnaires;
            
            obj.hStat_Quests  = uieditfield(obj.hTab1);
            obj.hStat_Quests.Position = [3*obj.nDivision_Horizontal+2*obj.nStatWidth,...
                obj.nDivision_Vertical, obj.nStatWidth, obj.nStatHeight];
            obj.hStat_Quests.Editable = 'Off';
            obj.hStat_Quests.Value = '';
            
            % User Data Tab 2
            
            % Button "Open"
            obj.hButton_Open = uibutton(obj.hTab2);
            obj.hButton_Open.Position = [obj.nDivision_Horizontal,...
                4*obj.nDivision_Vertical + 7*obj.nButtonHeight + 44,...
                obj.nButtonWidth,...
                obj.nButtonHeight];
            obj.hButton_Open.Text = obj.sLabel_Button_Open;
            obj.hButton_Open.ButtonPushedFcn = @obj.callbackOpen;
            
            % Button "Clear"
            obj.hButton_Clear = uibutton(obj.hTab2);
            obj.hButton_Clear.Position = [2*obj.nDivision_Horizontal + obj.nButtonWidth,...
                4*obj.nDivision_Vertical + 7*obj.nButtonHeight + 44,...
                obj.nButtonWidth,...
                obj.nButtonHeight];
            obj.hButton_Clear.Text = obj.sLabel_Button_Clear;
            obj.hButton_Clear.ButtonPushedFcn = @obj.clearEntries;
            
            % Text field "Subject"
            obj.hEditSubject = uieditfield(obj.hTab2);
            obj.hEditSubject.Position = [obj.nDivision_Horizontal,...
                3*obj.nDivision_Vertical + 5*obj.nButtonHeight + 44,...
                obj.hTab2.Position(3) - 2*obj.nDivision_Horizontal,...
                obj.nButtonHeight];
            obj.hEditSubject.Value = '';
            obj.hEditSubject.ValueChangingFcn = @obj.callbackEditField;
            obj.hEditSubject.Tag = 'EditSubject';
            
            obj.hLabelSubject = uilabel(obj.hTab2);
            obj.hLabelSubject.Position = [obj.nDivision_Horizontal,...
                3*obj.nDivision_Vertical + 6*obj.nButtonHeight + 44,...
                obj.hTab2.Position(3) - 2*obj.nDivision_Horizontal,...
                obj.nTextHeight];
            obj.hLabelSubject.Text = obj.sLabelSubject;
            
            % Text field "Date"
            obj.hEditDate = uieditfield(obj.hTab2);
            obj.hEditDate.Position = [obj.nDivision_Horizontal,...
                3*obj.nDivision_Vertical + 3*obj.nButtonHeight + 44,...
                obj.hTab2.Position(3) - 2*obj.nDivision_Horizontal,...
                obj.nButtonHeight];
            obj.hEditDate.Value = '';
            obj.hEditDate.ValueChangingFcn = @obj.callbackEditField;
            obj.hEditDate.Tag = 'EditDate';
            
            obj.hLabelDate = uilabel(obj.hTab2);
            obj.hLabelDate.Position = [obj.nDivision_Horizontal,...
                3*obj.nDivision_Vertical + 4*obj.nButtonHeight + 44,...
                obj.hTab2.Position(3) - 2*obj.nDivision_Horizontal,...
                obj.nTextHeight];
            obj.hLabelDate.Text = obj.sLabelDate;
            
            % Text field "Experimenter"
            obj.hEditExperimenter = uieditfield(obj.hTab2);
            obj.hEditExperimenter.Position = [obj.nDivision_Horizontal,...
                3*obj.nDivision_Vertical + obj.nButtonHeight + 44,...
                obj.hTab2.Position(3) - 2*obj.nDivision_Horizontal,...
                obj.nButtonHeight];
            obj.hEditExperimenter.Value = '';
            obj.hEditExperimenter.ValueChangingFcn = @obj.callbackEditField;
            obj.hEditExperimenter.Tag = 'EditExperimenter';
            
            obj.hLabelExperimenter = uilabel(obj.hTab2);
            obj.hLabelExperimenter.Position = [obj.nDivision_Horizontal,...
                3*obj.nDivision_Vertical + 2*obj.nButtonHeight + 44,...
                obj.hTab2.Position(3) - 2*obj.nDivision_Horizontal,...
                obj.nTextHeight];
            obj.hLabelExperimenter.Text = obj.sLabelExperimenter;
            
            % Button "Create"
            obj.hButton_Create = uibutton(obj.hTab2);
            obj.hButton_Create.Position = [obj.nDivision_Horizontal,...
                obj.nDivision_Vertical + 44+4, ...
                obj.nButtonWidth,...
                obj.nButtonHeight];
            obj.hButton_Create.Text = obj.sLabel_Button_Create;
            obj.hButton_Create.Enable = 'Off';
            obj.hButton_Create.ButtonPushedFcn = @obj.createNewSubject;
            
            % Button "Analyse"
            obj.hButton_Analyse = uibutton(obj.hTab2);
            obj.hButton_Analyse.Position = [2*obj.nDivision_Horizontal + obj.nButtonWidth,...
                obj.nDivision_Vertical + 44+4,...
                obj.nButtonWidth, obj.nButtonHeight];
            obj.hButton_Analyse.Text = obj.sLabel_Button_Analyse;
            obj.hButton_Analyse.Enable = 'Off';
            obj.hButton_Analyse.ButtonPushedFcn = @obj.callbackAnalyseData;
            
            % Text Min Part Length
            obj.hLabel_MinPartLength = uilabel(obj.hTab2);
            obj.hLabel_MinPartLength.Position = [2*obj.nDivision_Horizontal + obj.nButtonWidth,...
                obj.nDivision_Vertical - 4,...
                obj.nButtonWidth+20,...
                obj.nButtonHeight];
            obj.hLabel_MinPartLength.Text = 'MPL:';
            %             obj.hLabel_MinPartLength.Tooltip = 'Minimum Part Length';
            
            % Button "Compare"
            obj.hButton_Compare = uibutton(obj.hTab2);
            obj.hButton_Compare.Position = [obj.nDivision_Horizontal,...
                obj.nDivision_Vertical + 4, ...
                obj.nButtonWidth,...
                obj.nButtonHeight];
            obj.hButton_Compare.Text = obj.sLabel_Button_Compare;
            obj.hButton_Compare.Enable = 'Off';
            obj.hButton_Compare.ButtonPushedFcn = @obj.callbackCompareEMA;
            
            % Button "Min Part Length"
            obj.hButton_MinPartLength = uibutton(obj.hTab2);
            obj.hButton_MinPartLength.Position = [2*obj.nDivision_Horizontal + obj.nButtonWidth + 30,...
                obj.nDivision_Vertical + 4,...
                obj.nButtonWidth - 30, obj.nButtonHeight];
            obj.hButton_MinPartLength.Text = num2str(obj.stPreferences.MinPartLength);
            obj.hButton_MinPartLength.ButtonPushedFcn = @obj.callbackMinPartLength;
            
            % Phone Actions Tab 3
            
            % Button "Reboot"
            obj.hButton_Reboot = uibutton(obj.hTab3);
            obj.hButton_Reboot.Position = [obj.nDivision_Horizontal,...
                obj.nDivision_Vertical,...
                obj.nButtonWidth ,...
                obj.nButtonHeight];
            obj.hButton_Reboot.Text = 'Reboot';
            obj.hButton_Reboot.Enable = 'On';
            obj.hButton_Reboot.ButtonPushedFcn = @obj.callbackRebootPhone;
            
            % Button "Erase Data"
            obj.hButton_Erase = uibutton(obj.hTab3);
            obj.hButton_Erase.Position = [2*obj.nDivision_Horizontal + obj.nButtonWidth,...
                obj.nDivision_Vertical,...
                obj.nButtonWidth ,...
                obj.nButtonHeight];
            obj.hButton_Erase.Text = 'Erase Data';
            obj.hButton_Erase.Enable = 'On';
            obj.hButton_Erase.ButtonPushedFcn = @obj.callbackEraseData;
            
            % Button "Load Data"
            obj.hButton_Load = uibutton(obj.hTab3);
            obj.hButton_Load.Position = [obj.nDivision_Horizontal,...
                2*obj.nDivision_Vertical + obj.nButtonHeight,...
                obj.nButtonWidth ,...
                obj.nButtonHeight];
            obj.hButton_Load.Text = 'Load Data';
            obj.hButton_Load.Enable = 'On';
            obj.hButton_Load.ButtonPushedFcn = @obj.callbackLoadData;
            
            % Button "Kill App"
            obj.hButton_KillApp = uibutton(obj.hTab3);
            obj.hButton_KillApp.Position =...
                [2*obj.nDivision_Horizontal + obj.nButtonWidth,...
                2*obj.nDivision_Vertical + obj.nButtonHeight,...
                obj.nButtonWidth ,...
                obj.nButtonHeight];
            obj.hButton_KillApp.Text = 'KillApp';
            obj.hButton_KillApp.Enable = 'On';
            obj.hButton_KillApp.ButtonPushedFcn = @obj.callbackKillApp;
            
            % Text Output Tab 4
            
            obj.hListBox = uitextarea(obj.hTab4);
            obj.hListBox.Position = [0,0,...
                obj.hTab4.Position(3),obj.hTab4.Position(4)-obj.nTextHeight+1];
            obj.hListBox.BackgroundColor = 'white';
            obj.hListBox.Editable = 'Off';
            obj.cListQuestionnaire = {''};
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            % Axes
            obj.hAxes = uiaxes(obj.hTab5);
            obj.hAxes.Units = 'Pixels';
            obj.hAxes.Position = [0,0,obj.hTab5.Position(3), obj.hTab5.Position(4)-20];
            obj.hAxes.Visible = 'Off';
            obj.bClear = 0;
            
            % calculating
            obj.hLabel_Calculating = uilabel(obj.hTab5);
            obj.hLabel_Calculating.Position = [(obj.hTab5.Position(3)-obj.nCalculatingWidth)/2,...
                (obj.hTab5.Position(4)-obj.nCalculatingHeight)/2,...
                obj.nCalculatingWidth, obj.nCalculatingHeight];
            obj.hLabel_Calculating.Text = obj.sMessage_Calculating;
            obj.hLabel_Calculating.Visible = 'Off';
            obj.hLabel_Calculating.HorizontalAlignment = 'center';
            obj.hLabel_Calculating.VerticalAlignment = 'center';
            
        end
        
        function bDeviceFound = checkForDevice(obj)
            % make sure only one device is connected
            sTestDevices = [obj.prefix,'adb devices'];
            [~, sList] = system(sTestDevices);
            if (length(splitlines(sList)) > 4)
                errordlg('Too many devices connected.', 'Error');
                bDeviceFound = 0;
            elseif (length(splitlines(sList)) < 4)
                errordlg('No device connected.', 'Error');
                bDeviceFound = 0;
            else
                bDeviceFound = 1;
            end
        end
        
        function bEntriesConform = checkEntryConformity(obj)
            
            bEntriesConform = 1;
            
            if length(obj.stEditText.EditSubject) ~= 8
                warndlg('Subject name must be 8 characters', 'Invalid entry');
                bEntriesConform = 0;
                return;
            end
            
            if length(obj.stEditText.EditDate) ~= 6
                warndlg('Date must be [yymmdd]', 'Invalid entry');
                bEntriesConform = 0;
                return;
            end
            
            if length(obj.stEditText.EditExperimenter) ~= 2
                warndlg('Experimenter code must be 2 characters', 'Invalid entry');
                bEntriesConform = 0;
                return;
            end
            
        end
        
        function [] = createNewSubject(obj, ~, ~)
            
            obj.isBatch = false;
            
            if ~obj.checkEntryConformity()
                return;
            end
            
            sBaseFolder = uigetdir();
            
            sSubjectFolder = [sBaseFolder, filesep, ...
                obj.hEditSubject.Value, '_', obj.hEditDate.Value, ...
                '_', obj.hEditExperimenter.Value];
            
            if isempty(obj.hEditSubject.Value) ||...
                    isempty(obj.hEditDate.Value) ||...
                    isempty(obj.hEditExperimenter.Value)
                warndlg('Please enter all subject data.');
            elseif exist(sSubjectFolder, 'dir') == 7
                
                cNewEntry = splitStringForTextBox(...
                    ['[  ] Subject folder already exists: "', ...
                    obj.stSubject.Folder, '"']);
                
                for iLine = 1:length(cNewEntry)
                    obj.cListQuestionnaire{end+1} = cNewEntry{iLine};
                end
                obj.hListBox.Value = obj.cListQuestionnaire;
                
                obj.hEditSubject.Enable = 'On';
                obj.hEditDate.Enable = 'On';
                obj.hEditExperimenter.Enable = 'On';
                
            else
                obj.stSubject.Name = obj.hEditSubject.Value;
                obj.stSubject.Date = obj.hEditDate.Value;
                obj.stSubject.Experimenter = obj.hEditExperimenter.Value;
                obj.stSubject.Folder = sSubjectFolder;
                obj.stSubject.Code = [obj.stSubject.Name, '_' , ...
                    obj.stSubject.Date, '_', obj.stSubject.Experimenter];
                system(['mkdir ', '"', obj.stSubject.Folder, '"']);
                obj.bNewFolder = 1;
                
                
                cNewEntry = splitStringForTextBox(...
                    ['[x] New subject folder created: "', ...
                    obj.stSubject.Folder, '"']);
                
                for iLine = 1:length(cNewEntry)
                    obj.cListQuestionnaire{end+1} = cNewEntry{iLine};
                end
                obj.hListBox.Value = obj.cListQuestionnaire;
                
                obj.hEditSubject.Enable = 'Off';
                obj.hEditDate.Enable = 'Off';
                obj.hEditExperimenter.Enable = 'Off';
                
                obj.hButton_Create.Enable = 'Off';
                
            end
        end
        
        function [bEntries] = allEntries(obj, ~, ~)
            
            if ~isempty(obj.stEditText.EditSubject)...
                    && ~isempty(obj.stEditText.EditDate)...
                    && ~isempty(obj.stEditText.EditExperimenter)
                bEntries = 1;
            else
                bEntries = 0;
            end
        end
        
        function [bData] = isDataComplete(obj, ~, ~)
            if (obj.bLog && obj.bFeatures && obj.bQuest)
                bData = 1;
            else
                bData = 0;
            end
        end
        
        function [bData] = isDataCompleteEnoughForAnalysis(obj, ~, ~)
            if (obj.bFeatures && obj.bQuest)
                bData = 1;
            else
                bData = 0;
            end
        end
        
        function [] = callbackOpen(obj, ~, ~)
            obj.transferSubjectFolder();
        end
        
        
        function [] = transferSubjectFolder(obj, ~, ~)
            
            [sFolder] = uigetdir();
            
            cSubjectData = regexp(sFolder, ...
                '(\w)*(\w){8}_(\w){6}_(\w){2}(_)*(\w)*(_\w)*', 'tokens');
            
            if isempty(cSubjectData)
                obj.isBatch = true;
                obj.openBatchSubjectFolder(sFolder);
            else
                obj.isBatch = false;
                obj.openSubjectFolder(sFolder);
            end
            
        end
        
        function [] = openBatchSubjectFolder(obj, sFolder)
            
            % Obtain all Contents from given Folder
            stDir = dir(sFolder);
            stDir(1:2) = [];
            nDir = length(stDir);
            vErase = [];
            
            % Clear all Non-Directories from List
            for iDir = 1:nDir
                if ~stDir(iDir).isdir
                    vErase = [vErase, iDir];
                end
            end
            stDir(vErase) = [];
            nDir = length(stDir);
            
            % Iteration over all Folders
            for iDir = 1:nDir
                obj.openSubjectFolder([stDir(iDir).folder, filesep, stDir(iDir).name]);
                obj.callbackAnalyseData();
            end
            
            
        end
        
        function [] = openSubjectFolderCommandLine(obj, sFolder)
            
            % Automatically extract subject info from folder name
            
            cPathName = split(sFolder, '\');
            sInfo = cPathName{end};
            
            cSubjectData = regexp(sInfo, ...
                '(\w)*(\w){8}_(\w){6}_(\w){2}(_)*(\w)*(_\w)*', 'tokens');
            
            if isempty(cSubjectData{1}{5})
                cSubjectData = cSubjectData{1}(~cellfun('isempty',cSubjectData{1}));
            else
                obj.stSubject.Appendix = cSubjectData{1}{6};
                cSubjectData = {cSubjectData{1}{2:4}};
            end
            
            if isValidSubjectData(cSubjectData)
                
                obj.stSubject.Name = cSubjectData{1};
                obj.stSubject.Date = cSubjectData{2};
                obj.stSubject.Experimenter = cSubjectData{3};
                obj.stSubject.Folder = sFolder;
                obj.stSubject.Code = sInfo;
                
            else
                fprintf('Cannot read folder.\n');
                return;
            end
            
            % check for Log
            
            nLog = exist(fullfile(sFolder,'log2.txt'), 'file') == 2;
            if nLog
                fprintf('[x] Log data found.\n');
                obj.bLog = 1;
            else
                fprintf('[ ] No Log data was found.\n');
            end
            
            % check for questionnaires
            
            stQuestionnaires = dir([sFolder, filesep, cSubjectData{1}, '_Quest']);
            stQuestionnaires(1:2) = [];
            nQuestionnaires = length(stQuestionnaires);
            if nQuestionnaires >= 0
                fprintf('[x] Questionnaire data found.\n');
                obj.bQuest = 1;
            else
                fprintf('[ ] No Questionnaire data found.');
            end
            
            % check for feature data
            
            stFeatures = dir([sFolder, filesep, cSubjectData{1}, '_AkuData']);
            stFeatures(1:2) = [];
            nFeatures = length(stFeatures);
            if nFeatures >= 0
                fprintf('[x] Feature data found.\n');
                obj.bFeatures = 1;
            else
                fprintf('[ ] No Feature data found.\n');
            end
            
            if obj.isDataCompleteEnoughForAnalysis()
                fprintf('Data complete for analysis.\n\n');
            end
            
        end
        
        function [] = openSubjectFolder(obj, sFolder)
            
            if (sFolder == 0)
                return;
            end
            
            obj.clearEntries();
            
            if obj.isBatch
                obj.cListQuestionnaire{end} = '::: Batch processing. :::';
                obj.hListBox.Value = obj.cListQuestionnaire;
            end
            
            % Automatically extract subject info from folder name
            
            cPathName = split(sFolder, '\');
            sInfo = cPathName{end};
            
            cSubjectData = regexp(sInfo, ...
                '(\w)*(\w){8}_(\w){6}_(\w){2}(_)*(\w)*(_\w)*', 'tokens');
            
            if isempty(cSubjectData{1}{5})
                cSubjectData = cSubjectData{1}(~cellfun('isempty',cSubjectData{1}));
            else
                obj.stSubject.Appendix = cSubjectData{1}{6};
                cSubjectData = {cSubjectData{1}{2:4}};
            end
            
            if isValidSubjectData(cSubjectData)
                
                obj.stSubject.Name = cSubjectData{1};
                obj.stSubject.Date = cSubjectData{2};
                obj.stSubject.Experimenter = cSubjectData{3};
                obj.stSubject.Folder = sFolder;
                obj.stSubject.Code = sInfo;
                
                obj.hEditSubject.Value = obj.stSubject.Name;
                obj.hEditDate.Value = obj.stSubject.Date;
                obj.hEditExperimenter.Value = obj.stSubject.Experimenter;
                
                obj.hEditSubject.Editable = 'Off';
                obj.hEditDate.Editable = 'Off';
                obj.hEditExperimenter.Editable = 'Off';
                
                obj.hButton_Create.Enable = 'Off';
                
            else
                obj.cListQuestionnaire{end} = 'Cannot read folder.';
                obj.hListBox.Value = obj.cListQuestionnaire;
                return;
            end
            
            % check for Log
            
            nLog = exist(fullfile(sFolder,'log2.txt'), 'file') == 2;
            if nLog
                obj.hStat_Log.Value = 'present';
                obj.cListQuestionnaire{end+1} = '[x] Log data found.';
                obj.bLog = 1;
            else
                obj.cListQuestionnaire{end+1} = '[  ] No Log data was found.';
            end
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            % check for questionnaires
            
            stQuestionnaires = dir([sFolder, filesep, cSubjectData{1}, '_Quest']);
            stQuestionnaires(1:2) = [];
            nQuestionnaires = length(stQuestionnaires);
            if nQuestionnaires >= 0
                obj.hStat_Quests.Value = num2str(nQuestionnaires);
                obj.cListQuestionnaire{end+1} = '[x] Questionnaire data found.';
                obj.bQuest = 1;
            else
                obj.cListQuestionnaire{end+1} = '[  ] No Questionnaire data found.';
            end
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            % check for feature data
            
            stFeatures = dir([sFolder, filesep, cSubjectData{1}, '_AkuData']);
            stFeatures(1:2) = [];
            nFeatures = length(stFeatures);
            if nFeatures >= 0
                obj.hStat_Features.Value = num2str(nFeatures);
                obj.cListQuestionnaire{end+1} = '[x] Feature data found.';
                obj.bFeatures = 1;
            else
                obj.cListQuestionnaire{end+1} = '[  ] No Feature data found.';
            end
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            if obj.isDataCompleteEnoughForAnalysis()
                obj.hButton_Analyse.Enable = 'On';
                obj.hButton_Compare.Enable = 'On';
            end
            
            if obj.bLog
                obj.extractConnection();
            end
            
        end
        
        function [] = clearEntries(obj, ~, ~)
            
            if ~obj.bClear
                try
                    delete(obj.hAxes.Children);
                end
                try
                    delete(obj.hAxes);
                end
                obj.bClear = 1;
                delete(timerfindall);
            end
            
            obj.hEditSubject.Value = '';
            obj.hLabelSubject.FontColor = [0,0,0];
            obj.hEditDate.Value = '';
            obj.hLabelDate.FontColor = [0,0,0];
            obj.hEditExperimenter.Value = '';
            obj.hLabelExperimenter.FontColor = [0,0,0];
            
            obj.cListQuestionnaire = {''};
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            obj.hStat_Log.Value = '';
            obj.hStat_Features.Value = '';
            obj.hStat_Quests.Value = '';
            
            obj.bLog = 0;
            obj.bQuest = 0;
            obj.bFeatures = 0;
            
            obj.stSubject = struct('Name', [],...
                'Date', [],...
                'Experimenter', [],...
                'Folder', [], ...
                'Appendix', '-');
            obj.bNewFolder = 0;
            
            obj.hEditSubject.Enable = 'On';
            obj.hEditDate.Enable = 'On';
            obj.hEditExperimenter.Enable = 'On';
            obj.hEditSubject.Editable = 'On';
            obj.hEditDate.Editable = 'On';
            obj.hEditExperimenter.Editable = 'On';
            
            obj.hButton_Create.Enable = 'Off';
            obj.hButton_Analyse.Enable = 'Off';
            obj.hButton_Compare.Enable = 'Off';
            
        end
        
        function [] = callbackEditField(obj, source, event)
            
            if (strcmp(source.Tag, 'EditSubject'))
                
                obj.stEditText.EditSubject = event.Value;
                if length(obj.stEditText.EditSubject) > 8
                    obj.hLabelSubject.FontColor = [1,0,0];
                else
                    obj.hLabelSubject.FontColor = [0,0,0];
                end
                
            elseif (strcmp(source.Tag, 'EditDate'))
                
                obj.stEditText.EditDate = event.Value;
                if length(obj.stEditText.EditDate) > 6
                    obj.hLabelDate.FontColor = [1,0,0];
                else
                    obj.hLabelDate.FontColor = [0,0,0];
                end
                
            elseif (strcmp(source.Tag, 'EditExperimenter'))
                
                obj.stEditText.EditExperimenter = event.Value;
                if length(obj.stEditText.EditExperimenter) > 2
                    obj.hLabelExperimenter.FontColor = [1,0,0];
                else
                    obj.hLabelExperimenter.FontColor = [0,0,0];
                end
                
            end
            
            if obj.allEntries()
                obj.hButton_Create.Enable = 'On';
                drawnow;
            else
                obj.hButton_Create.Enable = 'Off';
                drawnow;
            end
        end
        
        function [] = callbackRebootPhone(obj, ~, ~)
            
            if obj.checkForDevice()
                obj.rebootPhone();
            end
            
        end
        
        function [] = rebootPhone(obj, ~, ~)
            
            if obj.checkForDevice()
                [status, cmdout] = system('adb shell "su -c ps"');
                switch status
                    case 1
                        errordlg('No device found.');
                        return;
                    case 0
                        system('adb reboot');
                        obj.cListQuestionnaire{end+1} = 'Rebooting modile device.';
                        obj.hListBox.Value = obj.cListQuestionnaire;
                end
            end
        end
        
        function [] = callbackKillApp(obj, ~, ~)
            
            if obj.checkForDevice()
                obj.killApp();
            end
            
        end
        
        function [] = killApp(obj, ~, ~)
            
            if obj.checkForDevice()
                %                 [status, ~] = system('adb shell "su -c ps"');
                [status, ~] = system('adb root');
                switch status
                    case 1
                        errordlg('No device found.');
                        return;
                    case 0
                        system('adb shell am force-stop com.fragtest.android.pa');
                        obj.cListQuestionnaire{end+1} = 'Application was stopped.';
                        obj.hListBox.Value = obj.cListQuestionnaire;
                end
            end
        end
        
        function [] = callbackEraseData(obj, ~, ~)
            if obj.checkForDevice()
                status = questdlg('Would you like to erase all data on mobile device?', 'Erase all data?', 'yes', 'no', 'no');
                if strcmp(status, 'yes')
                    obj.eraseData();
                end
            end
        end
        
        function [] = eraseData(obj, ~, ~)
            
            vStatus = [];
            
            % Erase questionnaire data
            sCommand_erase_quest = [obj.prefix, 'adb shell rm -r /sdcard/ihab/data'];
            [status, ~] = system(sCommand_erase_quest);
            vStatus = [vStatus, status];
            
            sCommand_erase_quest = [obj.prefix, 'adb shell mkdir /sdcard/ihab/data'];
            [status, ~] = system(sCommand_erase_quest);
            vStatus = [vStatus, status];
            
            sCommand_erase_quest = [obj.prefix, 'adb -d shell "am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/ihab/data'];
            [status, ~] = system(sCommand_erase_quest);
            vStatus = [vStatus, status];
            
            % Erase feature data
            sCommand_erase_features = [obj.prefix, 'adb shell rm -r /sdcard/ihab/features'];
            [status, ~] = system(sCommand_erase_features);
            vStatus = [vStatus, status];
            
            sCommand_erase_features = [obj.prefix, 'adb shell mkdir /sdcard/ihab/features'];
            [status, ~] = system(sCommand_erase_features);
            vStatus = [vStatus, status];
            
            sCommand_erase_features = [obj.prefix, 'adb -d shell "am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/ihab/features'];
            [status, ~] = system(sCommand_erase_features);
            vStatus = [vStatus, status];
            
            % Erase cache data
            sCommand_erase_cache = [obj.prefix, 'adb shell rm -r /sdcard/ihab/cache'];
            [status, ~] = system(sCommand_erase_cache);
            vStatus = [vStatus, status];
            
            sCommand_erase_cache = [obj.prefix, 'adb -d shell "am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/ihab/cache'];
            [status, ~] = system(sCommand_erase_cache);
            vStatus = [vStatus, status];
            
            % Erase log data
            sCommand_erase_cache = [obj.prefix, 'adb shell rm -r /sdcard/ihab/log.txt'];
            [status, ~] = system(sCommand_erase_cache);
            vStatus = [vStatus, status];
            
            % Erase log2 data
            sCommand_erase_cache = [obj.prefix, 'adb shell rm -r /sdcard/ihab/log2.txt'];
            [status, ~] = system(sCommand_erase_cache);
            vStatus = [vStatus, status];
            
            sCommand_erase_cache = [obj.prefix, 'adb -d shell "am broadcast -a android.intent.action.MEDIA_MOUNTED -d file:///sdcard/ihab/log.txt'];
            [status, ~] = system(sCommand_erase_cache);
            vStatus = [vStatus, status];
            
            [~, cmdout] = system('adb shell ls /sdcard/ihab/features');
            vStatus = [vStatus, (~isempty(find(strfind(cmdout, 'No such file or directory'))) || ~isempty(cmdout))];
            
            %             [~, cmdout] = system('adb shell ls -l /sdcard/ihab');
            
            %             if contains(cmdout, obj.sLogFile)
            %                 tmp = splitlines(cmdout);
            %                 for iLine = 1:length(tmp)
            %                     if contains(tmp{iLine}, obj.sLogFile)
            %                         tmp2 = split(tmp{iLine});
            %                         vStatus = [vStatus, tmp2{4}<100];
            %                     end
            %                 end
            %             end
            
            if (mean(vStatus) == 0)
                obj.cListQuestionnaire{end+1} = 'Data was erased from mobile device.';
                obj.hListBox.Value = obj.cListQuestionnaire;
            end
            
        end
        
        function [] = callbackLoadData(obj, ~, ~)
            if obj.bNewFolder && obj.checkForDevice()
                obj.loadData();
            end
        end
        
        function [] = loadData(obj, ~, ~)
            
            sFolder_log = obj.stSubject.Folder;
            sFolder_quest = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '_Quest', '"'];
            sFolder_features = [obj.stSubject.Folder, filesep, obj.stSubject.Name, '_AkuData', '"'];
            
            system(['mkdir ', sFolder_quest]);
            system(['mkdir ', sFolder_features]);
            
            % Copy Log data
            
            sCommand_log = [obj.prefix, 'adb pull sdcard/ihab/log.txt ', sFolder_log];
            [status, ~] = system(sCommand_log);
            
            sCommand_log = [obj.prefix, 'adb pull sdcard/ihab/log2.txt ', sFolder_log];
            [status, ~] = system(sCommand_log);
            
            if (status == 0)
                obj.cListQuestionnaire{end+1} = '[x] Log data copied.';
                obj.hStat_Log.Value = 'present';
                obj.bLog = 1;
            else
                obj.cListQuestionnaire{end+1} = '[  ] No Log data was copied.';
                obj.hStat_Log.Value = 'none';
                obj.bLog = 0;
            end
            
            obj.cListQuestionnaire{end+1} = '';
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            % Copy Questionnaire data
            
            sCommand_quest_dir = [obj.prefix, 'adb ls sdcard/ihab/data'];
            [~, cmdout] = system(sCommand_quest_dir);
            cLines_quest = splitlines(cmdout);
            nLines_quest = length(cLines_quest);
            
            
            nApproxTime = 0;
            tic;
            
            vStatus = [];
            for iLine = 1:nLines_quest
                
                cLine = split(cLines_quest{iLine});
                if ((length(cLine) > 1) && (~strcmp(cLine{4},'.')) && (~strcmp(cLine{4},'..')))
                    
                    sCommand_quest = [obj.prefix, 'adb pull sdcard/ihab/data/',cLine{4},' ', sFolder_quest];
                    [status, ~] = system(sCommand_quest);
                    vStatus = [vStatus, status];
                    
                    nTimeTaken = toc;
                    nApproxTime = nTimeTaken/iLine*(nLines_quest - iLine);
                    
                    obj.cListQuestionnaire{end} = sprintf('Copying questionnaire files: %.0i%%, estimated time: %s', round(iLine/nLines_quest*100), secondsToTime(nApproxTime));
                    obj.hListBox.Value = obj.cListQuestionnaire;
                    pause(0.01);
                end
                
            end
            
            obj.cListQuestionnaire{end} = sprintf('Copying questionnaire files: %.0i%%', 100);
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            if (mean(vStatus) == 0)
                obj.cListQuestionnaire{end} = '[x] Questionnaire files copied.';
                obj.bQuest = 1;
                obj.hStat_Quests.Value = num2str(length(vStatus));
            else
                obj.cListQuestionnaire{end+1} = '[  ] No Questionnaire data was copied.';
                obj.hStat_Quests.Value = '0';
                obj.bQuest = 0;
            end
            
            obj.cListQuestionnaire{end+1} = '';
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            % copy feature data
            
            sCommand_quest_features = [obj.prefix, 'adb ls sdcard/ihab/features'];
            [~, cmdout] = system(sCommand_quest_features);
            cLines_features = splitlines(cmdout);
            nLines_features = length(cLines_features);
            
            obj.cListQuestionnaire{end} = 'Copying feature files: 0%';
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            nApproxTime = 0;
            tic;
            iCount = 0;
            
            vStatus = [];
            for iFeature = randperm(nLines_features)
                
                iCount = iCount + 1;
                
                cLine = split(cLines_features{iFeature});
                if ((length(cLine) > 1) && (~strcmp(cLine{4},'.')) && (~strcmp(cLine{4},'..')))
                    sCommand_features = [obj.prefix, 'adb pull sdcard/ihab/features/',cLine{4},' ', sFolder_features];
                    [status, ~] = system(sCommand_features);
                    vStatus = [vStatus, status];
                    
                    nTimeTaken = toc;
                    nApproxTime = nTimeTaken/iCount*(nLines_features - iCount);
                    
                    obj.cListQuestionnaire{end} = sprintf('Copying feature files: %.0i%%, estimated time: %s', ceil(iCount/nLines_features*100), secondsToTime(nApproxTime));
                    obj.hListBox.Value = obj.cListQuestionnaire;
                end
                
            end
            
            obj.cListQuestionnaire{end} = sprintf('Copying feature files: %.0i%%', 100);
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            if (mean(vStatus) == 0)
                obj.cListQuestionnaire{end} = '[x] Feature files copied.';
                obj.bFeatures = 1;
                obj.hStat_Features.Value = num2str(length(vStatus));
            else
                obj.cListQuestionnaire{end} = '[  ] No Feature data was copied.';
                obj.hStat_Features.Value = '0';
                obj.bFeatures = 0;
            end
            
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            %             if obj.isDataComplete()
            obj.hButton_Analyse.Enable = 'On';
            %             end
            
            if obj.bLog
                obj.extractConnection();
            end
            
        end
        
        function [] = extractConnection(obj, ~, ~)
            
            obj.hLabel_Calculating.Visible = 'On';
            drawnow;
            
            obj.hAxes = uiaxes(obj.hTab5);
            obj.hAxes.Units = 'Pixels';
            obj.hAxes.Position = [0,0,obj.hTab5.Position(3), obj.hTab5.Position(4)-20];
            obj.hAxes.Visible = 'Off';
            
            obj.bClear = 0;
            
            sFileName = 'log2.txt';
            
            cLog = fileread(fullfile(obj.stSubject.Folder,sFileName));
            cLog = splitlines(cLog);
            
            bIncludeAll = 0;
            bNormalise = 1;
            
            sOccBTOn = 'Bluetooth: connected';
            sOccBTOff = 'Bluetooth: disconnected';
            sOccBTOff2 = 'bluetoothNotPresent()';
            sOccBatteryLevel = 'battery level';
            sOccTimeReset = 'Device Time reset';
            sOccDisplayOn = 'Display: on';
            sOccDisplayOff = 'Display: off';
            sOccVibration = 'Vibration:';
            
            sOccStateCharging = 'StateCharging';
            sOccStateConnecting = 'StateConnecting';
            sOccStateError = 'StateError';
            sOccStateProposing = 'StateProposing';
            sOccStateQuest = 'StateQuest';
            sOccStateRunning = 'StateRunning';
            
            sMinTimeLimitString = '1970-00-00_00:00:00.000';
            
            sMinTimeString = cLog{1}(1:23);
            nMinTime = stringToTimeMs(sMinTimeString);
            
            vTimeBluetooth = [];
            vBluetooth = [];
            vTimeBattery = [];
            vLevelBattery = [];
            vTimeState = [];
            vState = [];
            vTimeDisplay = [];
            vDisplay = [];
            vTimeVibration = [];
            
            for iLog = 1:length(cLog)-1
                sLogTime = cLog{iLog}(1:23);
                sLog = cLog{iLog}(25:end);
                if contains(sLog, sOccBTOn)
                    vTimeBluetooth(end+1) = stringToTimeMs(sLogTime);
                    vBluetooth(end+1) = 1;
                    
                elseif contains(sLog, sOccBTOff)
                    vTimeBluetooth(end+1) = stringToTimeMs(sLogTime);
                    vBluetooth(end+1) = 0;
                    
                elseif contains(sLog, sOccBTOff2)
                    vTimeBluetooth(end+1) = stringToTimeMs(sLogTime);
                    vBluetooth(end+1) = 0;
                    
                elseif contains(sLog, sOccBatteryLevel)
                    vTimeBattery(end+1) = stringToTimeMs(sLogTime);
                    vLevelBattery(end+1) = str2double(sLog(16:end));
                    
                elseif strcmp(sLog, sOccStateCharging) % blue
                    vTimeState(end+1) = stringToTimeMs(sLogTime);
                    vState(end+1) = 1;
                    
                elseif strcmp(sLog, sOccStateProposing) % yellow
                    vTimeState(end+1) = stringToTimeMs(sLogTime);
                    vState(end+1) = 3;
                    
                elseif strcmp(sLog, sOccStateError) % red
                    vTimeState(end+1) = stringToTimeMs(sLogTime);
                    vState(end+1) = 2;
                    
                elseif contains(sLog, sOccStateConnecting) % purple
                    vTimeState(end+1) = stringToTimeMs(sLogTime);
                    vState(end+1) = 4;
                    
                elseif strcmp(sLog, sOccStateQuest) % light blue
                    vTimeState(end+1) = stringToTimeMs(sLogTime);
                    vState(end+1) = 6;
                    
                elseif strcmp(sLog, sOccStateRunning) % green
                    vTimeState(end+1) = stringToTimeMs(sLogTime);
                    vState(end+1) = 5;
                    
                elseif strcmp(sLog, sOccDisplayOn)
                    vTimeDisplay(end+1) = stringToTimeMs(sLogTime);
                    vDisplay(end+1) = 1;
                    
                elseif strcmp(sLog, sOccDisplayOff)
                    vTimeDisplay(end+1) = stringToTimeMs(sLogTime);
                    vDisplay(end+1) = 0;
                    
                elseif contains(sLog, sOccVibration)
                    vTimeVibration(end+1) = stringToTimeMs(sLogTime);
                    
                end
            end
            
            nTimeMin = min([vTimeBluetooth, vTimeBattery, vTimeState, vTimeDisplay, vTimeVibration]) - nMinTime;
            nTimeMax = max([vTimeBluetooth, vTimeBattery, vTimeState, vTimeDisplay, vTimeVibration]) - nMinTime;
            
            vTimeState = vTimeState - nMinTime;
            vTimeState(end+1) = nTimeMax;
            
            if ~isempty(vState)
                vState(end+1) = vState(end);
            end
            
            vTimeBluetooth = vTimeBluetooth - nMinTime;
            vTimeBluetooth(end+1) = nTimeMax;
            if ~isempty(vBluetooth)
                vBluetooth(end+1) = vBluetooth(end);
            end
            
            vTimeDisplay = vTimeDisplay - nMinTime;
            vTimeDisplay(end+1) = nTimeMax;
            vDisplay(end+1) = vDisplay(end);
            
            vTimeVibration = vTimeVibration - nMinTime;
            
            vTimeBattery = vTimeBattery - nMinTime;
            
            obj.hLabel_Calculating.Visible = 'Off';
            
            obj.hAxes.Visible = 'On';
            
            if ~isempty(vState)
                
                for iState = 1:length(vState)-1
                    vX = [vTimeState(iState), vTimeState(iState), ...
                        vTimeState(iState+1), vTimeState(iState+1)];
                    vY = [0.5, 1, 1, 0.5];
                    
                    if vState(iState) == 1
                        p = patch(obj.hAxes, vX, vY, obj.mColors(1,:));
                        obj.vProportions(1) = obj.vProportions(1) + vX(end)-vX(1);
                    elseif vState(iState) == 2
                        p = patch(obj.hAxes, vX, vY, obj.mColors(2,:));
                        obj.vProportions(2) = obj.vProportions(2) + vX(end)-vX(1);
                    elseif vState(iState) == 3
                        p = patch(obj.hAxes, vX, vY, obj.mColors(3,:));
                        obj.vProportions(3) = obj.vProportions(3) + vX(end)-vX(1);
                    elseif vState(iState) == 4
                        p = patch(obj.hAxes, vX, vY, obj.mColors(4,:));
                        obj.vProportions(4) = obj.vProportions(4) + vX(end)-vX(1);
                    elseif vState(iState) == 5
                        p = patch(obj.hAxes, vX, vY, obj.mColors(5,:));
                        obj.vProportions(5) = obj.vProportions(5) + vX(end)-vX(1);
                    elseif vState(iState) == 6
                        p = patch(obj.hAxes, vX, vY, obj.mColors(6,:));
                        obj.vProportions(6) = obj.vProportions(6) + vX(end)-vX(1);
                    end
                    p.LineStyle = 'none';
                    if iState == 1
                        obj.hAxes.NextPlot = 'add';
                    end
                end
                
            end
            
            
            for iArea = 1:length(vBluetooth)-1
                vX = [vTimeBluetooth(iArea), vTimeBluetooth(iArea), ...
                    vTimeBluetooth(iArea+1), vTimeBluetooth(iArea+1)];
                vY = [0, 0.5, 0.5, 0];
                
                if vBluetooth(iArea) == 0
                    p = patch(obj.hAxes, vX, vY, 'r');
                else
                    p = patch(obj.hAxes, vX, vY, 'g');
                end
                p.LineStyle = 'none';
                
                if iArea == 1
                    obj.hAxes.NextPlot = 'add';
                end
            end
            
            stairs(obj.hAxes, vTimeDisplay, vDisplay*0.50, 'Color', obj.mColors(3,:));
            plot(obj.hAxes, vTimeBattery, vLevelBattery*0.99, 'k');
            
            obj.hHotspot_Legend = patch(obj.hAxes, vTimeBluetooth([1,1,end,end]),[0.5,1,1,0.5], [0.5,0.5,0.5], 'FaceAlpha',0.01);
            obj.hHotspot_Legend.LineStyle = 'none';
            obj.hHotspot_Legend.ButtonDownFcn = @obj.callbackLegend;
            
            obj.hAxes.NextPlot = 'replace';
            
            obj.hAxes.YLim = [0,1];
            obj.hAxes.XLim = [nTimeMin, nTimeMax];
            [cTime, ~] = timeMsToString(obj.hAxes.XTick);
            vTimeMarks = [ceil(str2double(cTime{1})), floor(str2double(cTime{end}))];
            vTime = round(linspace(vTimeMarks(1), vTimeMarks(2), 4));
            
            cTime = {};
            for iTime = 1:length(vTime)
                cTime{iTime} = [num2str(vTime(iTime)),'h'];
            end
            
            obj.hAxes.XTick = vTime*60*60*1000;
            obj.hAxes.XTickLabel = cTime;
            
            obj.hAxes.YTick = [];
            obj.hAxes.YTickLabel = {};
            
            obj.hAxes.Box = 'On';
            obj.hAxes.Layer = 'Top';
            
            % sort proportions
            
            [obj.vProportions_Sorted, idx] = sort(obj.vProportions, 'ascend');
            obj.vStateNumSorted = obj.vStateNum(idx);
            
        end
        
        function [] = getPreferencesFromFile(obj)
            hFid = fopen(['functions', filesep, obj.sFileName_Preferences]);
            cTemp = textscan(hFid, '%s%f');
            
            obj.stPreferences.MinPartLength = cTemp{2}(1);
            
            if cTemp{2}(1) == -1
                obj.bIncludeObjectiveData = false;
                obj.hButton_MinPartLength.Text = 'n/a';
            else
                obj.bIncludeObjectiveData = true;
                obj.hButton_MinPartLength.Text = ...
                    num2str(obj.stPreferences.MinPartLength);
            end
            
            obj.stPreferences.Test = cTemp{2}(2);
            
            fclose(hFid);
        end
        
        function [] = writePreferencesToFile(obj)
            hFid = fopen(['functions', filesep, obj.sFileName_Preferences], 'w');
            
            fprintf(hFid, 'MinPartLength[min]: %d\n', obj.stPreferences.MinPartLength);
            fprintf(hFid, 'Test: %d\n', obj.stPreferences.Test);
            
            fclose(hFid);
        end
        
        function [] = callbackLegend(obj, ~, ~)
            
            obj.hHotspot_Legend.Visible = 'Off';
            
            % calculate proportions
            
            vPercentage = round(obj.vProportions_Sorted/sum(obj.vProportions_Sorted)*1000)/10;
            
            obj.hFig2 = uifigure();
            obj.hFig2.Position = [(obj.vScreenSize(3)-obj.nWidthLegend)/2-50,...
                (obj.vScreenSize(4)-obj.nHeightLegend)/2-50, obj.nWidthLegend, obj.nHeightLegend];
            obj.hFig2.Name = obj.sTitleFig2;
            obj.hFig2.Resize = 'Off';
            
            % Close button
            
            obj.hButton_Legend_Close = uibutton(obj.hFig2);
            obj.hButton_Legend_Close.Position =...
                [(obj.nWidthLegend-obj.nButtonWidth)/2,...
                obj.nDivision_Vertical, obj.nButtonWidth, obj.nButtonHeight];
            obj.hButton_Legend_Close.ButtonPushedFcn = @obj.callbackLegendClose;
            obj.hButton_Legend_Close.Text = obj.sLabelButton_Legend_Close;
            
            % Patches and Precents
            
            nStates = 6;
            for iState = 1:nStates
                
                obj.hPatch_Legend_Charging = uilabel(obj.hFig2);
                obj.hPatch_Legend_Charging.Position = [50,20+(2+iState)*obj.nDivision_Vertical+obj.nButtonHeight+(iState-1)*obj.nPatchHeight,...
                    obj.nPatchWidth, obj.nPatchHeight];
                obj.hPatch_Legend_Charging.Text = '';
                obj.hPatch_Legend_Charging.BackgroundColor = obj.mColors(obj.vStateNumSorted(iState),:);
                
                obj.hLabel_Legend_Charging = uilabel(obj.hFig2);
                obj.hLabel_Legend_Charging.Position = [110,20+(2+iState)*obj.nDivision_Vertical+obj.nButtonHeight+(iState-1)*obj.nPatchHeight,...
                    obj.nLegendLabelWidth, obj.nLegendLabelHeight];
                obj.hLabel_Legend_Charging.Text = sprintf('%s (%.1f%%)',obj.cStates{obj.vStateNumSorted(iState)}, vPercentage(iState));
                
            end
            
        end
        
        function [] = callbackMinPartLength(obj, ~, ~)
            
            % Figure "Part Length"
            obj.hFig3 = uifigure();
            obj.hFig3.Position = [(obj.vScreenSize(3)-obj.nWidth_PartLength)/2-50,...
                (obj.vScreenSize(4)-obj.nHeight_PartLength)/2-50,...
                obj.nWidth_PartLength, obj.nHeight_PartLength];
            obj.hFig3.Name = obj.sTitleFig3;
            obj.hFig3.Resize = 'Off';
            
            % Label "Edit Part Length"
            obj.hLabel_PartLength = uilabel(obj.hFig3);
            obj.hLabel_PartLength.Position = [obj.nDivision_Horizontal, ...
                2*obj.nDivision_Vertical + obj.nButtonHeight, ...
                2*obj.nButtonWidth + obj.nDivision_Horizontal, ...
                obj.nButtonHeight];
            obj.hLabel_PartLength.Text = obj.sLabel_MinPartLength_Text;
            
            % Button "Enter"
            obj.hButton_PartLength_Enter = uibutton(obj.hFig3);
            obj.hButton_PartLength_Enter.Position = ...
                [2*obj.nDivision_Horizontal + obj.nButtonWidth, ...
                obj.nDivision_Vertical, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hButton_PartLength_Enter.Text = obj.sLabel_MinPartLength_Enter;
            obj.hButton_PartLength_Enter.ButtonPushedFcn = @obj.callbackEnterPartLength;
            
            % Edit Text "Part Length"
            obj.hEditText_PartLength = uieditfield(obj.hFig3, 'numeric');
            obj.hEditText_PartLength.Position = ...
                [obj.nDivision_Horizontal, ...
                obj.nDivision_Vertical, ...
                obj.nButtonWidth, ...
                obj.nButtonHeight];
            obj.hEditText_PartLength.Editable = 'On';
            obj.hEditText_PartLength.Value = obj.stPreferences.MinPartLength;
            
        end
        
        function [] = callbackEnterPartLength(obj, ~, ~)
            
            obj.stPreferences.MinPartLength = obj.hEditText_PartLength.Value;
            
            if obj.stPreferences.MinPartLength == -1
                obj.hButton_MinPartLength.Text = 'n/a';
                obj.cListQuestionnaire{end+1} =...
                    sprintf('     Objective data excluded from analysis');
            else
                obj.hButton_MinPartLength.Text = num2str(obj.stPreferences.MinPartLength);
                obj.cListQuestionnaire{end+1} =...
                    sprintf('     Minimum part length changed to: %d', obj.stPreferences.MinPartLength);
            end
            
            obj.writePreferencesToFile;
            
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            close(obj.hFig3);
            
        end
        
        function [] = callbackCompareEMA(obj, ~, ~)
            obj.compareEMA();
        end
        
        function stOut = extractSubjectInfoFromFolder(~, sFolder)
            
            cPathName = split(sFolder, '\');
            sInfo = cPathName{end};
            stOut = struct();
            
            cSubjectData = regexp(sInfo, ...
                '(\w)*(\w){8}_(\w){6}_(\w){2}(_)*(\w)*(_\w)*', 'tokens');
            
            if isempty(cSubjectData{1}{5})
                cSubjectData = cSubjectData{1}(~cellfun('isempty',cSubjectData{1}));
            else
                stOut.Appendix = cSubjectData{1}{6};
                cSubjectData = {cSubjectData{1}{2:4}};
            end
            
            if isValidSubjectData(cSubjectData)
                
                stOut.Name = cSubjectData{1};
                stOut.Date = cSubjectData{2};
                stOut.Experimenter = cSubjectData{3};
                stOut.Folder = sFolder;
                stOut.Code = sInfo;
                
            end
        end
        
        function [] = compareEMA(obj, ~, ~)
            
            % Omit objective data for comparison
            nTempIncludeObjectiveData = obj.bIncludeObjectiveData;
            obj.bIncludeObjectiveData = false;
            
            obj.stComparison = [];
            obj.stComparison(1).Folder = obj.stSubject.Folder;
            obj.stComparison(2).Folder = uigetdir(pwd, 'Please specify directory of EMA #2');
            
            if obj.stComparison(2).Folder == 0
                return;
            end
            
            stInfo1 = obj.extractSubjectInfoFromFolder(obj.stComparison(1).Folder);
            stInfo2 = obj.extractSubjectInfoFromFolder(obj.stComparison(2).Folder);
            
            if ~strcmp(stInfo1.Name, stInfo2.Name)
                errordlg('Subjects must be the same.', 'Subject mismatch');
                return;
            end
            
            tic;
            
            for iEMA = 1:2
                
                obj.bClear = false;
                obj.clearEntries();
                obj.nCompare_Run = iEMA;
                
                sFolder = obj.stComparison(iEMA).Folder;
                
                % Automatically extract subject info from folder name
                cPathName = split(sFolder, '\');
                sInfo = cPathName{end};
                
                cSubjectData = regexp(sInfo, ...
                    '(\w)*(\w){8}_(\w){6}_(\w){2}(_)*(\w)*(_\w)*', 'tokens');
                
                if isempty(cSubjectData{1}{5})
                    cSubjectData = cSubjectData{1}(~cellfun('isempty',cSubjectData{1}));
                else
                    obj.stSubject.Appendix = cSubjectData{1}{6};
                    cSubjectData = {cSubjectData{1}{2:4}};
                end
                
                if isValidSubjectData(cSubjectData)
                    
                    obj.stSubject.Name = cSubjectData{1};
                    obj.stSubject.Date = cSubjectData{2};
                    obj.stSubject.Experimenter = cSubjectData{3};
                    obj.stSubject.Folder = sFolder;
                    obj.stSubject.Code = sInfo;
                    
                    obj.hEditSubject.Value = obj.stSubject.Name;
                    obj.hEditDate.Value = obj.stSubject.Date;
                    obj.hEditExperimenter.Value = obj.stSubject.Experimenter;
                    
                    obj.hEditSubject.Editable = 'Off';
                    obj.hEditDate.Editable = 'Off';
                    obj.hEditExperimenter.Editable = 'Off';
                    
                    obj.hButton_Create.Enable = 'Off';
                    
                else
                    obj.hProgress.killTimer();
                    obj.cListQuestionnaire{end} = 'Cannot read folder.';
                    obj.hListBox.Value = obj.cListQuestionnaire;
                    return;
                end
                
                obj.stAnalysis = struct('NumberOfDays', [], ...
                    'Dates', [], ...
                    'TimePerDay', [], ...
                    'NumberOfParts', [], ...
                    'NumberOfQuestionnaires', []);
                
                % OUTPUT INFO
                obj.cListQuestionnaire{end+1} = ...
                    sprintf('[  ] Performing comparison: %s (%d/2)', obj.stSubject.Name, iEMA);
                obj.hListBox.Value = obj.cListQuestionnaire;
                
                obj.hProgress = BlindProgress(obj);
                
                obj.hProgress.startTimer();
                % Check Data and compute Overview
                main(obj);
                obj.hProgress.stopTimer();
                
                obj.cListQuestionnaire{end} = sprintf('\t.generating pdf files -');
                obj.hListBox.Value = obj.cListQuestionnaire;
                obj.hProgress.startTimer();
                
                % Generate profile PDF's and Fingerprints
                generateProfile_Comparison(obj);
                
                obj.stComparison(iEMA).Analysis = obj.stAnalysis;
                
            end
            
            % OUTPUT INFO
            obj.hProgress.stopTimer();
            obj.cListQuestionnaire{end} = sprintf('\t.merging files -');
            obj.hListBox.Value = obj.cListQuestionnaire;
            obj.hProgress.startTimer();
            
            mergeAndCompilePDFLatex_Comparison(obj);
            
            % OUTPUT INFO
            obj.hProgress.stopTimer();
            obj.cListQuestionnaire{end} = sprintf('\t.copying files -');
            obj.hListBox.Value = obj.cListQuestionnaire;
            obj.hProgress.startTimer();
            
            sDataFolder_Output = [pwd, filesep, 'Overviews'];
            if ~exist(sDataFolder_Output, 'dir')
                mkdir(sDataFolder_Output);
            end
            
            % Filename of Profile
            sResult_PDF_Profile_New = [obj.sFolderMain, filesep, 'Overviews', filesep,...
                'Comparison_', obj.stSubject.Name, '_', datestr(date, 'dd.mm.yy'), '.pdf'];
            sResult_PDF_Profile = [obj.sFolderMain, filesep, 'profile.pdf'];
            movefile(sResult_PDF_Profile, sResult_PDF_Profile_New);
            
            obj.hProgress.stopTimer();
            
            % OUTPUT INFO
            obj.cListQuestionnaire{end-1} = sprintf('[x] Performing comparison: %s', obj.stSubject.Name);
            obj.cListQuestionnaire{end} = sprintf('     Finished in %s\n', formatSeconds(round(toc)));
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            obj.hProgress.killTimer();
            
            % Reset inclusion of objective data
            obj.bIncludeObjectiveData = nTempIncludeObjectiveData;
            
        end
        
        function [] = analyseData(obj, ~, ~)
            
            if exist([obj.sFolderMain, filesep, 'cache', filesep, ...
                    obj.stSubject.Name, '.mat'], 'file') == 2
                sErase_tmp = questdlg('Would you like to erase pre-cached data', ...
                    'Erase pre-cached data?', 'yes', 'no', 'no');
                if strcmp(sErase_tmp, 'yes')
                    deletePreCacheData(obj);
                end
            end
            
            tic;
            
            obj.hProgress = BlindProgress(obj);
            
            obj.stAnalysis = struct('NumberOfDays', [], ...
                'Dates', [], ...
                'TimePerDay', [], ...
                'NumberOfParts', [], ...
                'NumberOfQuestionnaires', []);
            
            sDataFolder_Output = [pwd, filesep, 'Overviews'];
            
            if ~exist(sDataFolder_Output, 'dir')
                mkdir(sDataFolder_Output);
            end
            
            % OUTPUT INFO
            obj.cListQuestionnaire{end+1} = ...
                sprintf('[  ] Analysing subject: %s', obj.stSubject.Name);
            obj.hListBox.Value = obj.cListQuestionnaire;
            drawnow;
            
            % Check Data and compute Overview
            main(obj);
            
            obj.cListQuestionnaire{end} = sprintf('\t.generating pdf files -');
            obj.hListBox.Value = obj.cListQuestionnaire;
            obj.hProgress.startTimer();
            
            % Generate profile PDF's and Fingerprints
            
            generateProfile(obj);
            
            % OUTPUT INFO
            obj.hProgress.stopTimer();
            obj.cListQuestionnaire{end} = sprintf('\t.merging files -');
            obj.hListBox.Value = obj.cListQuestionnaire;
            obj.hProgress.startTimer();
            
            mergeAndCompilePDFLatex(obj);
            
            % OUTPUT INFO
            obj.hProgress.stopTimer();
            obj.cListQuestionnaire{end} = sprintf('\t.copying files -');
            obj.hListBox.Value = obj.cListQuestionnaire;
            obj.hProgress.startTimer();
            
            % Filename of Profile
            sResult_PDF_Profile_New = [obj.sFolderMain, filesep, 'Overviews', filesep,...
                'Personal_Profile_', obj.stSubject.Name, '_Aku_', datestr(date, 'dd.mm.yy'), '.pdf'];
            
            sResult_PDF_Profile_Subject = [obj.stSubject.Folder, filesep,...
                'Personal_Profile_', obj.stSubject.Name, '_Aku_', datestr(date, 'dd.mm.yy'), '.pdf'];
            
            sResult_PDF_Profile = [obj.sFolderMain, filesep, 'profile.pdf'];
            copyfile(sResult_PDF_Profile, sResult_PDF_Profile_Subject);
            movefile(sResult_PDF_Profile, sResult_PDF_Profile_New);
            
            obj.hProgress.stopTimer();
            
            % OUTPUT INFO
            obj.cListQuestionnaire{end-1} = sprintf('[x] Analysing subject: %s', obj.stSubject.Name);
            obj.cListQuestionnaire{end} = sprintf('     Finished in %s\n', formatSeconds(round(toc)));
            obj.hListBox.Value = obj.cListQuestionnaire;
            
            obj.hProgress.killTimer();
            
            delete(timerfindall);
            
        end
        
        function [] = callbackLegendClose(obj, ~, ~)
            close(obj.hFig2);
            obj.hHotspot_Legend.Visible = 'On';
        end
        
        function [] = callbackAnalyseData(obj, ~, ~)
            if obj.isDataCompleteEnoughForAnalysis()
                obj.analyseData();
            end
        end
        
    end
    
    methods(Access = public)
        
        function [stSubject] = getSubjectData(obj)
            stSubject = obj.stSubject;
        end
        
        function [] = setDone(obj, done)
            obj.isDone = done;
        end
        
        
    end
end