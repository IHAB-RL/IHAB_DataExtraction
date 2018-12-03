function [] = generateOverview(printMode, hasSubjectiveData, obj)

% Version 1.0 Data Availibility is displayed
% Version 1.1 GUI integration

% ToDo:
% 1) to get more from the data
%    a) color-code the speech understanding
%    b) marker-size for the importace (or other parts)

%szBaseDir = fullfile(pwd,'ObjectiveDataAnalysisToolbox','HALLO_EMA2016_all');
if nargin < 3
    hasSubjectiveData = true;
end
if nargin < 2
    printMode = true;
end
% szBaseDir = fullfile(pwd,'IHAB_Rohdaten_EMA2018');
% subjectPath = dir([szBaseDir filesep subjectID '*']);
%szBaseDir = [obj.stSubject.Folder,filesep, '..'];

obj.cListQuestionnaire{end} = sprintf('\t.analysing subject data -');
obj.hListBox.Value = obj.cListQuestionnaire;
obj.hProgress.startTimer();


% Create directory for graphics
szGraphicsDir = [obj.stSubject.Folder, filesep 'graphics'];
if ~exist(szGraphicsDir, 'dir')
    mkdir(szGraphicsDir);
end

if hasSubjectiveData
    load ([obj.stSubject.Folder filesep 'Questionnaires_', obj.stSubject.Name, '.mat'])
    TableOneSubject = QuestionnairesTable;
end

% Find unique test subjects
% allSubjects = getallsubjects(obj.stSubject.Folder);

%allSubjects = {obj.stSubject.Name};

clear dateVecOneSubjectQ;


if hasSubjectiveData
    tableHeight = height(TableOneSubject);
    
    dateVecOneSubjectQ = datetime(zeros(tableHeight,1),...
        zeros(tableHeight,1),...
        zeros(tableHeight,1),...
        zeros(tableHeight,1),...
        zeros(tableHeight,1),...
        zeros(tableHeight,1));
    % generate date type variable from data
    for kk = 1:tableHeight
        szDate = TableOneSubject.Date{kk};
        szTime = TableOneSubject.Start{kk};
        szYear = szDate(1:4);
        szMonth = szDate(6:7);
        szDay = szDate(9:10);
        szHour = szTime(1:2);
        szMin = szTime(4:5);
        szSec = szTime(7:8);
        
        dateVecOneSubjectQ(kk) =  datetime(str2double(szYear), ...
            str2double(szMonth), str2double(szDay),str2double(szHour), ...
            str2double(szMin),str2double(szSec));
    end
    % unique Dates of one subject
    dateVecDayOnlyQ = dateVecOneSubjectQ - timeofday(dateVecOneSubjectQ);
    %     uniqueDaysQ = unique(dateVecDayOnlyQ);
    
    %     szSubjectName = TableOneSubject.SubjectID;
else
    %     szSubjectName = obj.stSubject.Name;
end

% subIndex = [];
% for subjectIndex = 1:numel(allSubjects)
%     if strcmpi(allSubjects{subjectIndex}.SubjectID, szSubjectName)
%         subIndex = subjectIndex;
%         break;
%     end
% end
%
% if isempty(subIndex)
%     return;
% end
%
% if isempty(subIndex)
%     error('Subject not found')
% end

subjectMatFile = fullfile(obj.stSubject.Folder,...
    [obj.stSubject.Name '.mat']);
if exist(subjectMatFile, 'file')
    load(subjectMatFile);
else
    warning('Subject mat file %s.mat not found', obj.stSubject.Name)
    return;
end

% Feature Data PSD
[dateVecAllFeatPSD,UniqueDaysFeatPSD] = showAvailableFeatureDataOneTestSubject(obj, 'PSD');

if isempty(dateVecAllFeatPSD)
    return;
end

dateVecDayOnlyFeatPSD = dateVecAllFeatPSD-timeofday(dateVecAllFeatPSD);
AllDates = getdatesonesubject(obj);
AllDates = AllDates.(obj.stSubject.Name)(:);

if ~printMode
    % Feature Data RMS
    [dateVecAllFeatRMS,UniqueDaysFeatRMS] = showAvailableFeatureDataOneTestSubject(obj, 'RMS');
    dateVecDayOnlyFeatRMS= dateVecAllFeatRMS-timeofday(dateVecAllFeatRMS);
    
    % Feature Data ZCR
    [dateVecAllFeatZCR,UniqueDaysFeatZCR] = showAvailableFeatureDataOneTestSubject(obj, 'ZCR');
    dateVecDayOnlyFeatZCR= dateVecAllFeatZCR-timeofday(dateVecAllFeatZCR);
end

numAvailableDataAllDays = zeros(length(AllDates),1);
numInvalidDay = zeros(length(AllDates),1);
percentInvalidDay = zeros(length(AllDates),1);
txtFile = fullfile(obj.stSubject.Folder,[obj.stSubject.Name '.txt']);

if exist(txtFile, 'file')
    delete(txtFile);
end

fid = fopen(txtFile,'wt');

% Plot all data
hFig_Overview = figure();
hFig_Overview.Visible = 'Off';
% hFig_Overview.Units = 'centimeters';
% hFig_Overview.PaperPositionMode = 'auto';
% hFig_Overview.Position = [0 0 21 29.7];
% hFig_Overview.PaperPosition = [0 0 21 29.7];
set(hFig_Overview,'renderer','Painters')
%orient(hFig_Overview,'landscape')
box off
yDistance = @(x) x;

if printMode
    availablePSDColor = [0,0,0]+0.7;
else
    availablePSDColor = 'r';
    availableRMSColor = 'b';
    availableZCRColor = 'g';
end

% Gather statistical data for report
obj.stAnalysis.NumberOfDays = length(AllDates);
obj.stAnalysis.Dates = AllDates;

for kk = 1:length(AllDates)
    PartCounter = -1;
    %         % first plot feature data
    idx = find(dateVecDayOnlyFeatPSD == AllDates(kk));
    if ~isempty(idx) && length(idx) > 1
        %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
        hold on;
        dtMinutes = minutes(diff(dateVecAllFeatPSD(idx)));
        idx2 = find (dtMinutes> 1.1);
        if (isempty(idx2))
            hLinePSD = plot([dateVecAllFeatPSD(idx(1))-AllDates(kk) dateVecAllFeatPSD(idx(end))-AllDates(kk)],[yDistance(kk) yDistance(kk)],'color',[0,0,0]+0.7,'Marker','s','DisplayName','sin');
            set(hLinePSD,'LineWidth',2);
            set(hLinePSD,'MarkerSize',3);
            if ~printMode
                text(datenum(dateVecAllFeatPSD(idx(1))-AllDates(kk)),yDistance(kk)+0.15,'1','Color','red');
            else
                text(datenum(dateVecAllFeatPSD(idx(end))-AllDates(kk))+minutes(1),yDistance(kk),num2str(1),'Color',availablePSDColor);
            end
        else
            %display('At least two parts during this day')
            % first part
            hLinePSD = plot([dateVecAllFeatPSD(idx(1))-AllDates(kk) dateVecAllFeatPSD(idx(idx2(1)))-AllDates(kk)],[yDistance(kk) yDistance(kk)],'color',availablePSDColor,'Marker','s');
            set(hLinePSD,'LineWidth',2);
            set(hLinePSD,'MarkerSize',3);
            if ~printMode
                text(datenum(dateVecAllFeatPSD(idx(1))-AllDates(kk)),kk+0.15,'1','Color','red');
            end
            PartCounter = 1;
            % Andinbetween
            for pp = 1:length(idx2)-1
                hLinePSD = plot([dateVecAllFeatPSD(idx(idx2(pp)+1))-AllDates(kk) dateVecAllFeatPSD(idx(idx2(pp+1)))-AllDates(kk)],[yDistance(kk) yDistance(kk)],'color',availablePSDColor,'Marker','s');
                set(hLinePSD,'LineWidth',2);
                set(hLinePSD,'MarkerSize',3);
                if ~printMode
                    text(datenum(dateVecAllFeatPSD(idx(idx2(pp)+1))-AllDates(kk)),yDistance(kk)+0.15,num2str(PartCounter+1),'Color','red');
                end
                PartCounter = PartCounter+1;
            end
            %last part
            hLinePSD = plot([dateVecAllFeatPSD(idx(idx2(end)+1))-AllDates(kk) dateVecAllFeatPSD(idx(end))-AllDates(kk)],[yDistance(kk) yDistance(kk)],'color',availablePSDColor,'Marker','s');
            set(hLinePSD,'LineWidth',2);
            set(hLinePSD,'MarkerSize',3);
            if ~printMode
                text(datenum(dateVecAllFeatPSD(idx(idx2(end)+1))-AllDates(kk)),yDistance(kk)+0.15,num2str(PartCounter+1),'Color','red');
            else
                text(datenum(dateVecAllFeatPSD(idx(end))-AllDates(kk))+minutes(30),yDistance(kk),num2str(PartCounter+1),'Color',availablePSDColor);
            end
        end
        
        
    end
    
    % Gather statistical data for report
    obj.stAnalysis.NumberOfParts(kk) = PartCounter+1;
    
    if ~printMode
        
        %% now rms
        idx = find(dateVecDayOnlyFeatRMS == AllDates(kk));
        if ~isempty(idx) && length(idx) > 1
            %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
            hold on;
            dtMinutes = minutes(diff(dateVecAllFeatRMS(idx)));
            idx2 = find (dtMinutes> 1.1);
            if (isempty(idx2))
                hLineRMS = plot([dateVecAllFeatRMS(idx(1))-AllDates(kk) dateVecAllFeatRMS(idx(end))-AllDates(kk)],[kk-0.05 kk-0.05],'b-s','DisplayName','cos');
                set(hLineRMS,'LineWidth',2);
                set(hLineRMS,'MarkerSize',3);
                if ~printMode
                    text(datenum(minutes(15)+dateVecAllFeatRMS(idx(1))-AllDates(kk)),kk+0.15,'1','Color',availableRMSColor);
                end
            else
                %display('At least two parts during this day')
                % first part
                hLineRMS = plot([dateVecAllFeatRMS(idx(1))-AllDates(kk) dateVecAllFeatRMS(idx(idx2(1)))-AllDates(kk)],[kk-0.05 kk-0.05],'b-s');
                set(hLineRMS,'LineWidth',2);
                set(hLineRMS,'MarkerSize',3);
                if ~printMode
                    text(datenum(minutes(15)+ dateVecAllFeatRMS(idx(1))-AllDates(kk)),kk+0.15,'1','Color',availableRMSColor);
                end
                PartCounter = 1;
                % Andinbetween
                for pp = 1:length(idx2)-1
                    hLineRMS = plot([dateVecAllFeatRMS(idx(idx2(pp)+1))-AllDates(kk) dateVecAllFeatRMS(idx(idx2(pp+1)))-AllDates(kk)],[kk-0.05 kk-0.05],'b-s');
                    set(hLineRMS,'LineWidth',2);
                    set(hLineRMS,'MarkerSize',3);
                    
                    if ~printMode
                        text(datenum(minutes(15) + dateVecAllFeatRMS(idx(idx2(pp)+1))-AllDates(kk)),kk+0.15,num2str(PartCounter+1),'Color',availableRMSColor);
                    end
                    PartCounter = PartCounter+1;
                end
                %last part
                hLineRMS = plot([dateVecAllFeatRMS(idx(idx2(end)+1))-AllDates(kk) dateVecAllFeatRMS(idx(end))-AllDates(kk)],[kk-0.05 kk-0.05],'b-s');
                set(hLineRMS,'LineWidth',2);
                set(hLineRMS,'MarkerSize',3);
                if ~printMode
                    text(datenum(minutes(15) + dateVecAllFeatRMS(idx(idx2(end)+1))-AllDates(kk)),kk+0.15,num2str(PartCounter+1),'Color',availableRMSColor);
                end
            end
        end
        
        % now ZCR
        idx = find(dateVecDayOnlyFeatZCR == AllDates(kk));
        if ~isempty(idx) && length(idx) > 1
            %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
            hold on;
            dtMinutes = minutes(diff(dateVecAllFeatZCR(idx)));
            idx2 = find (dtMinutes> 1.1);
            if (isempty(idx2))
                hLineZCR = plot([dateVecAllFeatZCR(idx(1))-AllDates(kk) dateVecAllFeatZCR(idx(end))-AllDates(kk)],[kk-0.1 kk-0.1],'color',availableZCRColor,'Marker','s','DisplayName','tan');
                set(hLineZCR,'LineWidth',2);
                set(hLineZCR,'MarkerSize',3);
                if ~printMode
                    text(datenum(minutes(30)+dateVecAllFeatZCR(idx(1))-AllDates(kk)),kk+0.15,'1','Color','green');
                else
                    
                end
            else
                %display('At least two parts during this day')
                % first part
                hLineZCR = plot([dateVecAllFeatZCR(idx(1))-AllDates(kk) dateVecAllFeatZCR(idx(idx2(1)))-AllDates(kk)],[kk-0.1 kk-0.1],'color',availableZCRColor,'Marker','s');
                set(hLineZCR,'LineWidth',2);
                set(hLineZCR,'MarkerSize',3);
                if ~printMode
                    text(datenum(minutes(30)+ dateVecAllFeatZCR(idx(1))-AllDates(kk)),kk+0.15,'1','Color','green');
                end
                PartCounter = 1;
                % Andinbetween
                for pp = 1:length(idx2)-1
                    hLineZCR = plot([dateVecAllFeatZCR(idx(idx2(pp)+1))-AllDates(kk) dateVecAllFeatZCR(idx(idx2(pp+1)))-AllDates(kk)],[kk-0.1 kk-0.1],'color',availableZCRColor,'Marker','s');
                    set(hLineZCR,'LineWidth',2);
                    set(hLineZCR,'MarkerSize',3);
                    if ~printMode
                        text(datenum(minutes(30) + dateVecAllFeatZCR(idx(idx2(pp)+1))-AllDates(kk)),kk+0.15,num2str(PartCounter+1),'Color','green');
                    end
                    PartCounter = PartCounter+1;
                end
                %last part
                hLineZCR = plot([dateVecAllFeatZCR(idx(idx2(end)+1))-AllDates(kk) dateVecAllFeatZCR(idx(end))-AllDates(kk)],[kk-0.1 kk-0.1],'color',availableZCRColor,'Marker','s');
                set(hLineZCR,'LineWidth',2);
                set(hLineZCR,'MarkerSize',3);
                if ~printMode
                    text(datenum(minutes(30) + dateVecAllFeatZCR(idx(idx2(end)+1))-AllDates(kk)),kk+0.15,num2str(PartCounter+1),'Color','green');
                end
            end
        end
    end
    
    obj.hProgress.stopTimer();
    obj.cListQuestionnaire{end} = sprintf('\t.building overview -');
    obj.hListBox.Value = obj.cListQuestionnaire;
    obj.hProgress.startTimer();
   
    if hasSubjectiveData
        
        %% now plot questionaire info
        idx = find(dateVecDayOnlyQ == AllDates(kk));
        
        % Gather statistical data for report
        obj.stAnalysis.NumberOfQuestionnaires(kk) = length(idx);
        
        if ~isempty(idx) && length(idx) > 1
            %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
            hold on;
            for ss = 1:length(idx)
                hLine = plot(dateVecOneSubjectQ(idx(ss))-AllDates(kk),kk-0.15,'bx');
                if ~printMode
                    LE = TableOneSubject.ListeningEffort(idx(ss));
                    if ~iscell(LE)
                        LE = num2cell(LE);
                    end
                    if (isnumeric(LE{1}))
                        %display('Zahl');
                        if LE{1} < 111
                            set(hLine,'MarkerSize',2*LE{1});
                        else
                            set(hLine,'MarkerSize',0.5);
                        end
                    else
                        %display('Missing LE');
                        set(hLine,'MarkerSize',0.5);
                    end
                    SU = TableOneSubject.SpeechUnderstanding(idx(ss));
                    if ~iscell(SU)
                        SU = num2cell(SU);
                    end
                    if (isnumeric(SU{1}))
                        %display('Zahl');
                        ColorMapSU = flipud([0 1 0; 0 0.8 0; 0.2 0.6 0.2; 0.4 0.4 0.2; 0.6 0.2 0; 0.8 0 0; 1 0 0]);
                        if SU{1} < 100
                            set(hLine,'Color',ColorMapSU(SU{1},:));
                        else % 222 no speech
                            set(hLine,'Color',[0 0 0]);
                        end
                    else
                        %display('Missing SU');
                        set(hLine,'Color',[0 0 1]);
                    end
                    
                    LR = TableOneSubject.LoudnessRating(idx(ss));
                    if ~iscell(LR)
                        LR = num2cell(LR);
                    end
                    if (isnumeric(LR{1}))
                        %display('Zahl');
                        MarkerFormLR = {'x','o','diamond','<','>','*','square'};
                        if LR{1} < numel(MarkerFormLR)
                            set(hLine,'Marker',MarkerFormLR{LR{1}});
                        else
                            set(hLine,'Marker','.');
                        end
                    else
                        %display('Missing LE');
                        set(hLine,'Marker','.');
                    end
                else
                    % Define color coding for markers of subjective data
                    situationColors = [...
                        66 197 244; % light blue: at home
                        255 153   0; % orange: on the way
                        165 191 102; % green: society
                        166  65 244; % purple: work
                        0   0   0; % black: no rating
                        ]./255; % RGB scaling
                    situation = TableOneSubject.Situation(idx(ss));
                    
                    % Missing rating for situation: Set marker color to
                    % black (row 5 of situationColor)
                    if situation > 4
                        situation = 5;
                    end
                    
                    %                     if ~isfield(TableOneSubject, 'ListeningEffort')
                    if ~ismember('ListeningEffort', TableOneSubject.Properties.VariableNames)
                        hProgress.stopTimer();
                        obj.cListQuestionnaire{end} = [];
                        obj.cListQuestionnaire{end} = sprintf('    Questionnaire data incomplete.');
                        obj.hListBox.Value = obj.cListQuestionnaire;
                        close(hFig_Overview);
                        return;
                    end
                    
                    LE = TableOneSubject.ListeningEffort(idx(ss));
                    % Case: Missing rating
                    if LE > 100
                        hLine.Marker = 'x';
                        hLine.MarkerSize = 5;
                        hLine.LineWidth = 0.5;
                    else
                        hLine.Marker = 'o';
                        hLine.MarkerSize = LE;
                        hLine.LineWidth = 2;
                    end
                    
                    % Set the corresponding color for situation
                    hLine.MarkerEdgeColor = situationColors(situation,:);
                    
                    % At home
                    hNanBlue = plot([NaN,NaN]);
                    hNanBlue.Marker = 'o';
                    hNanBlue.LineStyle = 'none';
                    hNanBlue.LineWidth = 2;
                    hNanBlue.MarkerEdgeColor = situationColors(1,:);
                    
                    % On the way
                    hNanOrange = plot([NaN,NaN]);
                    hNanOrange.Marker = 'o';
                    hNanOrange.LineStyle = 'none';
                    hNanOrange.LineWidth = 2;
                    hNanOrange.MarkerEdgeColor = situationColors(2,:);
                    
                    % Society
                    hNanGreen = plot([NaN,NaN]);
                    hNanGreen.Marker = 'o';
                    hNanGreen.LineStyle = 'none';
                    hNanGreen.LineWidth = 2;
                    hNanGreen.MarkerEdgeColor = situationColors(3,:);
                    
                    % At work
                    hNanPurple = plot([NaN,NaN]);
                    hNanPurple.Marker = 'o';
                    hNanPurple.LineStyle = 'none';
                    hNanPurple.LineWidth = 2;
                    hNanPurple.MarkerEdgeColor = situationColors(4,:);
                end
            end
        end
    end
    
    
    % plot error codes
    
    % Filter for PSD feat files since no second arguments is given to
    % Filename2date; also get back the indices of PSD files only
    [dateFilenames,isFeatFile] = Filename2date(stSubject.chunkID.FileName);
    
    % Now since you have the indices, you have to filter the error
    % codes to get the respective ones
    filteredErrorCodes = stSubject.chunkID.ErrorCode(isFeatFile);
    filteredECColors = stSubject.chunkID.PercentageError(isFeatFile);
    
    % Get only the dates of the current day ...
    currentDayIndexes = ...
        find(dateFilenames-timeofday(dateFilenames) == AllDates(kk));
    
    if isempty(currentDayIndexes)
        continue;
    end
    
    currentDays = dateFilenames(currentDayIndexes);
    onlyTimeOfDay = timeofday(currentDays);
    
    % ... and again filter also the error codes
    currentErrorCodes = filteredErrorCodes(currentDayIndexes);
    currentECColors = filteredECColors(currentDayIndexes);
    
    if ~iscell(currentErrorCodes)
        currentErrorCodes = num2cell(currentErrorCodes);
    end
    
    % CURRENTLY unused (especially in black/white mode)
    if ~iscell(currentECColors)
        currentECColors = num2cell(currentECColors);
    end
    
    numAvailableDataAllDays(kk) = length(currentErrorCodes);
    strHoursAvailableDataCurrentDay = ...
        num2str(round(10*numAvailableDataAllDays(kk)/60)/10);
    validChunkIndices = cell2mat(cellfun(@(x) ~isempty(find(x == 0, 1)),...
        currentErrorCodes, 'UniformOutput', false));
    invalidChunkIndices = ~validChunkIndices;
    currentErrorCodesValid = currentErrorCodes;
    currentErrorCodesInvalid = currentErrorCodes;
    currentErrorCodesValid(invalidChunkIndices) = {NaN};
    currentErrorCodesInvalid(validChunkIndices) = {NaN};
    
    % Get number of invalid data per day
    validCounter = 0;
    for ii = 1:length(currentErrorCodes)
        if currentErrorCodesValid{ii} == 0
            validCounter = validCounter + 1;
        end
    end
    numInvalidDay(kk) = numAvailableDataAllDays(kk) - validCounter;
    percentInvalidDay(kk) = numInvalidDay(kk)/numAvailableDataAllDays(kk);
    strValidData = num2str(round(100*(1-percentInvalidDay(kk)))/100);
    strDate = datestr(AllDates(kk),'dd mmm yyyy');
    strSeparationLine = repmat('-', 1, length(strDate));
    
    % Write information to file
    fprintf(fid,'%s\n', strDate);
    fprintf(fid, '%s\n', strSeparationLine);
    fprintf(fid,'Hours: %s\n', strHoursAvailableDataCurrentDay);
    fprintf(fid,'Valid: %s\n', strValidData);
    fprintf(fid,'\n');
    
    % Gather statistical data for report
    obj.stAnalysis.TimePerDay(kk) = round(numAvailableDataAllDays(kk)*60);
    
    % Plot error codes
    lineDistance = 0.1;
    fontSize = 6.5;
    fontColor = [0, 0, 0] + 0.5;
    
    % Line for valid data
    hLineZero = plot([onlyTimeOfDay(1) onlyTimeOfDay(end)], ...
        [yDistance(kk)+5*lineDistance yDistance(kk)+5*lineDistance], ...
        'Color', [0,0,0]);
    set(hLineZero,'LineWidth',0.1);
    t = text(onlyTimeOfDay(1)-minutes(60), yDistance(kk)+5*lineDistance, ...
        'VALID DATA', 'HorizontalAlignment', 'right', 'Color', ...
        fontColor, 'BackGroundColor', 'w');
    t.FontSize = fontSize+0.5;
    
    % Line for too high RMS (error code: -1)
    hLineMinusOne = plot([onlyTimeOfDay(1) onlyTimeOfDay(end)], ...
        [yDistance(kk)+4*lineDistance yDistance(kk)+4*lineDistance], ...
        'Color', fontColor, 'LineStyle', '--');
    set(hLineMinusOne,'LineWidth',0.1);
    t = text(onlyTimeOfDay(1)-minutes(60), yDistance(kk)+4*lineDistance, ...
        'RMS too high', 'HorizontalAlignment', 'right', 'Color', ...
        fontColor, 'BackGroundColor', 'w');
    t.FontSize = fontSize;
    
    % Line for too low RMS (error code: -2)
    hLineMinusTwo = plot([onlyTimeOfDay(1) onlyTimeOfDay(end)], ...
        [yDistance(kk)+3*lineDistance yDistance(kk)+3*lineDistance], ...
        'Color', fontColor, 'LineStyle', '--');
    set(hLineMinusTwo,'LineWidth',0.1);
    t = text(onlyTimeOfDay(1)-minutes(60), yDistance(kk)+3*lineDistance, ...
        'RMS too low', 'HorizontalAlignment', 'right', 'Color', ...
        fontColor, 'BackGroundColor', 'w');
    t.FontSize = fontSize;
    
    % Line for mono/no stereo signal (error code: -3)
    hLineMinusThree = plot([onlyTimeOfDay(1) onlyTimeOfDay(end)], ...
        [yDistance(kk)+2*lineDistance yDistance(kk)+2*lineDistance], ...
        'Color', fontColor, 'LineStyle', '--');
    set(hLineMinusThree,'LineWidth',0.1);
    t = text(onlyTimeOfDay(1)-minutes(60), yDistance(kk)+2*lineDistance, ...
        'no stereo signal', 'HorizontalAlignment', 'right', 'Color', ...
        fontColor, 'BackGroundColor', 'w');
    t.FontSize = fontSize;
    
    % Line for invalid coherence (error code: -4)
    hLineMinusFour = plot([onlyTimeOfDay(1) onlyTimeOfDay(end)], ...
        [yDistance(kk)+1*lineDistance yDistance(kk)+1*lineDistance], ...
        'Color',fontColor, 'LineStyle','--');
    set(hLineMinusFour,'LineWidth',0.1);
    t = text(onlyTimeOfDay(1)-minutes(60), yDistance(kk)+1*lineDistance, ...
        'coherence invalid', 'HorizontalAlignment', 'right', ...
        'Color', fontColor, 'BackGroundColor', 'w', 'FontSize', fontSize);
    
    % Plot error codes to the figure
    
    % Define marker styles for different modes (black/white printing or
    % colored)
    if ~printMode
        markerStyleValid = 'gx';
        markerStyleInvalid = 'rx';
    else
        markerStyleValid = 'kx';
        markerStyleInvalid = 'kx';
    end
    
    % Plot markers for VALID data
    hLineValid = plot(onlyTimeOfDay, lineDistance*[currentErrorCodesValid{:}]+yDistance(kk)+5*lineDistance,markerStyleValid);
    hLineInvalid = [];
    
    % Plot markers for INVALID data
    for errPlotIdx = 1:length(onlyTimeOfDay)
        yAxisError = lineDistance*[currentErrorCodesInvalid{errPlotIdx}]+yDistance(kk)+5*lineDistance;
        if ~isnan(yAxisError)
            hLineInvalid = plot(onlyTimeOfDay(errPlotIdx), yAxisError,markerStyleInvalid);
        end
    end
end % end of one day

% Add legend depending on print mode (black/white or colored)
if ~printMode
    legend([hLinePSD,hLineRMS,hLineZCR,hLineValid,hLineInvalid], ...
        {'PSD', 'RMS', 'ZCR', 'valid data', 'invalid data'}, ...
        'Location','southoutside', 'Orientation','horizontal','Interpreter','latex');
    
else
    if hasSubjectiveData
        legend([hLineValid, hNanBlue, hNanOrange, hNanGreen, hNanPurple], {'marks chunk', 'listening effort (LE) at home', 'LE on the way','LE in society','LE at work'}, ...
            'Location','southoutside', 'Orientation','vertical','Interpreter','none');
    else
        legend(hLineValid, {'marks chunk'}, ...
            'Location','southoutside', 'Orientation','vertical','Interpreter','none');
    end
end

% Set dates as Y-tick labels
set(gca,'YTick',1:length(AllDates));
set(gca,'YTickLabel',datestr(AllDates));

% title([obj.stSubject.Name, ' data availability']);
ylim([1-0.5 length(AllDates)+1]);

hFig_Overview.Color = 'w';

nWidth_Overview = 6/2.54;
nHeight_Overview = 8.5/2.54;

tmp_pos = get(gcf, 'Position');
hFig_Overview.Position = [tmp_pos(1), tmp_pos(2), ...
    nWidth_Overview*obj.stPrint.DPI, nHeight_Overview*obj.stPrint.DPI];
set(gca, 'FontSize', obj.stPrint.FontSize, ...
    'LineWidth', 1);
hFig_Overview.InvertHardcopy = obj.stPrint.InvertHardcopy;
hFig_Overview.PaperUnits = 'inches';
tmp_papersize = hFig_Overview.PaperSize;
tmp_left = (tmp_papersize(1) - nWidth_Overview)/2;
tmp_bottom = (tmp_papersize(2) - nHeight_Overview)/2;
tmp_figuresize = [tmp_left, tmp_bottom, nWidth_Overview, ...
    nHeight_Overview];
hFig_Overview.PaperPosition = tmp_figuresize;

export_fig([obj.stSubject.Folder, filesep, 'graphics', filesep, ...
    '17_' obj.stSubject.Name, '.pdf'], '-native');

% Save the figure as PDF and EPS ('016_' for page numbering in PDF)
% print(hFig_Overview,'-fillpage',fullfile(szGraphicsDir,...
%     ['17_' obj.stSubject.Name]),'-dpdf');


% saveas(hFig_Overview,fullfile(szGraphicsDir,...
%     ['17_' obj.stSubject.Name]),'epsc')

close(hFig_Overview);

% Write information on validity per day to file
totalHours = num2str(round(10*sum(numAvailableDataAllDays)/60)/10);
percentInvalidTotal = sum(numInvalidDay)/sum(numAvailableDataAllDays);
strValidDataTotal = num2str(round(100*(1-percentInvalidTotal))/100);
fprintf(fid,'Total hours: %s\n', totalHours);
fprintf(fid,'Total validity: %s', strValidDataTotal);
fclose(fid);

obj.hProgress.stopTimer();

end
% EOF