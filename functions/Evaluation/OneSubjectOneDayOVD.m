function [] = OneSubjectOneDayOVD(stBaseDir, stTestSubject, stDesiredDay, AllParts)
% function to evaluate the Own Voice Detection (OVD) and Futher Voice 
% Detection (FVD) on real IHAB data
% OVD and FVD by Nils Schreiber (Master 2019)
% Usage: OneSubjectOneDayOVD(stBaseDir, stTestSubject, stDesiredDay, AllParts)
%
% input:
%   stBaseDir     - string, path to data folder (needs to be customized)
%   stTestSubject - string, name of subject folder, 
%                   format <subject id>_yymmdd_<experimenter id>
%   stDesiredDay  - datetime, desired day to be analysed
%   AllParts      - logical whether to select all (1) or just one (0) part  
%                   of the desired day
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% contains main.m and plotAllDayFingerprints.m 
% mainly computeDayFingerprintData.m by Nils Schreiber
% Version History:
% Ver. 0.01 initial create 10-Sep-2019  JP


% set parameters for data compression
compressData = 1;
stControl.DataPointRepresentation_s = 5;
stControl.DataPointOverlap_percent = 0;
stControl.szTimeCompressionMode = 'mean';
stControlOVD.DataPointRepresentation_s = stControl.DataPointRepresentation_s;
stControlOVD.DataPointOverlap_percent = 0;
stControlOVD.szTimeCompressionMode = 'max';


%% lets start with reading objective data
% desired feature RMS
stFeature = 'RMS';
[DataRMS,TimeVecRMS] = getObjectiveDataOneDay(stBaseDir,stTestSubject,stDesiredDay,stFeature,[],AllParts);

if compressData
    [FinalDataRMS,FinaltimeVecRMS] = DataCompactor(DataRMS,TimeVecRMS,stControl);
else
    FinalDataRMS = DataRMS;
    FinaltimeVecRMS = TimeVecRMS;
end
clear DataRMS TimeVecRMS;


% desired feature PSD
stFeature = 'PSD';
[DataPSD,TimeVecPSD,~,stInfo] = getObjectiveDataOneDay(stBaseDir,stTestSubject,stDesiredDay, stFeature);

version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
clear DataPSD;
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);

if compressData
    [FinalDataCxy,~] = DataCompactor(Cxy,TimeVecPSD,stControl);
    [FinalDataPxx,~] = DataCompactor(Pxx,TimeVecPSD,stControl);
    [FinalDataPyy,~] = DataCompactor(Pyy,TimeVecPSD,stControl);
    [FinalDataCohe,~] = DataCompactor(Cohe,TimeVecPSD,stControl);
else
    FinalDataCxy = Cxy;
    FinalDataPxx = Pxx;
    FinalDataPyy = Pyy;
    FinalDataCohe = Cohe;
end

% set frequency specific parameters 
stParam.fs = stInfo.fs;
stParam.nFFT = 1024;
stParam.vFreqRange  = [400 1000]; % auszuwertender Frequenzbereich
stParam.vFreqIdx = round(stParam.nFFT*stParam.vFreqRange./stParam.fs);

% averaged Coherence 
MeanCohe = mean(real(Cohe(:,stParam.vFreqIdx(1):stParam.vFreqIdx(2))),2);

CohTimeSmoothing_s = 0.1;
fs_cohdata = 1/0.125;

alpha = exp(-1./(CohTimeSmoothing_s*fs_cohdata));
MeanCoheTimeSmoothed = filter([1-alpha],[1 -alpha],MeanCohe);

if compressData
    [FinalDataMeanCohe,FinaltimeVecPSD]=DataCompactor(MeanCoheTimeSmoothed,TimeVecPSD,stControlOVD);
else
    FinalDataMeanCohe = MeanCoheTimeSmoothed;
    FinaltimeVecPSD = TimeVecPSD;
end
clear Cxy Pxx Pyy Cohe MeanCohe;


% limit to 125 ... 8000 Hz
stBandDef.StartFreq = 125;
stBandDef.EndFreq = 8000;
stBandDef.Mode = 'onethird';
stBandDef.fs = stInfo.fs;
[stBandDef]=fftbin2freqband(stParam.nFFT/2+1,stBandDef);
stBandDef.skipFrequencyNormalization = 1;
[stBandDefCohe]=fftbin2freqband(stParam.nFFT/2+1,stBandDef);

FinalDataCxy2 = FinalDataCxy*stBandDefCohe.ReGroupMatrix;
FinalDataPxx2 = FinalDataPxx*stBandDefCohe.ReGroupMatrix;
FinalDataPyy2 = FinalDataPyy*stBandDefCohe.ReGroupMatrix;
FinalDataCohe2 = FinalDataCohe*stBandDefCohe.ReGroupMatrix;


% logical to save figure
bPrint = 1;

stParam.privacy = true;


%% VOICE DETECTION
stDataOVD.Coh = [];
stDataOVD.vOVS = [];
stDataOVD.snrPrio = [];
stDataOVD.movAvgSNR = [];
stDataFVD.vFVS = [];

[stDataOVD] = OVD3(reshape(FinalDataCxy,[size(FinalDataCxy,2), size(FinalDataCxy,1)]), reshape(FinalDataPxx,[size(FinalDataPxx,2), size(FinalDataPxx,1)]), reshape(FinalDataPyy,[size(FinalDataPyy,2), size(FinalDataPyy,1)]), stParam.fs);

[stDataFVD] = FVD3(stDataOVD.vOVS,stDataOVD.snrPrio,stDataOVD.movAvgSNR);

clear FinalDataCxy FinalDataPxx FinalDataPyy;


%% subjective data
quest = dir([stBaseDir filesep stTestSubject filesep 'Questionnaires_*.mat']);
if ~isempty(quest)
    load([stBaseDir filesep stTestSubject filesep quest.name]);
else
    import_EMA2018(stTestSubject,stBaseDir);
end
isPrintMode = 1;
hasSubjectiveData = 1;

if hasSubjectiveData
    
    SubjectIDTable = QuestionnairesTable.SubjectID;
    
    idx = strcmp(stTestSubject(1:8), SubjectIDTable);
    
    if all(idx == 0)
        error('Subject not found in questionnaire table')
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
        
        dateVecOneSubjectQ(kk) = datetime(str2num(szYear),str2num(szMonth)...
            ,str2num(szDay),str2num(szHour),str2num(szMin),str2num(szSec));
    end
    
    %% reduce to data of one day
    
    dateVecDayOnlyQ = dateVecOneSubjectQ-timeofday(dateVecOneSubjectQ);
    idxDate = find(dateVecDayOnlyQ == stDesiredDay);
    
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



%% plot objective Data

figure('Units','centimeters','PaperPosition',[0 0 1 1],'Position',[0 0 18 29.7]);
GUI_xStart = 0.1300;
GUI_xAxesWidth = 0.7750;
mTextTitle = uicontrol(gcf,'style','text');
set(mTextTitle,'Units','normalized','Position', [0.2 0.93 0.6 0.05], 'String',[stTestSubject ' ' datestr(stDesiredDay)],'FontSize',16);


%% Erst die Coherence
axCoher = axes('Position',[GUI_xStart 0.6 GUI_xAxesWidth 0.18]);

timeVecShort = datenum(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
% DataMatrixShort = real(FinalDataCohe2);
DataMatrixShort = real(FinalDataCohe2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('');
reText=text(timeVecShort(5),freqVecShort(end-1),'Re\{Coherence\}','Color',[1 1 1]);
reText.FontSize = 12;
yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
yaxisLables = strrep(yaxisLables,'000', 'k');
set(axCoher,'YTick',1:3:size(FinalDataPxx2,2));
set(axCoher,'YTickLabel',yaxisLables);
set(axCoher ,'ylabel', ylabel('frequency in Hz'))
set(axCoher,'XTick',[]);

PosVecCoher = get(axCoher,'Position');
drawnow;


%% RMS
Calib_RMS = 104;
axRMS = axes('Position',[GUI_xStart 0.09 PosVecCoher(3) 0.09]);
% hRMS = plot(TimeVecRMS,20*log10(DataRMS)+Calib_RMS);
hRMS = plot(datenum(FinaltimeVecRMS),20*log10(FinalDataRMS)+Calib_RMS);

ylim([30 100]);
yticks([30 50 70 90])
axRMS.YLabel = ylabel('dB SPL');
datetickzoom(axRMS,'x','HH:MM:SS')
xlim([datenum(FinaltimeVecRMS(1)) datenum(FinaltimeVecRMS(end))]);


%% Results Voice Detection
vOVS = double(stDataOVD.vOVS);
vOVS(vOVS == 0) = NaN;
vFVS = double(stDataFVD.vFVS);
vFVS(vFVS == 0) = NaN;
% stDataOVD.meanCoh = mean(real(stDataOVD.Coh(6:64,:)),1);

axOVD = axes('Position',[GUI_xStart 0.8 PosVecCoher(3) 0.13]);
hold on;
hOVD = plot(datenum(FinaltimeVecPSD),FinalDataMeanCohe);
hOVD.Color = [0 0 0];

% Einbinden OVD: 
plot(datenum(FinaltimeVecPSD),1.25*vOVS,'rx');
% Einbinden FVD:
plot(datenum(FinaltimeVecPSD),1.25*vFVS,'bx');
set(axOVD,'XTick',[]);
axOVD.YLabel = ylabel('avg. Re\{Coherence\}');
xlim([datenum(FinaltimeVecPSD(1)) datenum(FinaltimeVecPSD(end))]);
ylim ([-0.5 1.5]);
axOVD.YTick = [-0.5 0 0.5 1];
axOVD.YTickLabels = {'-0.5','0', '0.5', '1'};


%% Pxx
axPxx = axes('Position',[GUI_xStart 0.2 GUI_xAxesWidth 0.18]);
timeVecShort = datenum(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = 10*log10(FinalDataPxx2)';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('');
psdText=text(timeVecShort(5),freqVecShort(end-1),'PSD (left)','Color',[1 1 1]);
psdText.FontSize = 12;
set(axPxx,'YTick',1:3:size(FinalDataPxx2,2));
yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
set(axPxx,'YTickLabel',yaxisLables);
set(axPxx ,'ylabel', ylabel('frequency in Hz'))
set(axPxx,'CLim',[-110 -55]);


set(axOVD,'XTickLabel','');
set(axCoher,'XTickLabel',[]);
set(axPxx,'XTickLabel',[]);


annotationOVD =annotation(gcf,'textbox',...
    'String',{'OVD'},...
    'FitBoxToText','off');
annotationOVD.LineStyle = 'none';
annotationOVD.FontSize = 12;
annotationOVD.Color = [1 0 0];
annotationOVD.Position = [0.82 0.85 0.0251 0.0411];

annotationFVD =annotation(gcf,'textbox',...
    'String',{'FVD'},...
    'FitBoxToText','off');
annotationFVD.LineStyle = 'none';
annotationFVD.FontSize = 12;
annotationFVD.Color = [0 0 1];
annotationFVD.Position = [0.82 0.83 0.0251 0.0411];

annotationRMS =annotation(gcf,'textbox',...
    'String',{'RMS'},...
    'FitBoxToText','off');
annotationRMS.LineStyle = 'none';
annotationRMS.FontSize = 12;
annotationRMS.Position = [0.82 0.112 0.0251 0.0411];


%% plot subjective Data
if hasSubjectiveData
    situationColors = [...
        66 197 244; % light blue: at home
        255 153   0; % orange: on the way
        165 191 102; % green: society
        166  65 244; % purple: work
        0   0   0; % black: no rating
        ]./255; % RGB scaling
    FinalTimeQ = FinalTimeQ((FinalTimeQ <= FinaltimeVecPSD(end)));
    
    if ~isempty(FinalTimeQ)
        axQ = axes('Position',[GUI_xStart 0.4  PosVecCoher(3) 0.13]);
        
        hold on;
        for ss = 1:length(FinalTimeQ)
            
            hLineLR = plot(datenum(FinalTimeQ(ss)-ReportedDelay(ss)),1,'bx');
            hLineLE = plot(datenum(FinalTimeQ(ss)-ReportedDelay(ss)),2.5,'bx');
            hLineIM = plot(datenum(FinalTimeQ(ss)-ReportedDelay(ss)),4,'bx');
            hLineSU = plot(datenum(FinalTimeQ(ss)-ReportedDelay(ss)),5.5,'bx');
            hLineIP = plot(datenum(FinalTimeQ(ss)-ReportedDelay(ss)),7,'bx');
            %plot(datenum(FinalTimeQ(axQ.YTickLabel{iTick}ss)-minutes(ReportedDelay(ss))),4,'bx');
            ylim([0.0 9]);
            yticks([1 2.5 4 5.5 7]);
            yticklabels({'loudness rating','listening effort','impairment rating','speech understanding','importance'});
            
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
                    % set(hLine,'MarkerSize',2*LE{1});
                    hText = text(datenum(FinalTimeQ(ss)),8.15,ActivityDescription{Ac{1}},'FontSize',10);
                    set(hText,'Rotation',40);
                else
                    %             display('Missing Activity');
                    set(hLineLR,'MarkerSize',0.5);
                    set(hLineLE,'MarkerSize',0.5);
                    set(hLineIM,'MarkerSize',0.5);
                    set(hLineSU,'MarkerSize',0.5);
                    set(hLineIP,'MarkerSize',0.5);
                end
            elseif isnumeric(Ac)
                if (isnumeric(Ac(1)))
                    if Ac(1) == 222
                        Ac(1) = 27; % Re-assign to 'other activity'
                    end
                    hText = text(datenum(FinalTimeQ(ss)),8.15,ActivityDescription{Ac(1)},'FontSize',10);
                    set(hText,'Rotation',40);
                else
                    %             display('Missing Activity');
                    set(hLineLR,'MarkerSize',0.5);
                    set(hLineLE,'MarkerSize',0.5);
                    set(hLineIM,'MarkerSize',0.5);
                    set(hLineSU,'MarkerSize',0.5);
                    set(hLineIP,'MarkerSize',0.5);
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
                SU = FinalTableOneSubject.SpeechUnderstanding((ss));
                set(axQ,'YTick',[]);
                %                 set(axQ,'XTick',XTicksTime);
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
                    %                     set(axQ,'XTick',XTicksTime);
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
                SU = FinalTableOneSubject.SpeechUnderstanding(ss);
                IP = FinalTableOneSubject.Importance(ss);
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
                
                if SU > 100
                    hLineSU.Marker = 'x';
                    hLineSU.MarkerSize = 5;
                    hLineSU.LineWidth = 0.5;
                else
                    hLineSU.Marker = 's';
                    hLineSU.MarkerSize = 2*IM;
                    hLineSU.LineWidth = 2;
                end
                hLineSU.MarkerEdgeColor = situationColors(situation,:);
                
                if IP > 100
                    hLineIP.Marker = 'x';
                    hLineIP.MarkerSize = 5;
                    hLineIP.LineWidth = 0.5;
                else
                    hLineIP.Marker = 'p';
                    hLineIP.MarkerSize = 2*IM;
                    hLineIP.LineWidth = 2;
                end
                hLineIP.MarkerEdgeColor = situationColors(situation,:);
                
            end
            
        end
    end
end

xlim([datenum(FinaltimeVecPSD(1)) datenum(FinaltimeVecPSD(end))]);
set(gcf,'PaperPositionMode', 'auto');
if hasSubjectiveData && ~isempty(FinalTimeQ)
    axQ.YAxis.Visible = 'off';
    axQ.XAxis.Visible = 'off';
    lenYTickLabels = numel(axQ.YTickLabel);
    
    for iTick = 1:lenYTickLabels
        axQ.YTickLabel{iTick} = ['\color[rgb]{0,0,0}' axQ.YTickLabel{iTick}];
    end
    
    axQ.XTickLabel = [];
    
    linkaxes([axOVD,axRMS,axPxx,axCoher,axQ],'x');
    % dynamicDateTicks([axOVD,axRMS,axPxx,axCoher,axCoherInvalid,axPxxInvalid,axQ],'linked','HH:mm');
else
    linkaxes([axOVD,axRMS,axPxx,axCoher],'x');
    % dynamicDateTicks([axOVD,axRMS,axPxx,axCoher,axCoherInvalid,axPxxInvalid],'linked');
    
end


if bPrint
    set(0,'DefaultFigureColor','remove')
%     datestr(stDesiredDay)% add date
    exportName = [stBaseDir filesep stTestSubject filesep ...
        'Fingerprint_VD_' stTestSubject]; 
    
    savefig(exportName);
    saveas(gcf, exportName,'pdf')
end



% fprintf('counted %d times own voice per day\n',sum(stDataOVD.vOVS));
% relative value
OVSrel = sum(stDataOVD.vOVS)/size(stDataOVD.vOVS,2);
fprintf('***estimated %.2f %% own voice per day\n',100*OVSrel);
FVSrel = sum(stDataFVD.vFVS)/size(stDataFVD.vFVS,2);
fprintf('***estimated %.2f %% futher voice per day\n',100*FVSrel);




%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> Jule Pohlhausen
% Institute for Hearing Technology and Audiology
% Jade University of Applied Sciences
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% eof