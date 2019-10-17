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


%% lets start with reading objective data
% desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,TimeVecPSD,stInfoFile] = getObjectiveDataBilert(obj, szFeature);


version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);
clear DataPSD;
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);


% set frequency specific parameters
stParam.fs = stInfoFile.fs;
stParam.nFFT = 1024;
stParam.vFreqRange  = [400 1000]; % frequency range in Hz
stParam.vFreqIdx = round(stParam.nFFT*stParam.vFreqRange./stParam.fs);

% averaged Coherence
MeanCohe = mean(real(Cohe(:,stParam.vFreqIdx(1):stParam.vFreqIdx(2))),2);

CohTimeSmoothing_s = 0.1;
fs_cohdata = 1/0.125;

alpha = exp(-1./(CohTimeSmoothing_s*fs_cohdata));
MeanCoheTimeSmoothed = filter([1-alpha],[1 -alpha],MeanCohe);


isFreqLim = 0;
if isFreqLim
    % limit to 125 ... 8000 Hz for optical reasons
    stBandDef.StartFreq = 125;
    stBandDef.EndFreq = 8000;
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
[DataRMS,TimeVecRMS,~] = getObjectiveDataBilert(obj, szFeature);


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

clear FinalDataCxy FinalDataPxx FinalDataPyy;


%% get recorded audio signal
[WavData, TimeVecWav, Fs] = getAudioSignal(obj);

% and ground truth labels for voice activity
obj.fsVD = stInfoFile.nFrames / 60;
obj.NrOfBlocks = size(stDataFVD.vFVS(:)',2);
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

% look for hits and false alarms
vOVS = double(stDataOVD.vOVS)';
vFVS = double(stDataFVD.vFVS);

% pre allocation
vHit.OVD = zeros(size(vOVS));
vFalseAlarm.OVD = zeros(size(vOVS));
vHit.FVD = zeros(size(vFVS));
vFalseAlarm.FVD = zeros(size(vFVS));

vHit.OVD(groundTrOVS == vOVS) = groundTrOVS(groundTrOVS == vOVS);
vFalseAlarm.OVD(groundTrOVS ~= vOVS) = vOVS(groundTrOVS ~= vOVS);
vHit.FVD(groundTrFVS == vFVS) = groundTrFVS(groundTrFVS == vFVS);
vFalseAlarm.FVD(groundTrFVS ~= vFVS) = vFVS(groundTrFVS ~= vFVS);


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

timeVec = datenum(TimeVecPSD);
if isFreqLim
    nFreqBins = size(PxxShort,2);
    freqVec = 1:nFreqBins;

    RealCohe = real(CoheShort(:,:))';
else
    freqVec = 0 : stParam.fs/stParam.nFFT : stParam.fs/2;
    
    RealCohe = real(Cohe(:,:))';
end
imagesc(timeVec,freqVec,RealCohe);
axis xy;
colorbar;
title('');
reText=text(timeVec(5),freqVec(end-10),'Re\{Coherence\}','Color',[1 1 1]);
reText.FontSize = 12;
if isFreqLim
    yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
    yaxisLables = strrep(yaxisLables,'000', 'k');
    set(axCoher,'YTick',1:3:nFreqBins);
    set(axCoher,'YTickLabel',yaxisLables);
end
set(axCoher ,'ylabel', ylabel('frequency in Hz'))
set(axCoher,'XTick',[]);
drawnow;
PosVecCoher = get(axCoher,'Position');


%% RMS
Calib_RMS = 100; % needs to be changed...
axRMS = axes('Position',[GUI_xStart 0.09 PosVecCoher(3) 0.09]);
plot(datenum(TimeVecRMS),20*log10(DataRMS)+Calib_RMS);

ylim([30 100]);
yticks([30 50 70 90])
axRMS.YLabel = ylabel('dB SPL');
datetickzoom(axRMS,'x','HH:MM:SS');
xlim([timeVec(1) timeVec(end)]);


%% audio signal with labels
axAudio = axes('Position',[GUI_xStart 0.41  PosVecCoher(3) 0.16]);
plot(datenum(TimeVecWav(1:100:end)),WavData(1:100:end,1));
hold on;
vTimeLabels = linspace(timeVec(1),timeVec(end),obj.NrOfBlocks);
plot(vTimeLabels, vHit.OVD, 'r', 'LineWidth', 1.5);
plot(vTimeLabels, vFalseAlarm.OVD, 'Color', [0.65 0.65 0.65]);
plot(vTimeLabels, vHit.FVD, 'b', 'LineWidth', 1.5);
plot(vTimeLabels, vFalseAlarm.FVD, 'Color', [0.85 0.85 0.85]);
% patch('Faces',vTimeLabels,'Vertices',vHit.OVD,'FaceColor','red','FaceAlpha',.3);
% siehe IHABdata Ziele 1547ff ...

set(axAudio,'XTick',[]);
axAudio.YLabel = ylabel('amplitude');
xlim([timeVec(1) timeVec(end)]);


%% Results Voice Detection with mean smooted coherence
axOVD = axes('Position',[GUI_xStart 0.8 PosVecCoher(3) 0.13]);
hold on;
hOVD = plot(datenum(TimeVecPSD),MeanCoheTimeSmoothed);
hOVD.Color = [0 0 0];

% vOVS = double(stDataOVD.vOVS);
% vOVS(vOVS == 0) = NaN;
% vFVS = double(stDataFVD.vFVS);
% vFVS(vFVS == 0) = NaN;
% stDataOVD.meanCoh = mean(real(stDataOVD.Coh(6:64,:)),1);
% % view estimated own voice sequences (red)
% plot(datenum(TimeVecPSD),1.25*vOVS,'rx');
% % view estimated futher voice sequences (blue)
% plot(datenum(TimeVecPSD),1.25*vFVS,'bx');

groundTrOVS(groundTrOVS == 0) = NaN;
groundTrFVS(groundTrFVS == 0) = NaN;
plot(vTimeLabels, 1.15*groundTrOVS, 'rx');
plot(vTimeLabels, 1.25*groundTrFVS, 'bx');
set(axOVD,'XTick',[]);
axOVD.YLabel = ylabel('avg. Re\{Coherence\}');
xlim([timeVec(1) timeVec(end)]);
ylim ([-0.5 1.5]);
axOVD.YTick = [-0.5 0 0.5 1];
axOVD.YTickLabels = {'-0.5','0', '0.5', '1'};


%% Pxx
axPxx = axes('Position',[GUI_xStart 0.2 GUI_xAxesWidth 0.18]);
timeVec = datenum(TimeVecPSD);

if isFreqLim
    PxxLog = 10*log10(PxxShort)';
else
    PxxLog = 10*log10(Pxx)';
end
imagesc(timeVec,freqVec,PxxLog);
axis xy;
colorbar;
title('');
psdText=text(timeVec(5),freqVec(end-10),'PSD (left)','Color',[1 1 1]);
psdText.FontSize = 12;
if isFreqLim
    set(axPxx,'YTick',1:3:size(PxxShort,2));
    yaxisLables = sprintfc('%d', stBandDef.MidFreq(1:3:end));
    set(axPxx,'YTickLabel',yaxisLables);
end
set(axPxx ,'ylabel', ylabel('frequency in Hz'))
set(axPxx,'CLim',[-110 -55]);


set(axOVD,'XTickLabel','');
set(axAudio,'XTickLabel',[]);
set(axCoher,'XTickLabel',[]);
set(axPxx,'XTickLabel',[]);

%% assign annotations
iStartAnno = 0.95; % define 'left' position/ start for all annotations

annotationOVD =annotation(gcf,'textbox',...
    'String',{'OVS'},...
    'FitBoxToText','off');
annotationOVD.LineStyle = 'none';
annotationOVD.FontSize = 12;
annotationOVD.Color = [1 0 0];
annotationOVD.Position = [iStartAnno 0.85 0.0251 0.0411];

annotationFVD =annotation(gcf,'textbox',...
    'String',{'FVS'},...
    'FitBoxToText','off');
annotationFVD.LineStyle = 'none';
annotationFVD.FontSize = 12;
annotationFVD.Color = [0 0 1];
annotationFVD.Position = [iStartAnno 0.83 0.0251 0.0411];

annotationAudio =annotation(gcf,'textbox',...
    'String',{'Audio'},...
    'FitBoxToText','off');
annotationAudio.LineStyle = 'none';
annotationAudio.FontSize = 12;
annotationAudio.Color = [0 0 0];
annotationAudio.Position = [iStartAnno 0.5 0.0251 0.0411];

annotationOVS =annotation(gcf,'textbox',...
    'String',{'OVD'},...
    'FitBoxToText','off');
annotationOVS.LineStyle = 'none';
annotationOVS.FontSize = 11;
annotationOVS.Color = [1 0 0];
annotationOVS.Position = [iStartAnno 0.48 0.0251 0.0411];

annotationFVS =annotation(gcf,'textbox',...
    'String',{'FVD'},...
    'FitBoxToText','off');
annotationFVS.LineStyle = 'none';
annotationFVS.FontSize = 11;
annotationFVS.Color = [0 0 1];
annotationFVS.Position = [iStartAnno 0.46 0.0251 0.0411];

annotationRMS =annotation(gcf,'textbox',...
    'String',{'RMS'},...
    'FitBoxToText','off');
annotationRMS.LineStyle = 'none';
annotationRMS.FontSize = 12;
annotationRMS.Position = [iStartAnno 0.112 0.0251 0.0411];



set(gcf,'PaperPositionMode', 'auto');


linkaxes([axOVD,axRMS,axAudio,axPxx,axCoher],'x');
% dynamicDateTicks([axOVD,axRMS,axPxx,axCoher,axCoherInvalid,axPxxInvalid],'linked');


if bPrint
    set(0,'DefaultFigureColor','remove')
    exportName = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig ...
        'Fingerprint_VD_' obj.szCurrentFolder '_' obj.szNoiseConfig];
    
    savefig(exportName);
    %     saveas(gcf, exportName,'pdf')
end

% print relative values of voice activity
nFrames = size(stDataOVD.vOVS,1);
OVSrel = sum(stDataOVD.vOVS)/nFrames;
fprintf('***estimated %.2f %% own voice per day\n',100*OVSrel);
FVSrel = sum(stDataFVD.vFVS)/nFrames;
fprintf('***estimated %.2f %% futher voice per day\n',100*FVSrel);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Test Area%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idxTrOVS = ~isnan(groundTrOVS);
idxTrFVS = ~isnan(groundTrFVS);
idxTrNone = ~idxTrOVS & ~idxTrFVS;

% modulation spectrum
EnvelopeFromRMS = sqrt(DataRMS);
nFFT = 16*stParam.nFFT;
ModSpecOVS = fft(EnvelopeFromRMS(idxTrOVS,1), nFFT);
ModSpecOVS = ModSpecOVS(1:nFFT/2+1);
ModSpecFVS = fft(EnvelopeFromRMS(idxTrFVS,1), nFFT);
ModSpecFVS = ModSpecFVS(1:nFFT/2+1);
ModSpecNone = fft(EnvelopeFromRMS(idxTrNone,1), nFFT);
ModSpecNone = ModSpecNone(1:nFFT/2+1);
vFreq = 0 : stParam.fs/nFFT : stParam.fs/2;

figure;
subplot(2,2,1);
plot(vFreq, ModSpecOVS, 'r');
hold on;
plot(vFreq, ModSpecFVS, 'b');
plot(vFreq, ModSpecNone, 'g');
title('envelope modulation spectrum');
xlabel('Frequency in Hz');
ylabel('magnitude');
legend('OVS','FVS','none');
xlim([0 100]);


% magnitude spectrum
% figure;
subplot(2,2,3);
[hLineXX] = PlotMeanStd(Pxx(idxTrOVS,:), freqVec, 'r');
% plot(freqVec, mean(Pxx(idxTrOVS,:)), 'r');
hold on;
[hLineYY] = PlotMeanStd(Pyy(idxTrOVS,:), freqVec, 'm');
% plot(freqVec, mean(Pyy(idxTrOVS,:)), 'm');
xlim([0 2000]);
title('mean magnitude spectrum PSD at OVS');
xlabel('Frequency in Hz');
ylabel('magnitude');
legend([hLineXX, hLineYY], 'Pxx','Pyy');

% figure;
subplot(2,2,4);
[hLineXX] = PlotMeanStd(Pxx(idxTrFVS,:), freqVec, 'b');
% plot(freqVec,mean(Pxx(idxTrFVS,:)), 'b');
hold on;
[hLineYY] = PlotMeanStd(Pyy(idxTrFVS,:), freqVec, 'c');
% plot(freqVec,mean(Pyy(idxTrFVS,:)), 'c');
xlim([0 2000]);
title('mean magnitude spectrum PSD at FVS');
xlabel('Frequency in Hz');
ylabel('magnitude');
legend([hLineXX, hLineYY], 'Pxx','Pyy');

% figure;
subplot(2,2,2);
[hLineXX] = PlotMeanStd(Pxx(idxTrNone,:), freqVec, 'g');
% plot(freqVec,mean(Pxx(idxTrNone,:)), 'k');
hold on;
[hLineYY] = PlotMeanStd(Pyy(idxTrNone,:), freqVec, 'y');
% plot(freqVec,mean(Pyy(idxTrNone,:)), 'Color', [0.8 0.8 0.8]);
xlim([0 2000]);
title('mean magnitude spectrum PSD at no VS');
xlabel('Frequency in Hz');
ylabel('magnitude');
legend([hLineXX, hLineYY], 'Pxx','Pyy');

sgtitle([obj.szCurrentFolder ' ' obj.szNoiseConfig]);

function [hl] = PlotMeanStd(data, freqVec, color)
    lo = mean(data) - std(data);
    hi = mean(data) + std(data);

    hp = patch([freqVec freqVec(end:-1:1) freqVec(1)], [lo hi(end:-1:1) lo(1)], color);
    hold on;
    hl = line(freqVec,mean(data));

    set(hp, 'FaceColor', color, 'edgecolor', 'none', 'FaceAlpha',.2);
    set(hl, 'Color', color, 'marker', 'x');
end

end

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