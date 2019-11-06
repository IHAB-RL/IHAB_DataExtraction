function [] = CalcCorrelationTest(obj)
% function belonging to CalcCorrelation.m
% uses PSD features
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 23-Oct-2019  JP

if ~exist('obj', 'var')
% logical witch data should be analysed: IHAB (1) or Bilert (0)
isIHAB = 0;
if isIHAB
    % path to data folder (needs to be customized)
    szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';

    % get all subject directories
    subjectDirectories = dir(szBaseDir);

    % sort for correct subjects
    isValidLength = arrayfun(@(x)(length(x.name) == 18), subjectDirectories);
    subjectDirectories = subjectDirectories(isValidLength);

    % choose a subject number (adjust for a specific subject)
    nSubject = 1;

    % get one subject directoy
    szCurrentFolder = subjectDirectories(nSubject).name;

    % get object
    [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

    % call function to check input date format and plausibility
    StartTime = duration(10,50,0);
    EndTime = duration(10,55,0);
    StartDay = 1;
    EndDay = 1;
    stInfo = checkInputFormat(obj, StartTime, EndTime, StartDay, EndDay);
    
else
    % path to main data folder (needs to be customized)
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
%     obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';

    % get all subject directories
    subjectDirectories = dir(obj.szBaseDir);

    % sort for correct subjects
    isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
    subjectDirectories = subjectDirectories(isValidLength);

    % number of subjects
    nSubject = 1;

    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(nSubject).name;
    
    % number of noise configuration
    nConfig = 4;

    % choose noise configurations
    obj.szNoiseConfig = ['config' num2str(nConfig)];
end

else
    isIHAB = 0;
end

% lets start with reading objective data
% desired feature PSD
szFeature = 'PSD';

% get all available feature file data
if isIHAB
    [DataPSD,TimeVecPSD,stInfoFile] = getObjectiveData(obj, szFeature, ...
        'stInfo', stInfo, 'isCompress', false);
else
    [DataPSD,TimeVecPSD,stInfoFile] = getObjectiveDataBilert(obj, szFeature);
end

if isempty(DataPSD)
    return;
end

% extract PSD data
version = 1; % JP modified get_psd
[Cxy, Pxx, Pyy] = get_psd(DataPSD, version);

% calculate coherence
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);

nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);

% load basefrequencies and synthetic spectra
szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch';
% matfile = 'SyntheticMagnitudes_80_450_741.mat';
matfile = 'SyntheticMagnitudes_50_450_200.mat';
load([szDir filesep matfile], 'basefrequencies', 'synthetic_magnitudes');


% % norm spectrum to maximum value
% MaxValuesPxx = max(Pxx'); % block based
% PxxNorm = Pxx./MaxValuesPxx(:);
Pxx = 10^5*Pxx;
Cxy = 10^5*real(Cxy);
Pyy = 10^5*Pyy;

% calculate correlation
[correlation] = CalcCorrelation(Pxx, stInfoFile.fs, specsize);

% calculate time vector
if isIHAB
    nDur = seconds(EndTime-StartTime);
else
    nLenFrame = 60/stInfoFile.nFrames; % duration one frame in sec
    nDur = nBlocks*nLenFrame;
end
timeVec = linspace(0, nDur, nBlocks);

% calculate frequency vector
freqVec = linspace(0, stInfoFile.fs/2, specsize);

% % plot PSD and correlation
% figure;
% subplot(2,1,1);
% imagesc(timeVec, basefrequencies, correlation');
% axis xy;
% c = colorbar;
% title('feat PSD x syn Spec');
% ylabel('Fundamental Frequency in Hz');
% xlabel('Time in sec');
% ylabel(c, 'Magnitude Feature F^M_t(f_0)');
% xlim([timeVec(1) timeVec(end)]);
% 
% subplot(2,1,2);
% imagesc(timeVec, freqVec, 10*log10(Pxx)');
% axis xy;
% c = colorbar;
% title('scaled PSD feature');
% ylabel('Frequency in Hz');
% xlabel('Time in sec');
% ylabel(c, 'PSD Magnitude in dB');
% xlim([timeVec(1) timeVec(end)]);
% ylim([freqVec(1) 6000]);


% % plot template and real spectra
% FundFreq = [130 200];
% idxFundFreq(1) = find(basefrequencies >= FundFreq(1), 1);
% idxFundFreq(2) = find(basefrequencies >= FundFreq(2), 1);

blockidx = find(timeVec >= 15.2, 1);
% figure; 
% plot(freqVec, real(Cohe(blockidx,:)), 'k');
% hold on;
% plot(freqVec, synthetic_magnitudes(idxFundFreq(1),:), 'r');
% plot(freqVec, synthetic_magnitudes(idxFundFreq(2),:), 'g');
% % plot(freqVec, synthetic_PSD(idxFundFreq(1),:), 'b');
% % plot(freqVec, synthetic_PSD(idxFundFreq(2),:), 'c');
% legend('Pxx', 'T^M(f, 130)', 'T^M(f, 200)', 'PSD(T^M(f, 130))', 'PSD(T^M(f, 200))');
% xlim([0 4000]);
% xlabel('Frequency in Hz');
% ylabel('STFT Magnitude');


% get labels for new blocksize
obj.fsVD = nBlocks/nDur;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

idxTrOVS = groundTrOVS == 1;
idxTrFVS = groundTrFVS == 1;
idxTrNone = ~idxTrOVS & ~idxTrFVS;

% % check labels
% figure;
% imagesc(timeVec, basefrequencies, correlation');
% axis xy;
% colorbar;
% hold on;
% plot(200*groundTrOVS, 'r');
% plot(300*groundTrFVS, 'b');
% plot(400*idxTrNone, 'g');



% plot PSD and correlation for one time frame with marked peaks
figure;
subplot(2,1,1);
plot(basefrequencies, correlation(blockidx,:));
title('feat PSD x syn Spec');
xlabel('Fundamental Frequency in Hz');
ylabel('Magnitude Feature F^M_t(f_0)');

subplot(2,1,2);
plot(freqVec, 10*log10(Pxx(blockidx,:))');
title('scaled PSD feature');
xlabel('Frequency in Hz');
ylabel('PSD Magnitude in dB');

if isIHAB
    return;
end

%% calculate and plot distribution of Magnitude Feature

% calculate mean on correlation for OVS | FVS | no VS
MeanCorrOVS = mean(correlation(idxTrOVS,:));
MeanCorrFVS = mean(correlation(idxTrFVS,:));
MeanCorrNone = mean(correlation(idxTrNone,:));

hFig1 = figure;
hFig1.Position =  get(0,'ScreenSize');

subplot(3,1,1);
bar(basefrequencies, MeanCorrOVS, 'FaceColor', 'r');
title('Mean Magnitude Feature F^M_t(f_0) at OVS');
xlabel('Fundamental Frequency in Hz');
ylabel('Mean Magnitude Feature F^M_t(f_0)');

subplot(3,1,2);
bar(basefrequencies, MeanCorrFVS, 'FaceColor', 'b');
title('Mean Magnitude Feature F^M_t(f_0) at FVS');
xlabel('Fundamental Frequency in Hz');
ylabel('Mean Magnitude Feature F^M_t(f_0)');

subplot(3,1,3);
bar(basefrequencies, MeanCorrNone, 'FaceColor', [0 0.6 0.2]);
title('Mean Magnitude Feature F^M_t(f_0) at no VS');
xlabel('Fundamental Frequency in Hz');
ylabel('Mean Magnitude Feature F^M_t(f_0)');


% calculate maximum on correlation for OVS | FVS | no VS
MaxCorrOVS = max(correlation(idxTrOVS,:));
MaxCorrFVS = max(correlation(idxTrFVS,:));
MaxCorrNone = max(correlation(idxTrNone,:));

hFig4 = figure;
hFig4.Position = hFig1.Position;
subplot(3,1,1);
bar(basefrequencies, MaxCorrOVS, 'FaceColor', 'r');
title('Max Magnitude Feature F^M_t(f_0) at OVS');
xlabel('Fundamental Frequency in Hz');
ylabel('max(Magnitude Feature F^M_t(f_0))');

subplot(3,1,2);
bar(basefrequencies, MaxCorrFVS, 'FaceColor', 'b');
title('Max Magnitude Feature F^M_t(f_0) at FVS');
xlabel('Fundamental Frequency in Hz');
ylabel('max(Magnitude Feature F^M_t(f_0))');

subplot(3,1,3);
bar(basefrequencies, MaxCorrNone, 'FaceColor', [0 0.6 0.2]);
title('Max Magnitude Feature F^M_t(f_0) at no VS');
xlabel('Fundamental Frequency in Hz');
ylabel('max(Magnitude Feature F^M_t(f_0))');


% calculate p% percentile on correlation for OVS | FVS | no VS
p = 80;
PrcCorrOVS = prctile(correlation(idxTrOVS,:), p);
PrcCorrFVS = prctile(correlation(idxTrFVS,:), p);
PrcCorrNone = prctile(correlation(idxTrNone,:), p);

hFig3 = figure;
hFig3.Position = hFig1.Position;
subplot(3,1,1);
bar(basefrequencies, PrcCorrOVS, 'FaceColor', 'r');
title([num2str(p) '% percentile Magnitude Feature F^M_t(f_0) at OVS']);
xlabel('Fundamental Frequency in Hz');
ylabel([num2str(p) '% percentile Magnitude Feature F^M_t(f_0)']);

subplot(3,1,2);
bar(basefrequencies, PrcCorrFVS, 'FaceColor', 'b');
title([num2str(p) '% percentile Magnitude Feature F^M_t(f_0) at FVS']);
xlabel('Fundamental Frequency in Hz');
ylabel([num2str(p) '% percentile Magnitude Feature F^M_t(f_0)']);

subplot(3,1,3);
bar(basefrequencies, PrcCorrNone, 'FaceColor', [0 0.6 0.2]);
title([num2str(p) '% percentile Magnitude Feature F^M_t(f_0) at no VS']);
xlabel('Fundamental Frequency in Hz');
ylabel([num2str(p) '% percentile Magnitude Feature F^M_t(f_0)']);



% save figures
isSaveMode = 0;
if ~isSaveMode
    return;
end
% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
szFolder_Output = [szDir filesep 'Pitch' filesep 'Pxx'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

if isIHAB
    hFig1.Name = ['MeanCorr_Pxx_' obj.szCurrentFolder];
    hFig3.Name = ['Prc' num2str(p) '_Pxx_' obj.szCurrentFolder];
    hFig4.Name = ['MaxCorr_Pxx_' obj.szCurrentFolder];
else
    hFig1.Name = ['MeanCorr_Pxx_' obj.szCurrentFolder '_' obj.szNoiseConfig];
    hFig3.Name = ['Prc' num2str(p) '_Pxx_' obj.szCurrentFolder '_' obj.szNoiseConfig];
    hFig4.Name = ['MaxCorr_Pxx_' obj.szCurrentFolder '_' obj.szNoiseConfig];
end
exportName1 = [szFolder_Output filesep hFig1.Name];
savefig(hFig1, exportName1);

exportName3 = [szFolder_Output filesep hFig3.Name];
savefig(hFig3, exportName3);

exportName4 = [szFolder_Output filesep hFig4.Name];
savefig(hFig4, exportName4);

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