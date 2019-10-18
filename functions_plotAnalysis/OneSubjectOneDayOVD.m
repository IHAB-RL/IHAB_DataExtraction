function [] = OneSubjectOneDayOVD(obj, varargin)
% function to plot a fingerprint for a specific time frame
% analyse data from IHAB
% shows results of Own Voice Detection (OVD) and Futher Voice
% Detection (FVD) by Nils Schreiber (Master 2019)
% Usage: OneSubjectOneDayOVD(obj, varargin)
%
% Parameters
% ----------
% obj : class IHABdata, contains all informations
%
% varargin :  specifies optional parameter name/value pairs.
%             getObjectiveData(obj 'PARAM1', val1, 'PARAM2', val2, ...)
%  'StartTime'          duration to specify the start time of desired data
%                       syntax duration(H,MI,S);
%                       or a number between [0 24], which will be 
%                       transformed to a duration;
%
%  'EndTime'            duration to specify the end time of desired data
%                       syntax duration(H,MI,S);
%                       or a number between [0 24], which will be 
%                       transformed to a duration; 
%                       obviously EndTime should be greater than StartTime;
%
%  'StartDay'           to specify the start day of desired data, allowed
%                       formats are datetime, numeric (i.e. 1 for day one),
%                       char (i.e. 'first', 'last')
%
%  'EndDay'             to specify the end day of desired data, allowed
%                       formats are datetime, numeric (i.e. 1 for day one),
%                       char (i.e. 'first', 'last'); obviously EndDay 
%                       should be greater than or equal to StartDay;
%
%  'stInfo'             struct which contains valid date informations about 
%                       the aboved named 4 parameters; this struct results 
%                       from calling checkInputFormat.m
%
%  'PlotWidth'          number that speciefies the width of the desired 
%                       figure in pixels; by default it is set to full 
%                       screen
%
%  'SamplesPerPixel'    number that speciefies the data point resolution in
%                       samples per pixel; by default it is 5 samples/pixel
%
% 'HigherFreqResolution' logical whether to plot with a low frequency 
%                        resolution (=false) or with the highest possible
%                        frequency resolution (=true)
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% based on:  main.m and plotAllDayFingerprints.m,
% mainly computeDayFingerprintData.m by Nils Schreiber
% Version History:
% Ver. 0.01 initial create 10-Sep-2019  JP
% Ver. 1.0 object-based version, new input 26-Sept-2019 JP

% define figure width to full screen in pixels
stRoots = get(0);
% default plot width in pixels
iDefaultPlotWidth = stRoots.ScreenSize(3);

% default plot resolution in samples (data points) per pixel
iDefaultSamplesPerPixel = 5; 

% parse input arguments
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isa(x,'IHABdata') && ~isempty(x));

p.addParameter('StartTime', 0, @(x) isduration(x) || isnumeric(x));
p.addParameter('EndTime', 24, @(x) isduration(x) || isnumeric(x));
p.addParameter('StartDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('EndDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('PlotWidth', iDefaultPlotWidth, @(x) isnumeric(x));
p.addParameter('SamplesPerPixel', iDefaultSamplesPerPixel, @(x) isnumeric(x));
p.addParameter('HigherFreqResolution', false, @(x) islogical(x));
p.parse(obj,varargin{:});

% Re-assign values
iPlotWidth = p.Results.PlotWidth;
iSamplesPerPixel = p.Results.SamplesPerPixel;
iHigherFreqResolution = p.Results.HigherFreqResolution;

% call function to check input date format and plausibility
stInfo = checkInputFormat(obj, p.Results.StartTime, p.Results.EndTime, ...
    p.Results.StartDay, p.Results.EndDay);


%% lets start with reading objective data
% desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,TimeVecPSD,stInfoFile] = getObjectiveData(obj, szFeature, ...
    'stInfo', stInfo, 'PlotWidth',iPlotWidth, 'SamplesPerPixel', iSamplesPerPixel);


version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
clear DataPSD;
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);

% set frequency specific parameters
stParam.fs = stInfoFile.fs;
stParam.nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
stParam.vFreqRange  = [400 1000]; % frequency range in Hz
stParam.vFreqIdx = round(stParam.nFFT*stParam.vFreqRange./stParam.fs);

% averaged Coherence
MeanCohe = mean(real(Cohe(:,stParam.vFreqIdx(1):stParam.vFreqIdx(2))),2);

CohTimeSmoothing_s = 0.1;
fs_cohdata = 1/0.125;

alpha = exp(-1./(CohTimeSmoothing_s*fs_cohdata));
MeanCoheTimeSmoothed = filter([1-alpha], [1 -alpha], MeanCohe);

if ~iHigherFreqResolution
    % limit to 125 ... 8000 Hz for optical reasons
    stBandDef.StartFreq = 125;
    stBandDef.EndFreq = 8000;
    if stInfoFile.fs/2 <= stBandDef.EndFreq
        stBandDef.EndFreq = 4000;
    end
    stBandDef.Mode = 'onethird';
    stBandDef.fs = stInfoFile.fs;
    [stBandDef] = fftbin2freqband(stParam.nFFT/2+1,stBandDef);
    stBandDef.skipFrequencyNormalization = 1;
    [stBandDefCohe] = fftbin2freqband(stParam.nFFT/2+1,stBandDef);

    PxxShort = Pxx*stBandDefCohe.ReGroupMatrix;
    CoheShort = Cohe*stBandDefCohe.ReGroupMatrix;
    clear Cohe MeanCohe;
end


% desired feature RMS
szFeature = 'RMS';

% get all available feature file data
[DataRMS,TimeVecRMS,~] = getObjectiveData(obj, szFeature, 'stInfo', stInfo, 'PlotWidth',iPlotWidth);


% logical to save figure
bPrint = 1;

stParam.privacy = true;


%% VOICE DETECTION
stDataOVD.Coh = [];
stDataOVD.vOVS = [];
stDataOVD.snrPrio = [];
stDataOVD.movAvgSNR = [];
stDataFVD.vFVS = [];

[stDataOVD] = OVD3(Cxy, Pxx, Pyy, stParam.fs);

[stDataFVD] = FVD3(stDataOVD.vOVS,stDataOVD.snrPrio,stDataOVD.movAvgSNR);

% clear Cxy Pxx Pyy;



%% plot objective Data
% define figure height full screen in pixels
iPlotHeight = stRoots.ScreenSize(4);

figure('PaperPosition',[0 0 1 1],'Position',[0 0 iPlotWidth iPlotHeight]);
GUI_xStart = 0.05;
GUI_xAxesWidth = 0.9;
mTextTitle = uicontrol(gcf,'style','text');
if stInfo.StartDay ~= stInfo.EndDay
    szTitle = [obj.stSubject.Name ' ' datestr(stInfo.StartDay) ' : ' datestr(stInfo.EndDay)];
else
    szTitle = [obj.stSubject.Name ' ' datestr(stInfo.StartDay)];
end
set(mTextTitle,'Units','normalized','Position', [0.2 0.93 0.6 0.05], 'String', szTitle,'FontSize',16);


%% Coherence
axCoher = axes('Position',[GUI_xStart 0.6 GUI_xAxesWidth 0.18]);

if ~iHigherFreqResolution
    nFreqBins = size(PxxShort,2);
    freqVec = 1:nFreqBins;
    
    RealCohe = real(CoheShort(:,:))';
else
    freqVec = 0 : stParam.fs/stParam.nFFT : stParam.fs/2;
    
    RealCohe = real(Cohe(:,:))';
end

% find time gaps and fill them with NaNs
[timeVec, FinalRealCohe] = FillTimeGaps(TimeVecPSD, RealCohe);

timeVec = datenum(timeVec);

imagesc(timeVec,freqVec,FinalRealCohe);
axis xy;
colorbar;
axCoher.Colormap(1,:) = [1 1 1]; % set darkest blue to white for time gaps
title('');
reText=text(timeVec(5),freqVec(end-1),'Re\{Coherence\}','Color',[1 1 1]);
reText.FontSize = 12;
if ~iHigherFreqResolution
    set(axCoher,'YTick',1:3:size(PxxShort,2));
    yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
else
    yaxisLables = axCoher.YTickLabel;
end
yaxisLables = strrep(yaxisLables,'000', 'k');
set(axCoher,'YTickLabel',yaxisLables);
set(axCoher ,'ylabel', ylabel('frequency in Hz'))
set(axCoher,'XTick',[]);
drawnow;
PosVecCoher = get(axCoher,'Position');


%% RMS
Calib_RMS = getCalibConst(obj.stSubject.Name);
axRMS = axes('Position',[GUI_xStart 0.09 PosVecCoher(3) 0.09]);
% hRMS = plot(TimeVecRMS,20*log10(DataRMS)+Calib_RMS);
plot(datenum(TimeVecRMS),20*log10(DataRMS)+Calib_RMS{:});

ylim([30 100]);
yticks([30 50 70 90])
axRMS.YLabel = ylabel('dB SPL');
datetickzoom(axRMS,'x','HH:MM:SS')
xlim([datenum(TimeVecRMS(1)) datenum(TimeVecRMS(end))]);


%% Pxx
axPxx = axes('Position',[GUI_xStart 0.2 GUI_xAxesWidth 0.18]);

if ~iHigherFreqResolution
    PxxLog = 10*log10(PxxShort)';
else
    PxxLog = 10*log10(Pxx)';
end

% find time gaps and fill them with NaNs
[~, PxxLog] = FillTimeGaps(TimeVecPSD, PxxLog);

imagesc(timeVec,freqVec,PxxLog);
axis xy;
colorbar;
axPxx.Colormap(1,:) = [1 1 1]; % set darkest blue to white for time gaps
title('');
psdText=text(timeVec(5),freqVec(end-1),'PSD (left)','Color',[1 1 1]);
psdText.FontSize = 12;
if ~iHigherFreqResolution
    set(axPxx,'YTick',1:3:size(PxxShort,2));
    yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
else
    yaxisLables = axPxx.YTickLabel;
end
yaxisLables = strrep(yaxisLables,'000', 'k');
set(axPxx,'YTickLabel',yaxisLables);
set(axPxx ,'ylabel', ylabel('frequency in Hz'))
set(axPxx,'CLim',[-110 -55]);


%% Results Voice Detection
TimeVecPSD = datenum(TimeVecPSD);

vOVS = double(stDataOVD.vOVS);
vOVS(vOVS == 0) = NaN;
vFVS = double(stDataFVD.vFVS);
vFVS(vFVS == 0) = NaN;
% stDataOVD.meanCoh = mean(real(stDataOVD.Coh(6:64,:)),1);

axOVD = axes('Position',[GUI_xStart 0.8 PosVecCoher(3) 0.13]);
hold on;
hOVD = plot(TimeVecPSD,MeanCoheTimeSmoothed);
hOVD.Color = [0 0 0];

% view estimated own voice sequences (red)
plot(TimeVecPSD,1.25*vOVS,'rx');
% view estimated futher voice sequences (blue)
plot(TimeVecPSD,1.25*vFVS,'bx');
set(axOVD,'XTick',[]);
axOVD.YLabel = ylabel('avg. Re\{Coherence\}');
xlim([TimeVecPSD(1) TimeVecPSD(end)]);
ylim ([-0.5 1.5]);
axOVD.YTick = [-0.5 0 0.5 1];
axOVD.YTickLabels = {'-0.5','0', '0.5', '1'};


set(axOVD,'XTickLabel','');
set(axCoher,'XTickLabel',[]);
set(axPxx,'XTickLabel',[]);

%% assign annotations
iStartAnno = 0.95; % define 'left' position/ start for all annotations

annotationOVD =annotation(gcf,'textbox',...
    'String',{'OVD'},...
    'FitBoxToText','off');
annotationOVD.LineStyle = 'none';
annotationOVD.FontSize = 12;
annotationOVD.Color = [1 0 0];
annotationOVD.Position = [iStartAnno 0.85 0.0251 0.0411];

annotationFVD =annotation(gcf,'textbox',...
    'String',{'FVD'},...
    'FitBoxToText','off');
annotationFVD.LineStyle = 'none';
annotationFVD.FontSize = 12;
annotationFVD.Color = [0 0 1];
annotationFVD.Position = [iStartAnno 0.83 0.0251 0.0411];

annotationRMS =annotation(gcf,'textbox',...
    'String',{'RMS'},...
    'FitBoxToText','off');
annotationRMS.LineStyle = 'none';
annotationRMS.FontSize = 12;
annotationRMS.Position = [iStartAnno 0.112 0.0251 0.0411];


%% get and plot subjective data
[hasSubjectiveData, axQ] = plotSubjectiveData(obj, stInfo, bPrint, GUI_xStart, PosVecCoher);
 
xlim([TimeVecPSD(1) TimeVecPSD(end)]);


set(gcf,'PaperPositionMode', 'auto');
if hasSubjectiveData 
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
    exportName = [obj.stSubject.Folder filesep ...
        'Fingerprint_VD_Comp_' obj.stSubject.Name '_' datestr(stInfo.StartDay,'yymmdd')];
    
    savefig(exportName);
%     saveas(gcf, exportName,'pdf')
end


% print relative values of voice activity
nFrames = size(stDataOVD.vOVS,1);
OVSrel = sum(stDataOVD.vOVS)/nFrames;
fprintf('***estimated %.2f %% own voice per day\n',100*OVSrel);
FVSrel = sum(stDataFVD.vFVS)/nFrames;
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