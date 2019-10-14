function []=plotPROBANDData(obj, varargin)
% function to  
% Usage [outParam]=plotPROBANDData(inParam)
%
% Usage: 
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% varargin :  specifies optional parameter name/value pairs.
%             getObjectiveData(obj 'PARAM1', val1, 'PARAM2', val2, ...)
%  'PlotWidth'          number that speciefies the width of the desired 
%                       figure in pixels; by default it is set to full 
%                       screen
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Source: based on 
% Version History:
% Ver. 0.01 initial create 14-Oct-2019  JP


% define figure width to full screen in pixels
stRoots = get(0);
% default plot width in pixels
iDefaultPlotWidth = stRoots.ScreenSize(3);

% parse input arguments
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isstruct(x) && ~isempty(x));

p.addParameter('PlotWidth', iDefaultPlotWidth, @(x) isnumeric(x));
p.parse(obj,varargin{:});

% Re-assign values
iPlotWidth = p.Results.PlotWidth;


% flag to use compression or not
compressData = 0; 


% %% lets start with reading objective data
% % desired feature PSD
% szFeature = 'PSD';
% 
% % get all available feature file data
% [DataPSD,TimeVecPSD,stInfoFile] = getObjectiveDataBilert(obj, szFeature);
% 
% 
% version = 1; % JP modified get_psd
% [Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
% clear DataPSD;
% Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);
% 
% if compressData
%     [FinalDataCxy,~] = DataCompactor(Cxy,TimeVecPSD,stControl);
%     [FinalDataPxx,~] = DataCompactor(Pxx,TimeVecPSD,stControl);
%     [FinalDataPyy,~] = DataCompactor(Pyy,TimeVecPSD,stControl);
%     [FinalDataCohe,~] = DataCompactor(Cohe,TimeVecPSD,stControl);
% else
%     FinalDataCxy = Cxy;
%     FinalDataPxx = Pxx;
%     FinalDataPyy = Pyy;
%     FinalDataCohe = Cohe;
% end
% clear Cxy Pxx Pyy;
% 
% % set frequency specific parameters
% stParam.fs = stInfoFile.fs;
% stParam.nFFT = 1024;
% stParam.vFreqRange  = [400 1000]; % frequency range in Hz
% stParam.vFreqIdx = round(stParam.nFFT*stParam.vFreqRange./stParam.fs);
% 
% % averaged Coherence
% MeanCohe = mean(real(Cohe(:,stParam.vFreqIdx(1):stParam.vFreqIdx(2))),2);
% 
% CohTimeSmoothing_s = 0.1;
% fs_cohdata = 1/0.125;
% 
% alpha = exp(-1./(CohTimeSmoothing_s*fs_cohdata));
% MeanCoheTimeSmoothed = filter([1-alpha],[1 -alpha],MeanCohe);
% 
% if compressData
%     [FinalDataMeanCohe,FinaltimeVecPSD]=DataCompactor(MeanCoheTimeSmoothed,TimeVecPSD,stControlOVD);
% else
%     FinalDataMeanCohe = MeanCoheTimeSmoothed;
%     FinaltimeVecPSD = TimeVecPSD;
% end
% clear Cohe MeanCohe MeanCoheTimeSmoothed TimeVecPSD;
% 
% 
% % limit to 125 ... 8000 Hz for optical reasons
% stBandDef.StartFreq = 125;
% stBandDef.EndFreq = 8000;
% stBandDef.Mode = 'onethird';
% stBandDef.fs = stInfoFile.fs;
% [stBandDef] = fftbin2freqband(stParam.nFFT/2+1,stBandDef);
% stBandDef.skipFrequencyNormalization = 1;
% [stBandDefCohe] = fftbin2freqband(stParam.nFFT/2+1,stBandDef);
% 
% % FinalDataCxy2 = FinalDataCxy*stBandDefCohe.ReGroupMatrix;
% FinalDataPxx2 = FinalDataPxx*stBandDefCohe.ReGroupMatrix;
% % FinalDataPyy2 = FinalDataPyy*stBandDefCohe.ReGroupMatrix;
% FinalDataCohe2 = FinalDataCohe*stBandDefCohe.ReGroupMatrix;
% clear FinalDataCohe;
% 
% 
% % desired feature RMS
% szFeature = 'RMS';
% 
% % get all available feature file data
% [DataRMS,TimeVecRMS,~] = getObjectiveDataBilert(obj, szFeature);
% 
% if compressData
%     [FinalDataRMS,FinaltimeVecRMS] = DataCompactor(DataRMS,TimeVecRMS,stControl);
% else
%     FinalDataRMS = DataRMS;
%     FinaltimeVecRMS = TimeVecRMS;
% end
% clear DataRMS TimeVecRMS;
% 
% 
% % logical to save figure
% bPrint = 1;
% 
% stParam.privacy = true;
% 
% 
% %% VOICE DETECTION
% stDataOVD.Coh = [];
% stDataOVD.vOVS = [];
% stDataOVD.snrPrio = [];
% stDataOVD.movAvgSNR = [];
% stDataFVD.vFVS = [];
% 
% [stDataOVD] = OVD3(reshape(FinalDataCxy,[size(FinalDataCxy,2), size(FinalDataCxy,1)]), reshape(FinalDataPxx,[size(FinalDataPxx,2), size(FinalDataPxx,1)]), reshape(FinalDataPyy,[size(FinalDataPyy,2), size(FinalDataPyy,1)]), stParam.fs);
% 
% [stDataFVD] = FVD3(stDataOVD.vOVS,stDataOVD.snrPrio,stDataOVD.movAvgSNR);
% 
% clear FinalDataCxy FinalDataPxx FinalDataPyy;


%% get audio signal and ground truth for voice detection
[WavData, TimeVecWav] = getAudioSignal(obj);


%% plot objective Data
% define figure height full screen in pixels
iPlotHeight = stRoots.ScreenSize(4);

figure('PaperPosition',[0 0 1 1],'Position',[0 0 iPlotWidth iPlotHeight]);
GUI_xStart = 0.05;
GUI_xAxesWidth = 0.9;
mTextTitle = uicontrol(gcf,'style','text');
szTitle = [obj.szCurrentFolder ' ' obj.szNoiseConfig];
set(mTextTitle,'Units','normalized','Position', [0.2 0.93 0.6 0.05], 'String', szTitle,'FontSize',16);


%% Coherence
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
drawnow;
PosVecCoher = get(axCoher,'Position');


%% RMS
Calib_RMS = 100; % needs to be changed...
axRMS = axes('Position',[GUI_xStart 0.09 PosVecCoher(3) 0.09]);
% hRMS = plot(TimeVecRMS,20*log10(DataRMS)+Calib_RMS);
plot(datenum(FinaltimeVecRMS),20*log10(FinalDataRMS)+Calib_RMS);

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

% view estimated own voice sequences (red)
plot(datenum(FinaltimeVecPSD),1.25*vOVS,'rx');
% view estimated futher voice sequences (blue)
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



set(gcf,'PaperPositionMode', 'auto');


linkaxes([axOVD,axRMS,axPxx,axCoher],'x');
% dynamicDateTicks([axOVD,axRMS,axPxx,axCoher,axCoherInvalid,axPxxInvalid],'linked');


if bPrint
    set(0,'DefaultFigureColor','remove')
    exportName = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig ...
        'Fingerprint_VD_' obj.szCurrentFolder '_' obj.szNoiseConfig];
    
    savefig(exportName);
%     saveas(gcf, exportName,'pdf')
end


% fprintf('counted %d times own voice per day\n',sum(stDataOVD.vOVS));
% relative value
OVSrel = sum(stDataOVD.vOVS)/size(stDataOVD.vOVS,2);
fprintf('***estimated %.2f %% own voice per day\n',100*OVSrel);
FVSrel = sum(stDataFVD.vFVS)/size(stDataFVD.vFVS,2);
fprintf('***estimated %.2f %% futher voice per day\n',100*FVSrel);


%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
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