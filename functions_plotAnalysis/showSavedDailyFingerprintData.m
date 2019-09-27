
%function hFig = showSavedDailyFingerprintData(szBaseDir, desiredDay,desiredPart,szMatFile)

% display day fingerprints of HALLO data
clear
close all
format long

% Some GUI Defintion
GUI_xStart = 0.07;
GUI_xAxesWidth = 0.92;

% Todo
%- Kalibrierung auf SPL (must)
% Y -Ticks auf ganze Stunden bzw halbe Stunden
% Sauberer Zoom

%% 
%if (nargin < 1)
    szBaseDir = '/media/nils/HDD/ObjectiveDataAnalysisToolbox/HALLO_EMA2016_all';
    szDataMatFile = 'Questionnaires_all_out.mat';
    %szBaseDir = 'D:\Research\Projekte\HALLO\matlab\EMA_Analyse';
    %szDataMatFile = 'Questionnaires2.mat';
    szTestSubject =  'CK09LM19';
    desiredDay = datetime(2016,11,19);
    desiredPart = 2; 

    % szTestSubject =  'EL04ER22';
    % desiredDay = datetime(2016,3,6);
    % desiredPart = 3;


    %szTestSubject =  'ER05TZ14';
    %desiredDay = datetime(2015,8,20);
    %desiredPart = 2;
    
    %szTestSubject =  'AS05EB18';
    %desiredDay = datetime(2016,12,2);
    %desiredPart = 1; 
%end
szFullFile = [szBaseDir filesep szDataMatFile];
load (szFullFile)



dataFileName = [ szBaseDir filesep szTestSubject '_FinalDat_' num2str(day(desiredDay)) '_'...
    num2str(month(desiredDay)) '_' num2str(year(desiredDay)) ...
    '_p' num2str(desiredPart)];

%load AS05EB18_FinalDat_2_12_2016_p1.mat
%load CK09LM19_FinalDat_19_11_2016_p1.mat
%load EL04ER22_FinalDat_6_3_2016_p3.mat
%load ER05TZ14_FinalDat_20_8_2015_p2.mat
load (dataFileName);

%% Define Calibration Values
if (year(desiredDay) > 2014)
    Callib_RMS = 100;
else
    Callib_RMS = 85;
end    


SubjectIDTable = QuestionnairesTable.SubjectID;

idx = strcmp(szTestSubject,SubjectIDTable );

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

FinalIdxQ = find (dateVecOneSubjectQ(idxDate)>FinaltimeVecRMS(1));


FinalTimeQ = dateVecOneSubjectQ(idxDate(FinalIdxQ));
FinalTableOneSubject = TableOneSubject(idxDate(FinalIdxQ),:);

for kk = 1:height(FinalTableOneSubject)
      AssesDelay = FinalTableOneSubject.AssessDelay{kk};
    if (~ischar(AssesDelay))
        if (AssesDelay <= 5)
            ReportedDelay(kk) = (AssesDelay-1)*5;
        elseif (AssesDelay == 5)
            ReportedDelay(kk) = 30;
        elseif (AssesDelay == 6)
            ReportedDelay(kk) = 40; % Could be everything
        end
    else
        ReportedDelay(kk) = 0;
    end
end


%% objective Data

hFig = figure('Units','normalized','Position',[0.15 0.05 0.8 0.85]);

mTextTitle = uicontrol(gcf,'style','text');
set(mTextTitle, 'Units','normalized','Position', [0.2 0.91 0.6 0.05], 'String',[szTestSubject ' Part = ' num2str(desiredPart) '  ' datestr(desiredDay) ],'FontSize',16);
mTextOVD = uicontrol(gcf,'style','text');
set(mTextOVD, 'Units','normalized','Position', [0.9 0.76 0.1 0.05], 'String','OVD','FontSize',12);
mTextRMS = uicontrol(gcf,'style','text');
set(mTextRMS, 'Units','normalized','Position', [0.9 0.092 0.1 0.05], 'String','RMS','FontSize',12);

%% Erst die Coherence
axCoher = axes('Position',[GUI_xStart 0.55 GUI_xAxesWidth 0.18]);

fs = 16000;
PlotMaxFreq = 8000;
freq_vek = linspace(0,fs/2,size(FinalDataPxx,2));
MaxFreqIndex = round(PlotMaxFreq/(fs/2)*size(FinalDataPxx,2));
%timeVecShort = 1:length(FinaltimeVecPSD);
timeVecShort = datenum(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = (FinalDataCohe2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('');
text(timeVecShort(5),freqVecShort(end-1),'Re\{Coherence\}','Color',[1 1 1]);
%TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
%TickIndexName = timeofday(FinaltimeVecPSD);
%set (gca,'XTick',TickIndex);
%set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
%set (gca,'YTick',1:3:size(FinalDataPxx2,2));
%set (gca,'YTickLabel',stBandDef.MidFreq(1:3:end));
set (gca,'XTick',[]);
set (gca,'YTick',1:3:size(FinalDataPxx2,2));
set (gca,'YTickLabel',stBandDef.MidFreq(1:3:end));

% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';

PosVecCoher = get(axCoher,'Position');

%% RMS und OVD

axRMS = axes('Position',[GUI_xStart 0.09 PosVecCoher(3) 0.09]);
plot((FinaltimeVecRMS),20*log10(FinalDataRMS)+Callib_RMS,'DatetimeTickFormat','HH:mm');
set(axRMS,'XLim',[FinaltimeVecRMS(1) FinaltimeVecRMS(end)]);
ylim([25 95]);

axOVD = axes('Position',[GUI_xStart 0.75  PosVecCoher(3) 0.09]);
plot((FinaltimeVecPSD),FinalDataMeanCohe,'DatetimeTickFormat','HH:mm');
hold on;
idx = find(FinalDataOVD>0.5);
plot((FinaltimeVecPSD(idx)),FinalDataOVD(idx),'rx','DatetimeTickFormat','HH:mm');
%for i = 1:length(idx); 
%    line(datenum([FinaltimeVecPSD(idx(i)) FinaltimeVecPSD(idx(i))]), [0.95 1], 'color','red', 'linewidth', 2); 
%end


xlim([FinaltimeVecPSD(1) FinaltimeVecPSD(end)]);

hstart = hour(FinaltimeVecPSD(1))+1;
hend = hour(FinaltimeVecPSD(end));
YTicksTime = FinaltimeVecPSD(1)+seconds(1)-timeofday(FinaltimeVecPSD(1))+hours(hstart):hours(1):FinaltimeVecPSD(1)+seconds(1)-timeofday(FinaltimeVecPSD(1))+hours(hend);
set(axOVD,'XTick',YTicksTime);
set(axRMS,'XTick',YTicksTime);
set(axCoher,'XTick',datenum(YTicksTime));
set(axCoher,'XTickLabel',[]);

datetime(FinaltimeVecPSD(1),'ConvertFrom','datenum');

ylim ([-0.5 1.1]);
set(axOVD,'XAxisLocation','top');
%for i = 1:length(xData); 
%    line([xData(i) xData(i)], [0.95 1], 'color','red', 'linewidth', 2); 
%end

%linkaxes([axRMS axOVD],'x');
%TickIndexName = timeofday(FinaltimeVecPSD);
%set(gcf,'UserData',TickIndexName);

%h = zoom;
%h.ActionPostCallback = @drawYTick_cb;
%h.Enable = 'on';

%% Coherence


%linkaxes([axCoher axRMS axOVD],'x');

%% Pxx
axPxx = axes('Position',[GUI_xStart 0.2 GUI_xAxesWidth 0.18]);

%timeVecShort = 1:length(FinaltimeVecPSD);
timeVecShort = datenum(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = 10*log10(FinalDataPxx2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
%title('Pxx in subbands');
title('');
text(timeVecShort(5),freqVecShort(end-1),'PSD (left)','Color',[1 1 1]);

%TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
%set (gca,'XTick',TickIndex);
%set (gca,'XTick',[]);
set(axPxx,'XTick',datenum(YTicksTime));
set(axPxx,'XTickLabel',[]);

%TickIndexName = timeofday(FinaltimeVecPSD);
%set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set (gca,'YTick',1:3:size(FinalDataPxx2,2));
set (gca,'YTickLabel',stBandDef.MidFreq(1:3:end));
%set(gcf,'UserData',TickIndexName);
%h = zoom;
%h.ActionPostCallback = @drawYTick_cb;
%h.Enable = 'on';
set(gca,'CLim',[-110 -55]);

%linkaxes([axCoher axPxx],'x');


%%
axQ = axes('Position',[GUI_xStart 0.4  PosVecCoher(3) 0.05]);

hold on;
for ss = 1:length(FinalTimeQ)
    hLine = plot((FinalTimeQ((ss))),1,'bx','DatetimeTickFormat','HH:mm');
    plot((FinalTimeQ((ss))-minutes(ReportedDelay(ss))),1.1,'bx','DatetimeTickFormat','HH:mm');
    ylim([0.95 1.15]);
%     ActivityDescription = {'Ausruhen','Essen','K�chenarbeit',...
%     'Lesen Computer', 'Musik h�ren', 'Hausarbeit sonst' , ...
%     'Garten Balkon' , 'Auto selbst' , 'Auto mit' , ...
%     'Bus' , 'Bahn', 'ZuFu�', 'Fahrrad', ...
%     'Besuchen', 'Feier' ,'Restaurant', 'Theater etc', ...
%     'Versammlung' , 'Beh�rde Praxis' , 'Gesch�ft', ...
%     'B�ro' , 'Werkstatt' , 'Schalter', 'Besprechungsraum', ...
%     'Drau�en', 'Kantine', 'Sonstiges'};

    ActivityDescription = {'Relaxing','Eating','Kitchen work',...
    'Reading-Computer', 'Music listening', 'Chores' , ...
    'Yard-Balcony' , 'Car driving' , 'Car ride' , ...
    'Bus' , 'Train', 'By foot', 'By bike', ...
    'On visit', 'Party' ,'Restaurant', 'Theater etc', ...
    'Meeting' , 'Admin or med office' , 'Store', ...
    'Office' , 'Workshop' , 'Counter', 'Meeting room', ...
    'Working outside', 'Cantine', 'Other activity'}; 

    Ac = FinalTableOneSubject.Activity_1((ss));
    if (isnumeric(Ac{1}))
        %display('Zahl');
        % set(hLine,'MarkerSize',2*LE{1});
        hText = text(datenum(FinalTimeQ((ss))),1.15,ActivityDescription{Ac{1}},'FontSize',8);
        %text(datenum(minutes(30) + dateVecAllFeatZCR(idx(idx2(end)+1))-AllDates(kk)),kk+0.15,num2str(PartCounter+1),'Color','green');
        set(hText,'Rotation',30);
    else
        display('Missing Activity');
        set(hLine,'MarkerSize',0.5);
    end
    
    
    LE = FinalTableOneSubject.ListeningEffort((ss));
    if (isnumeric(LE{1}))
        %display('Zahl');
        set(hLine,'MarkerSize',2*LE{1});
    else
        display('Missing LE');
        set(hLine,'MarkerSize',0.5);
    end
    SU = FinalTableOneSubject.SpeechUnderstanding((ss));
    if (isnumeric(SU{1}))
        %display('Zahl');
        ColorMapSU = flipud([0 1 0; 0 0.8 0; 0.2 0.6 0.2; 0.4 0.4 0.2; 0.6 0.2 0; 0.8 0 0; 1 0 0]);
        if SU{1} < 100
            set(hLine,'Color',ColorMapSU(SU{1},:));
        else % 222 no speech
            set(hLine,'Color',[0 0 0]);
        end
    else
        display('Missing SU');
        set(hLine,'Color',[0 0 1]);
    end
    
    LR = FinalTableOneSubject.LoudnessRating((ss));
    if (isnumeric(LR{1}))
        %display('Zahl');
        MarkerFormLR = {'x','o','diamond','<','>','*','square'};
        set(hLine,'Marker',MarkerFormLR{LR{1}});
    else
        display('Missing LE');
        set(hLine,'Marker','.');
    end
    set(axQ,'YTick',[]);
    %set (axQ,'XTick',[]);
    set(axQ,'XTick',YTicksTime);
    set(axQ,'XTickLabel',[]);    
    xlim([datetime(FinaltimeVecPSD(1)) datetime(FinaltimeVecPSD(end))]);
    
end

%linkaxes([axOVD axRMS axCoher axPxx axQ],'x');
hZoom = zoom;
hZoom.ActionPostCallback = @CallbackZoomFingerprint;
hZoom.Enable = 'on';



%print([szBaseDir filesep 'Fingerprint_' szTestSubject],'-dpdf');



%end

% function CallbackZoomFingerprint(obj,evd)
% 
% newLim = evd.Axes.XLim;
% NewXTimeStart = datetime(newLim(1),'ConvertFrom','datenum');
% NewXTimeEnd = datetime(newLim(2),'ConvertFrom','datenum');
% DisplayXTimeRange = NewXTimeEnd-NewXTimeStart;
% 
% if hours(DisplayXTimeRange) > 4
%     deltaTime = hours(1);
% elseif hours(DisplayXTimeRange) > 1 && hours(DisplayXTimeRange) <= 4 
%     deltaTime = hours(0.25);
% elseif minutes(DisplayXTimeRange) > 10 && hours(DisplayXTimeRange) <= 60 
%     deltaTime = minutes(5);
% elseif minutes(DisplayXTimeRange) > 1 && hours(DisplayXTimeRange) <= 10 
%     deltaTime = minutes(1);
% elseif seconds(DisplayXTimeRange) > 30 && hours(DisplayXTimeRange) <= 60 
%     deltaTime = seconds(5);
% elseif seconds(DisplayXTimeRange) > 10 && hours(DisplayXTimeRange) <= 30 
%     deltaTime = seconds(2);
% elseif seconds(DisplayXTimeRange) > 1 && hours(DisplayXTimeRange) <= 10 
%     deltaTime = seconds(1);
% end
%     
%     
% 
% 
% hstart = hour(NewXTimeStart);
% hend = hour(NewXTimeEnd)+1;
% 
% XTickAll = NewXTimeStart-timeofday(NewXTimeStart)+hours(hstart):deltaTime:...
%     NewXTimeStart-timeofday(NewXTimeStart)+hours(hend);
% 
% idx = find (XTickAll > NewXTimeStart & XTickAll < NewXTimeEnd);
% 
% 
% %idx = find (datenum(XTickAll)> newLim(1) && datenum(XTickAll) < newLim(2));
% 
% XTicksTime = XTickAll(idx);
% 
% 
% %XTicksTime = NewXTimeStart(1)+seconds(1)-timeofday(NewXTimeStart(1))+hours(hstart):deltaTime:NewXTimeStart(1)+seconds(1)-timeofday(NewXTimeStart(1))+hours(hend);
% 
% AxesArray = findobj(gcf,'Type','Axes');
% 
% for kk = 1:length(AxesArray)
% set(AxesArray(kk),'XTick',datenum(XTicksTime));
% end
% set(axRMS,'XTick',datenum(XTicksTime));
% set(axCoher,'XTick',datenum(XTicksTime));
% set(axPxx,'XTick',datenum(XTicksTime));
% set(axQ,'XTick',datenum(XTicksTime));

% % devide xaxis 
% TickIndex = ceil(newLim(1)):round((newLim(2)-newLim(1))/5):floor(newLim(2));
% TickIndex = unique(TickIndex);
% %set (gca,'XTick',TickIndex);
% if (minutes(diff([TickIndexName(TickIndex(1)) TickIndexName(TickIndex(end))]))> 5)
%     TickIndex = ceil(newLim(1)):round((newLim(2)-newLim(1))/5):floor(newLim(2));
%     TickIndex = unique(TickIndex);
%     set (gca,'XTick',TickIndex);
%     set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% else
%     set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM:SS'));
%     TickIndex = ceil(newLim(1)):ceil((newLim(2)-newLim(1))/4):floor(newLim(2));
%     TickIndex = unique(TickIndex);
%     set (gca,'XTick',TickIndex);
%     set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM:SS'));
% end



%end


% %%
% figure;
% plot(FinaltimeVecRMS,20*log10(FinalDataRMS));
% 
% figure;
% plot(FinaltimeVecPSD,FinalDataOVD);
% figure;
% plot(FinaltimeVecPSD,FinalDataMeanCohe);
% 
% 
% 
% fs = 16000;
% PlotMaxFreq = 8000;
% freq_vek = linspace(0,fs/2,size(FinalDataPxx,2));
% MaxFreqIndex = round(PlotMaxFreq/(fs/2)*size(FinalDataPxx,2));
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = freq_vek(1:MaxFreqIndex);
% DataMatrixShort = real(FinalDataCohe(:,1:MaxFreqIndex))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% title('Coherence');
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% 
% figure;
% %set(gcf,'Units','normalized','Position',[0.02 0.3 0.96 0.58]);
% %subplot(1,2,1)
% %imagesc((1:size(Pxx,1))/DataInfo.nFrames,freq_vek(1:MaxFreqIndex),10*log10((Pxx(:,1:MaxFreqIndex)')));
% %imagesc(timeVecPSD(1:SubSample:end),freq_vek(1:MaxFreqIndex),10*log10((Pxx((1:SubSample:end),1:MaxFreqIndex)))');
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = freq_vek(1:MaxFreqIndex);
% DataMatrixShort = 10*log10((FinalDataPxx(:,1:MaxFreqIndex)))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% 
% axis xy;
% colorbar;
% set(gca,'CLim',[-110 -15]);
% title('PSD Left')
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% 
% %subplot(1,2,2)
% 
% %imagesc((1:size(Pxx,1))/DataInfo.nFrames,freq_vek(1:MaxFreqIndex),10*log10((Pyy(:,1:MaxFreqIndex)')));
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = freq_vek(1:MaxFreqIndex);
% DataMatrixShort = 10*log10((FinalDataPyy(:,1:MaxFreqIndex)))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% set(gca,'CLim',[-110 -15]);
% title('PSD right')
% 
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:mm'));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% %
% %
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = freq_vek(1:MaxFreqIndex);
% DataMatrixShort = 10*log10((FinalDataCxy(:,1:MaxFreqIndex)))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% set(gca,'CLim',[-110 -15]);
% title('|C_{xy}|')
% 
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% 
% 
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = 1:size(FinalDataPxx2,2);
% DataMatrixShort = 10*log10(FinalDataPxx2(:,:))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% title('Pxx in subbands');
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% set (gca,'YTick',1:1:size(FinalDataPxx2,2));
% set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% set(gca,'CLim',[-110 -15]);
% 
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = 1:size(FinalDataPyy2,2);
% DataMatrixShort = 10*log10(FinalDataPxx2(:,:))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% title('Pyy in subbands');
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% set (gca,'YTick',1:1:size(FinalDataPxx2,2));
% set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% set(gca,'CLim',[-110 -15]);
% 
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = 1:size(FinalDataPxx2,2);
% DataMatrixShort = (FinalDataCohe2(:,:))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% title('Coherence in subbands');
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% set (gca,'YTick',1:1:size(FinalDataPxx2,2));
% set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% 
% figure;
% timeVecShort = 1:length(FinaltimeVecPSD);
% freqVecShort = 1:size(FinalDataPxx2,2);
% DataMatrixShort = 10*log10(FinalDataCxy2(:,:))';
% imagesc(timeVecShort,freqVecShort,DataMatrixShort);
% axis xy;
% colorbar;
% title('Cxy in subbands');
% TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
% set (gca,'XTick',TickIndex);
% TickIndexName = timeofday(FinaltimeVecPSD);
% set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
% set (gca,'YTick',1:1:size(FinalDataPxx2,2));
% set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
% set(gcf,'UserData',TickIndexName);
% h = zoom;
% h.ActionPostCallback = @drawYTick_cb;
% h.Enable = 'on';
% set(gca,'CLim',[-110 -15]);
% 
% 
% %% Kalibrierungsdaten
% % 
% % 
% % 
% % COMPUTE RMSf_correction2016 = 100.
% % COMPUTE O125_correction2016 = 105.4.
% % COMPUTE O250_correction2016 = 101.1.
% % COMPUTE O500_correction2016 = 101.1.
% % COMPUTE O1000_correction2016 = 101.3.
% % COMPUTE O2000_correction2016 = 100.4.
% % COMPUTE O4000_correction2016 = 100.9.
% % 
% % COMPUTE RMSf_correction2014 = 85.
% % COMPUTE O125_correction2014 = 110.9.
% % COMPUTE O250_correction2014 = 93.3.
% % COMPUTE O500_correction2014 = 86.7.
% % COMPUTE O1000_correction2014 = 82.3.
% % COMPUTE O2000_correction2014 = 80.8.
% % COMPUTE O4000_correction2014 = 80.5.
% % EXECUTE.
% % 
% % * Korrekturwerte PDF per Mail von J�rg am 12.9.2016
% % 
% % COMPUTE O500_PDFcorrection = 26.4.
% % COMPUTE O1000_PDFcorrection = 28.8.
% % COMPUTE O2000_PDFcorrection = 31.8.
% % COMPUTE O4000_PDFcorrection = 34.9.
% % EXECUTE.
% % 
% % 
%