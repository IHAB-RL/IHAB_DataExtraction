
function plotAllDayFingerprints(obj, dateDay, iPart, bPrint, hasSubjectiveData)
% display day fingerprints of HALLO data

if nargin < 7
    hasSubjectiveData = false;
end

% Some GUI Defintion
GUI_xStart = 0.07;
GUI_xAxesWidth = 0.92;


% Todo
%- Kalibrierung auf SPL (must)
% Y -Ticks auf ganze Stunden bzw halbe Stunden
% Sauberer Zoom

%%
% szBaseDir = obj.stSubject.Folder;
% szSubjectDir = dir([szBaseDir filesep szSubject '*']);
% szSubjectDir = szSubjectDir.name;
% szDataMatFile = szQuestionnaireName;



szFullFile = [obj.stSubject.Folder, filesep, 'cache', filesep, ...
    obj.stSubject.Name, '_FinalDat_', num2str(day(dateDay)), '_', ...
    num2str(month(dateDay)), '_', num2str(year(dateDay)), ...
    '_p', num2str(iPart), '.mat'];

if ~exist(szFullFile,'file')
    %     warning('%s does not exist. Returning and continuing...',szFullFile);
    return;
end
load (szFullFile)



% szTestSubject =  szSubject;
% caAllSubjects = getallsubjects(szBaseDir);
%
% correctIdx = 0;
% for allSubsIdx = 1:numel(caAllSubjects)
%     if strcmpi(caAllSubjects{allSubsIdx}.SubjectID, szTestSubject)
%         correctIdx = allSubsIdx;
%         break;
%     end
% end

% szFolderName = caAllSubjects{correctIdx}.FolderName;

desiredDay = dateDay;
desiredPart = iPart;

% partsFinaltimeVecPSD = cell(desiredPart,1);
% partsRMSTimeVec = cell(desiredPart,1);
% partsFinalRMS = cell(desiredPart,1);
% partsFinalPSD = cell(desiredPart,1);
% partsFinalCohe = cell(desiredPart,1);
% partsFinalMeanCohe = cell(desiredPart,1);
% partsFinalOVD_fixed = cell(desiredPart,1);
% partsFinalOVD_adaptive = cell(desiredPart,1);

dataFileName = [obj.stSubject.Folder, filesep, 'cache', filesep, ...
    obj.stSubject.Name, '_FinalDat_', num2str(day(desiredDay)), '_', ...
    num2str(month(desiredDay)), '_', num2str(year(desiredDay)), ...
    '_p', num2str(desiredPart)];
[~,fileName,fext] = fileparts(dataFileName);

if ~exist([dataFileName '.mat'],'file')
    warndlg(sprintf('%s.mat does not exist. Returning and continuing...',fileName),'Missing mat-file');
    return;
end

load (dataFileName);
% for partIdx = 1:desiredPart
%
%     dataFileName = [ szBaseDir filesep szFolderName filesep szTestSubject '_FinalDat_' num2str(day(desiredDay)) '_'...
%         num2str(month(desiredDay)) '_' num2str(year(desiredDay)) ...
%         '_p' num2str(partIdx)];
%     [~,fileName,fext] = fileparts(dataFileName);
%
%     if ~exist([dataFileName '.mat'],'file')
%         warndlg(sprintf('%s.mat does not exist. Returning and continuing...',fileName),'Missing mat-file');
%         return;
%     end
%
%     load (dataFileName);
%     partsFinalRMS{partIdx,1} = FinalDataRMS;
%     partsRMSTimeVec{partIdx,1} = FinaltimeVecRMS;
%     partsFinalPSD{partIdx,1} = FinalDataPxx2;
%     partsFinalCohe{partIdx,1} = FinalDataCohe2;
%     partsFinalMeanCohe{partIdx,1} = FinalDataMeanCohe;
%     partsFinalOVD_adaptive{partIdx,1} = FinalDataOVD_adaptive;
%     partsFinalOVD_fixed{partIdx,1} = FinalDataOVD_fixed;
%     partsFinaltimeVecPSD{partIdx,1} = FinaltimeVecPSD;
% end
%
% FinalDataRMS = cat(1,partsFinalRMS{:});
% FinaltimeVecRMS = cat(1,partsRMSTimeVec{:});
% FinalDataPxx2 = cat(1,partsFinalPSD{:});
% FinalDataCohe2 = cat(1,partsFinalCohe{:});
% FinalDataMeanCohe = cat(1,partsFinalMeanCohe{:});
% FinalDataOVD_adaptive = cat(1,partsFinalOVD_adaptive{:});
% FinalDataOVD_fixed = cat(1,partsFinalOVD_fixed{:});
% FinaltimeVecPSD = cat(1,partsFinaltimeVecPSD{:});

%partDuration = timeofday(FinaltimeVecPSD(end))-timeofday(FinaltimeVecPSD(1));

% if partDuration < minutes(5)
%     warndlg('Part is less than 5 minutes. No plot will be created!','Short part')
%     return;
% end

%% Define Calibration Values
if (year(desiredDay) > 2014)
    Callib_RMS = 100;
else
    Callib_RMS = 85;
end

if hasSubjectiveData
    
    SubjectIDTable = QuestionnairesTable.SubjectID;
    
    idx = strcmp(szTestSubject,SubjectIDTable );
    
    if all(idx == 0)
        %     warning('%s not found in questionnaire table. Returning and continuing ...',szTestSubject)
        return;
    end
    
    TableOneSubject = QuestionnairesTable(idx,:);
    
    for kk = 1:height(TableOneSubject)
        szDate = TableOneSubject.Date{kk};
        szTime = TableOneSubject.Start{kk};
        szYear = szDate(1:4);
        szMonth = szDate(6:7);
        szDay = szDate(9:10);
        szHour = szTime(1:2);
        szMin = szTime(4:5);
        szSec = szTime(7:8);
        
        dateVecOneSubjectQ (kk) =  datetime(str2num(szYear),str2num(szMonth)...
            ,str2num(szDay),str2num(szHour),str2num(szMin),str2num(szSec));
    end
    
    %% reduce to data of one day
    
    dateVecDayOnlyQ= dateVecOneSubjectQ-timeofday(dateVecOneSubjectQ);
    idxDate = find(dateVecDayOnlyQ == desiredDay);
    
    FinalIdxQ = find (dateVecOneSubjectQ(idxDate) > FinaltimeVecPSD(1));
    
    
    FinalTimeQ = dateVecOneSubjectQ(idxDate(FinalIdxQ));
    FinalTableOneSubject = TableOneSubject(idxDate(FinalIdxQ),:);
    ReportedDelay = zeros(height(FinalTableOneSubject),1);
    if str2double(szYear) < 2017
        for kk = 1:height(FinalTableOneSubject)
            if iscell(FinalTableOneSubject.AssessDelay)
                AssessDelay = FinalTableOneSubject.AssessDelay{kk};
            elseif isnumeric(FinalTableOneSubject.AssessDelay)
                AssessDelay = FinalTableOneSubject.AssessDelay(kk);
            end
            if (~ischar(AssessDelay))
                if (AssessDelay <= 5)
                    ReportedDelay(kk) = (AssessDelay-1)*5;
                elseif (AssessDelay == 5)
                    ReportedDelay(kk) = 30;
                elseif (AssessDelay >= 6)
                    ReportedDelay(kk) = 40; % Could be everything
                end
            else
                ReportedDelay(kk) = 0;
            end
        end
    else
        for kk = 1:height(FinalTableOneSubject)
            if iscell(FinalTableOneSubject.AssessDelay)
                AssessDelay = FinalTableOneSubject.AssessDelay{kk};
            elseif isnumeric(FinalTableOneSubject.AssessDelay)
                AssessDelay = FinalTableOneSubject.AssessDelay(kk);
            end
            if (~ischar(AssessDelay))
                switch AssessDelay
                    case 1
                        ReportedDelay(kk) = 0;
                    case 2
                        ReportedDelay(kk) = 2.5;
                    case 3
                        ReportedDelay(kk) = 5;
                    case 4
                        ReportedDelay(kk) = 10;
                    case 5
                        ReportedDelay(kk) = 15;
                    case 6
                        ReportedDelay(kk) = 20;
                    case 7
                        ReportedDelay(kk) = 30;
                    otherwise
                end
            end
        end
    end
    
end
%% objective Data
%
% figure('Units','normalized','PaperPosition',[0.15 0.05 0.5 0.85]);
hFig_Fingerprint = figure('Units','normalized','PaperPosition',[0 0 1 1],'Position',[0 0 1 1], 'Visible', 'Off');

mTextTitle = uicontrol(hFig_Fingerprint, 'Style', 'Text');
set(mTextTitle, 'Units', 'normalized', 'Position', [0.2 0.91 0.6 0.05], ...
    'String',[obj.stSubject.Name, ' ', datestr(desiredDay)], 'FontSize', 16, ...
    'BackGroundColor', 'w')

mTextOVD = uicontrol(hFig_Fingerprint, 'Style', 'Text');
set(mTextOVD, 'Units', 'normalized', 'Position', [0.96 0.78 0.03 0.03], ...
    'String', 'OVD', 'FontSize', 12, 'BackGroundColor', 'w');

mTextRMS = uicontrol(hFig_Fingerprint,'style','text');
set(mTextRMS, 'Units', 'normalized', 'Position', [0.96 0.117 0.03 0.03], ...
    'String', 'RMS', 'FontSize', 12, 'BackGroundColor', 'w');

%% Erst die Coherence
axCoher = axes('Position',[GUI_xStart 0.55 GUI_xAxesWidth 0.18]);

fs = 16000;
PlotMaxFreq = 8000;
freq_vek = linspace(0,fs/2,size(FinalDataPxx,2));
MaxFreqIndex = round(PlotMaxFreq/(fs/2)*size(FinalDataPxx,2));
timeVecShort = datenum(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = (FinalDataCohe2(:,:))';
clear FinalDataCohe2;
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
clear DataMatrixShort;
axis xy;
colorbar;
title('');
text(timeVecShort(5),freqVecShort(end-1),'Re\{Coherence\}','Color',[1 1 1]);
yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
yaxisLables = strrep(yaxisLables,'000', 'k');
set (gca,'YTick',1:3:size(FinalDataPxx2,2));
set (gca,'YTickLabel',yaxisLables);
set(gca ,'ylabel', ylabel('center frequency in Hz'))
set (gca,'XTick',[]);



drawnow;

PosVecCoher = get(axCoher,'Position');




%% RMS und OVD

axRMS = axes('Position',[GUI_xStart 0.09 PosVecCoher(3) 0.09]);
hRMS = plot(datenum(FinaltimeVecRMS),20*log10(FinalDataRMS)+Callib_RMS);
hRMS(1).Color = [0 0 0];
hRMS(2).Color = [0 0 0]+0.5;
xlim([datenum(FinaltimeVecRMS(1)) datenum(FinaltimeVecRMS(end))]);
ylim([25 95]);
axRMS.YLabel = ylabel('dB SPL');
clear FinaltimeVecRMS;
clear FinalDataRMS;


%% OVD
axOVD = axes('Position',[GUI_xStart 0.75  PosVecCoher(3) 0.1]);
hOVD = plot(datenum(FinaltimeVecPSD),FinalDataMeanCohe);
axOVD.YLabel = ylabel('mean real coh.');
clear FinalDataMeanCohe;

hOVD.Color = [0 0 0];
hold on;
idx_fixedThresh = find(FinalDataOVD_fixed>0.5);
idx_adaptThresh = find(FinalDataOVD_adaptive ~= false);


if ~isempty(idx_fixedThresh)
    hOVDMarker_fixed = plot(datenum(FinaltimeVecPSD(idx_fixedThresh)),FinalDataOVD_fixed(idx_fixedThresh).* 1.25);
else
    hOVDMarker_fixed = plot(NaN,NaN);
end
if ~isempty(idx_adaptThresh)
    hOVDMarker_adaptive = plot(datenum(FinaltimeVecPSD(idx_adaptThresh)),FinalDataOVD_adaptive(idx_adaptThresh).* 1.1);
else
    hOVDMarker_adaptive = plot(NaN,NaN);
end
xlim([datenum(FinaltimeVecPSD(1)) datenum(FinaltimeVecPSD(end))]);
ylim ([-0.5 1.5]);
axOVD.YTick = [-0.5 0 0.5 1];
axOVD.YTickLabels = {'-0.5','0', '0.5', '1'};

% Mark own voice segments
hOVDMarker_fixed.LineStyle = 'none';
hOVDMarker_fixed.Marker = 'x';
hOVDMarker_fixed.Color = [1 0 0];
hOVDMarker_adaptive.LineStyle = 'none';
hOVDMarker_adaptive.Marker = 'x';
hOVDMarker_adaptive.Color = [143, 16, 163]./255;
clear FinalDataOVD;

%% Pxx
axPxx = axes('Position',[GUI_xStart 0.2 GUI_xAxesWidth 0.18]);
timeVecShort = datenum(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = 10*log10(FinalDataPxx2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('');
text(timeVecShort(5),freqVecShort(end-1),'PSD (left)','Color',[1 1 1]);

%TickIndexName = timeofday(FinaltimeVecPSD);
%set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set (axPxx,'YTick',1:3:size(FinalDataPxx2,2));
clear FinalDataPxx2;
clear DataMatrixShort;
yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
yaxisLables = strrep(yaxisLables,'000', 'k');
set (axPxx,'YTickLabel',yaxisLables);
set(axPxx ,'ylabel', ylabel('freq bins in Hz'))
set(axPxx,'CLim',[-110 -55]);

hstart = hour(FinaltimeVecPSD(1));
hend = hour(FinaltimeVecPSD(end));


if hstart ~= hend
    XTicksTime = FinaltimeVecPSD;
    
    if (XTicksTime(end).Minute - XTicksTime(1).Minute < 10) % UK
        return;
    end
    
    XTicksTime(:).Minute = 0;
    XTicksTime(:).Second = 0;
    XTicksTime = unique(XTicksTime);
    XTicksTime = datenum(XTicksTime);
else
    XTicksTime = datenum(FinaltimeVecPSD(1:ceil(length(FinaltimeVecPSD)/10):end));
end



XTickLabels = cellstr(datestr(XTicksTime,'HH:MM'));
set(axOVD,'XTick',XTicksTime);
set(axOVD,'XTickLabel','');
set(axRMS,'XTick',XTicksTime);
set(axRMS,'XTickLabel', XTickLabels,'XTickLabelRotation',30)

set(axCoher,'XTick',XTicksTime);
set(axCoher,'XTickLabel',[]);
set(axPxx,'XTick',datenum(XTicksTime));
set(axPxx,'XTickLabel',[]);




%%
if hasSubjectiveData
    situationColors = [...
        66 197 244; % light blue: at home
        255 153   0; % orange: on the way
        165 191 102; % green: society
        166  65 244; % purple: work
        0   0   0; % black: no rating
        ]./255; % RGB scaling
    FinalTimeQ = FinalTimeQ(FinalTimeQ <= FinaltimeVecPSD(end));
    if ~isempty(FinalTimeQ)
        axQ = axes('Position',[GUI_xStart 0.4  PosVecCoher(3) 0.07]);
        
        hold on;
        for ss = 1:length(FinalTimeQ)
            hLineLR = plot(datenum(FinalTimeQ(ss)),1,'bx');
            hLineLE = plot(datenum(FinalTimeQ(ss)),2,'bx');
            hLineIM = plot(datenum(FinalTimeQ(ss)),3,'bx');
            %plot(datenum(FinalTimeQ(ss)-minutes(ReportedDelay(ss))),4,'bx');
            ylim([0.0 4]);
            yticks(1:3);
            yticklabels({'loudness rating','listening effort','impaired'});
            
            ActivityDescription = {'Relaxing','Eating','Kitchen work',...
                'Reading-Computer', 'Music listening', 'Chores' , ...
                'Yard-Balcony' , 'Car driving' , 'Car ride' , ...
                'Bus' , 'Train', 'By foot', 'By bike', ...
                'On visit', 'Party' ,'Restaurant', 'Theater etc', ...
                'Meeting' , 'Admin or med office' , 'Store', ...
                'Office' , 'Workshop' , 'Counter', 'Meeting room', ...
                'Working outside', 'Cantine', 'Other activity'};
            
            Ac = FinalTableOneSubject.Activity((ss));
            situation = FinalTableOneSubject.Situation(ss);
            if situation > 4
                situation = 5;
            end
            if iscell(Ac)
                if (isnumeric(Ac{1}))
                    if Ac{1} == 222
                        Ac{1} = 27; % Re-assign to 'other activity'
                    end
                    %display('Zahl');
                    % set(hLine,'MarkerSize',2*LE{1});
                    hText = text(datenum(FinalTimeQ(ss)),4.15,ActivityDescription{Ac{1}},'FontSize',8);
                    set(hText,'Rotation',30);
                else
                    %             display('Missing Activity');
                    set(hLineLR,'MarkerSize',0.5);
                    set(hLineLE,'MarkerSize',0.5);
                    set(hLineIM,'MarkerSize',0.5);
                end
            elseif isnumeric(Ac)
                if (isnumeric(Ac(1)))
                    if Ac(1) == 222
                        Ac(1) = 27; % Re-assign to 'other activity'
                    end
                    hText = text(datenum(FinalTimeQ(ss)),4.15,ActivityDescription{Ac(1)},'FontSize',8);
                    set(hText,'Rotation',30);
                else
                    %             display('Missing Activity');
                    set(hLineLR,'MarkerSize',0.5);
                    set(hLineLE,'MarkerSize',0.5);
                    set(hLineIM,'MarkerSize',0.5);
                end
            end
            if ~bPrint
                LE = FinalTableOneSubject.ListeningEffort((ss));
                if ~iscell(LE)
                    LE = num2cell(LE);
                end
                if (isnumeric(LE{1}))
                    %display('Zahl');
                    if LE{1} < 111
                        set(hLine,'MarkerSize',2*LE{1});
                    else
                        %             display('LE is 111');
                        set(hLine,'MarkerSize',0.5);
                    end
                else
                    %         display('Missing LE');
                    set(hLine,'MarkerSize',0.5);
                end
                SU = FinalTableOneSubject.SpeechUnderstanding((ss));set(axQ,'YTick',[]);
                set(axQ,'XTick',XTicksTime);
                set(axQ,'XTickLabel',[]);
                xlim([FinaltimeVecPSD(1) FinaltimeVecPSD(end)]);
                if ~iscell(SU)
                    SU = num2cell(SU);
                end
                if (isnumeric(SU{1}))
                    ColorMapSU = flipud([0 1 0; 0 0.8 0; 0.2 0.6 0.2; 0.4 0.4 0.2; 0.6 0.2 0; 0.8 0 0; 1 0 0]);
                    if SU{1} < 100
                        set(hLine,'Color',ColorMapSU(SU{1},:));
                    else % 222 no speech
                        set(hLine,'Color',[0 0 0]);
                    end
                else
                    %         display('Missing SU');
                    set(hLine,'Color',[0 0 1]);
                end
                
                LR = FinalTableOneSubject.LoudnessRating((ss));
                if ~iscell(LR)
                    set(axQ,'YTick',[]);
                    set(axQ,'XTick',XTicksTime);
                    set(axQ,'XTickLabel',[]);
                    xlim([FinaltimeVecPSD(1) FinaltimeVecPSD(end)]);
                    LR = num2cell(LR);
                end
                MarkerFormLR = {'x','o','diamond','<','>','*','square'};
                if (isnumeric(LR{1}))
                    if LR{1} <= numel(MarkerFormLR)
                        set(hLine,'Marker',MarkerFormLR{LR{1}});
                    else
                        %             display('LR too big');
                        set(hLine,'Marker','.');
                    end
                    
                else
                    %         display('Missing LE');
                    set(hLine,'Marker','.');
                end
            else
                LE = FinalTableOneSubject.ListeningEffort((ss));
                LR = FinalTableOneSubject.LoudnessRating((ss));
                IM = FinalTableOneSubject.Impaired((ss));
                % Case: Missing ratingset(axQ,'YTick',[]);
                %             set(axQ,'XTick',XTicksTime);
                %             set(axQ,'XTickLabel',[]);
                xlim([datenum(FinaltimeVecPSD(1)) datenum(FinaltimeVecPSD(end))]);
                if LE > 100
                    hLineLE.Marker = 'x';
                    hLineLE.MarkerSize = 5;
                    hLineLE.LineWidth = 0.5;
                else
                    hLineLE.Marker = 'o';
                    hLineLE.MarkerSize = 2*LE;
                    hLineLE.LineWidth = 2;
                end
                hLineLE.MarkerEdgeColor = situationColors(situation,:);
                
                if LR > 100
                    hLineLR.Marker = 'x';
                    hLineLR.MarkerSize = 5;
                    hLineLR.LineWidth = 0.5;
                else
                    hLineLR.Marker = '*';
                    hLineLR.MarkerSize = 2*((-1)*LR + 8);
                    hLineLR.LineWidth = 2;
                end
                hLineLR.MarkerEdgeColor = situationColors(situation,:);
                
                if IM > 100
                    hLineIM.Marker = 'x';
                    hLineIM.MarkerSize = 5;
                    hLineIM.LineWidth = 0.5;
                else
                    hLineIM.Marker = '^';
                    hLineIM.MarkerSize = 2*IM;
                    hLineIM.LineWidth = 2;
                end
                hLineIM.MarkerEdgeColor = situationColors(situation,:);
                
            end
            
        end
    end
end

xlim([datenum(FinaltimeVecPSD(1)) datenum(FinaltimeVecPSD(end))]);
clear FinaltimeVecPSD;
set(gcf,'PaperPositionMode', 'auto');
if hasSubjectiveData && ~isempty(FinalTimeQ)
    %set(axQ,'YTick',[]);
    set(axQ,'XTick',XTicksTime);
    set(axQ,'XTickLabel',[]);
    linkaxes([axOVD,axRMS,axPxx,axCoher,axQ],'x');
    %legend([hLineLR,hLineLE,hLineIM],'LR','LE','HI', 'Location','southoutside')
else
    linkaxes([axOVD,axRMS,axPxx,axCoher],'x');
end
if bPrint
    set(0,'DefaultFigureColor','remove')
    %     print('-fillpage',[szBaseDir filesep szFolderName filesep 'Fingerprint_' szTestSubject '_' num2str(day(desiredDay)) '_'...
    %         num2str(month(desiredDay)) '_' num2str(year(desiredDay)) ...
    %         '_p' num2str(desiredPart)],'-dpdf');
    save2pdf([obj.stSubject.Folder, filesep, 'graphics', filesep, ...
        'Fingerprint_', obj.stSubject.Name, '_', num2str(day(desiredDay)), ...
        '_', num2str(month(desiredDay)), '_', num2str(year(desiredDay)), ...
        '_p', num2str(desiredPart)], gcf)
    close(gcf);
end

clf;

end

%% Kalibrierungsdaten
%set(axQ,'YTick',[]);

%
%
% COMPUTE RMSf_correction2016 = 100.
% COMPUTE O125_correction2016 = 105.4.
% COMPUTE O250_correction2016 = 101.1.
% COMPUTE O500_correction2016 = 101.1.
% COMPUTE O1000_correction2016 = 101.3.
% COMPUTE O2000_correction2016 = 100.4.
% COMPUTE O4000_correction2016 = 100.9.
%
% COMPUTE RMSf_correction2014 = 85.
% COMPUTE O125_correction2014 = 110.9.
% COMPUTE O250_correction2014 = 93.3.
% COMPUTE O500_correction2014 = 86.7.
% COMPUTE O1000_correction2014 = 82.3.
% COMPUTE O2000_correction2014 = 80.8.
% COMPUTE O4000_correction2014 = 80.5.
% EXECUTE.
%
% * Korrekturwerte PDF per Mail von Joerg am 12.9.2016
%
% COMPUTE O500_PDFcorrection = 26.4.
% COMPUTE O1000_PDFcorrection = 28.8.
% COMPUTE O2000_PDFcorrection = 31.8.
% COMPUTE O4000_PDFcorrection = 34.9.
% EXECUTE.
%
%