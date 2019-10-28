% Script belonging to CalcCorrelation.m
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 23-Oct-2019  JP

clear; 
% close all;

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
    nSubject = 7;

    % get one subject directoy
    szCurrentFolder = subjectDirectories(nSubject).name;

    % get object
    [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

    % call function to check input date format and plausibility
    StartTime = duration(13,30,0);
    EndTime = duration(13,35,0);
    StartDay = 1;
    EndDay = 1;
    stInfo = checkInputFormat(obj, StartTime, EndTime, StartDay, EndDay);
    
else
    % path to main data folder (needs to be customized)
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

    % get all subject directories
    subjectDirectories = dir(obj.szBaseDir);

    % sort for correct subjects
    isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
    subjectDirectories = subjectDirectories(isValidLength);

    % number of subjects
    nSubject = size(subjectDirectories, 1);

    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(nSubject).name;
    
    % number of noise configuration
    nConfig = 1;

    % choose noise configurations
    obj.szNoiseConfig = ['config' num2str(nConfig)];
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

version = 1; % JP modified get_psd
[Cxy, Pxx, Pyy] = get_psd(DataPSD, version);

nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);

matfile = 'SyntheticMagnitudes.mat';
szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch';
load([szDir filesep matfile]);

% % norm spectrum to maximum value
% MaxValuesPxx = max(Pxx'); % block based
% PxxNorm = Pxx./MaxValuesPxx(:);


% calculate correlation
[correlation, correlationPSD, synthetic_PSD] = CalcCorrelation(Pxx, stInfoFile.fs, specsize);

% calculate time vector
if isIHAB
    nDur = seconds(EndTime-StartTime);
else
    nLenFrame = 60/stInfoFile.nFrames; % duration one frame in sec
    nDur = nBlocks*nLenFrame;
end
timeVec = linspace(0, nDur, nBlocks);

% plot results
figure;
subplot(2,1,1);
imagesc(timeVec, basefrequencies, correlation');
axis xy;
c = colorbar;
title('feat PSD x syn Spec');
ylabel('Fundamental Frequency in Hz');
xlabel('Time in sec');
ylabel(c, 'Magnitude Feature F^M_t(f_0)');
xlim([timeVec(1) timeVec(end)]);

subplot(2,1,2);
imagesc(timeVec, basefrequencies, correlationPSD');
axis xy;
c = colorbar;
title('feat PSD x syn PSD');
ylabel('Fundamental Frequency in Hz');
xlabel('Time in sec');
ylabel(c, 'Magnitude Feature F^M_t(f_0)');
xlim([timeVec(1) timeVec(end)]);


freqs = linspace(0, stInfoFile.fs/2, specsize);

FundFreq = [130 200];
idxFundFreq(1) = find(basefrequencies >= FundFreq(1), 1);
idxFundFreq(2) = find(basefrequencies >= FundFreq(2), 1);


blockidx = find(timeVec >= 18.88, 1);
Pxx_abs =  abs(Pxx(blockidx,:)./max(Pxx(blockidx,:)))';
figure; 
plot(freqs, Pxx(blockidx,:), 'k');
hold on;
plot(freqs, synthetic_magnitudes(idxFundFreq(1),:), 'r');
plot(freqs, synthetic_magnitudes(idxFundFreq(2),:), 'g');
plot(freqs, synthetic_PSD(idxFundFreq(1),:), 'b');
plot(freqs, synthetic_PSD(idxFundFreq(2),:), 'c');
legend('Pxx', 'T^M(f, 130)', 'T^M(f, 200)', 'PSD(T^M(f, 130))', 'PSD(T^M(f, 200))');
xlim([0 4000]);
xlabel('Frequency in Hz');
ylabel('STFT Magnitude');

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