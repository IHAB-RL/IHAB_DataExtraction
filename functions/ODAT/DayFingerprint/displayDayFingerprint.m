clear
close all
addpath('../Tools');
addpath('../OVD');
addpath('../DroidFeatureTools');

isDebugMode = 1;
% script to display a fingerprint of one day of one test subject



%Define your parameters and adjust your function call
szBaseDir = '/Users/nilsschreiber/Documents/master/masterthesis/ObjectiveDataAnalysisToolbox/HALLO_EMA2016_all';
%szTestSubject =  'AS05EB18';%AS05EB18_161130_mh
%desiredDay = datetime(2016,10,27);

% szTestSubject =  'CH04ER05';
% desiredDay = datetime(2016,4,16);
% desiredPart = 5;
%szTestSubject =  'MA27MA11';
%desiredDay = datetime(2016,11,7);
%desiredPart = 1;
%szTestSubject =  'IG04UT29';
%desiredDay = datetime(2014,11,22);
%desiredPart = 1;

%szTestSubject =  'JE04HE16';
%desiredDay = datetime(2016,2,21);
%desiredPart = 1;

szTestSubject =  'ST09AX31';
desiredDay = datetime(2016,2,7);
desiredPart = 2; 

% lets start with reading objective data

if isDebugMode
    load DataMat
else
    szFeature = 'RMS';
    [DataRMS,timeVecRMS,~]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,desiredPart);
    szFeature = 'PSD';
    [DataPSD,timeVecPSD,NrOfParts]=getObjectiveDataOneDay(szBaseDir,szTestSubject,desiredDay, szFeature,desiredPart);
   save DataMat DataRMS timeVecRMS DataPSD timeVecPSD NrOfParts
end

% Data conversion
[Cxy,Pxx,Pyy] = get_psd(DataPSD);
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);

% OVD 
stInfoOVDAlgo.fs = 16000;
[OVD_result,MeanCohere,~] = computeOVD_Coh(Cohe,timeVecPSD,stInfoOVDAlgo); 

% prepare display by getting the right datetime vector for the data

% StartTime = TimeVec(1);
% EndTime = TimeVec(end)+minutes(1);
% 
% timeVecRMS = linspace(StartTime,EndTime,size(DataRMS,1))';
% timeVecPSD = linspace(StartTime,EndTime,size(DataPSD,1))';


% Fuer Zeit
stControl.DataPointRepresentation_s = 5;
stControl.DataPointOverlap_percent = 0;
stControl.szTimeCompressionMode = 'mean';

[FinalDataRMS,FinaltimeVecRMS]=DataCompactor(DataRMS,timeVecRMS,stControl);
[FinalDataPxx,FinaltimeVecPSD]=DataCompactor(Pxx,timeVecPSD,stControl);
[FinalDataPyy,FinaltimeVecPSD]=DataCompactor(Pyy,timeVecPSD,stControl);
[FinalDataCohe,FinaltimeVecPSD]=DataCompactor(real(Cohe),timeVecPSD,stControl);
[FinalDataCxy,FinaltimeVecPSD]=DataCompactor(abs(Cxy),timeVecPSD,stControl);

stControlOVD.DataPointRepresentation_s = stControl.DataPointRepresentation_s;
stControlOVD.DataPointOverlap_percent = 0;
stControlOVD.szTimeCompressionMode = 'max';
[FinalDataOVD,~]=DataCompactor(OVD_result,timeVecPSD,stControlOVD);
[FinalDataMeanCohe,FinaltimeVecPSD]=DataCompactor(MeanCohere,timeVecPSD,stControlOVD);

save ([ szTestSubject '_FinalDat'],'FinalDataRMS','FinaltimeVecRMS',...
    'FinalDataPxx','FinalDataPyy', 'FinalDataCohe','FinalDataCxy', ...
    'FinalDataOVD', 'FinalDataMeanCohe')

% Data reduction and condensing
% FFTSize x Band Matrix aufbauen
% fuer bark, mel, one-third. octave filterbank
% am BEsten als Funktion die die Multiplikations-Matrix zuruek gibt
FftSize = size(Pxx,2);
stBandDef.StartFreq = 125;
stBandDef.EndFreq = 8000;
stBandDef.Mode = 'onethird';
stBandDef.fs = 16000;
[stBandDef]=fftbin2freqband(FftSize,stBandDef);
stBandDef.skipFrequencyNormalization = 1;
[stBandDefCohe]=fftbin2freqband(FftSize,stBandDef);

FinalDataCxy2 = FinalDataCxy*stBandDef.ReGroupMatrix;
FinalDataPxx2 = FinalDataPxx*stBandDef.ReGroupMatrix;
FinalDataPyy2 = FinalDataPyy*stBandDef.ReGroupMatrix;
FinalDataCohe2 = FinalDataCohe*stBandDefCohe.ReGroupMatrix;
save ([ szTestSubject '_FinalDat'],'FinalDataRMS','FinaltimeVecRMS',...
    'FinalDataPxx','FinalDataPyy', 'FinalDataCohe','FinalDataCxy', ...
    'FinalDataPxx2','FinalDataPyy2', 'FinalDataCohe2','FinalDataCxy2', ...
    'FinalDataOVD', 'FinalDataMeanCohe','FinaltimeVecPSD','stBandDef');


% mean
% median
% max
% allgemein percentile
% implmentieren


% data display


figure;
plot(FinaltimeVecRMS,20*log10(FinalDataRMS));

figure;
 plot(FinaltimeVecPSD,FinalDataOVD);
figure;
plot(FinaltimeVecPSD,FinalDataMeanCohe);



fs = 16000;
PlotMaxFreq = 8000;
freq_vek = linspace(0,fs/2,size(FinalDataPxx,2));
MaxFreqIndex = round(PlotMaxFreq/(fs/2)*size(FinalDataPxx,2));
figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = freq_vek(1:MaxFreqIndex);
DataMatrixShort = real(FinalDataCohe(:,1:MaxFreqIndex))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('Coherence');
TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';

figure;
%set(gcf,'Units','normalized','Position',[0.02 0.3 0.96 0.58]);
%subplot(1,2,1)
%imagesc((1:size(Pxx,1))/DataInfo.nFrames,freq_vek(1:MaxFreqIndex),10*log10((Pxx(:,1:MaxFreqIndex)')));
%imagesc(timeVecPSD(1:SubSample:end),freq_vek(1:MaxFreqIndex),10*log10((Pxx((1:SubSample:end),1:MaxFreqIndex)))');
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = freq_vek(1:MaxFreqIndex);
DataMatrixShort = 10*log10((FinalDataPxx(:,1:MaxFreqIndex)))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);

axis xy;
colorbar;
set(gca,'CLim',[-110 -15]);
title('PSD Left')
TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));

%subplot(1,2,2)

%imagesc((1:size(Pxx,1))/DataInfo.nFrames,freq_vek(1:MaxFreqIndex),10*log10((Pyy(:,1:MaxFreqIndex)')));
figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = freq_vek(1:MaxFreqIndex);
DataMatrixShort = 10*log10((FinalDataPyy(:,1:MaxFreqIndex)))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
set(gca,'CLim',[-110 -15]);
title('PSD right')

TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';
%
%
figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = freq_vek(1:MaxFreqIndex);
DataMatrixShort = 10*log10((FinalDataCxy(:,1:MaxFreqIndex)))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
set(gca,'CLim',[-110 -15]);
title('|C_{xy}|')

TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';


figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = 10*log10(FinalDataPxx2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('Pxx in subbands');
TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set (gca,'YTick',1:1:size(FinalDataPxx2,2));
set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';
set(gca,'CLim',[-110 -15]);

figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPyy2,2);
DataMatrixShort = 10*log10(FinalDataPxx2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('Pyy in subbands');%AS05EB18
TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set (gca,'YTick',1:1:size(FinalDataPxx2,2));
set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';
set(gca,'CLim',[-110 -15]);

figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = (FinalDataCohe2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('Coherence in subbands');
TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set (gca,'YTick',1:1:size(FinalDataPxx2,2));
set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';

figure;
timeVecShort = 1:length(FinaltimeVecPSD);
freqVecShort = 1:size(FinalDataPxx2,2);
DataMatrixShort = 10*log10(FinalDataCxy2(:,:))';
imagesc(timeVecShort,freqVecShort,DataMatrixShort);
axis xy;
colorbar;
title('Cxy in subbands');
TickIndex = 1:round(length(timeVecShort)/5):length(timeVecShort);
set (gca,'XTick',TickIndex);
TickIndexName = timeofday(FinaltimeVecPSD);
set (gca,'XTickLabel',datestr(TickIndexName(TickIndex),'HH:MM'));
set (gca,'YTick',1:1:size(FinalDataPxx2,2));
set (gca,'YTickLabel',stBandDef.MidFreq(1:1:end));
set(gcf,'UserData',TickIndexName);
h = zoom;
h.ActionPostCallback = @drawYTick_cb;
h.Enable = 'on';
set(gca,'CLim',[-110 -15]);



