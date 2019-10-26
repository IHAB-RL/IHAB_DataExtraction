% Script to test PEFAC
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 25-Oct-2019  JP

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

    % number of specific subject
    nSubject = 2;

    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(nSubject).name;
    
    % number of noise configuration
    nConfig = 1;

    % choose noise configurations
    obj.szNoiseConfig = ['config' num2str(nConfig)];
    
    % build the full directory
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
    
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
    
    % read in audio signal for plotting
    audiofile = fullfile(szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
    [mSignal, fs] = audioread(audiofile);
    mSignal = resample(mSignal, stInfoFile.fs, fs);
    tStart = 15.5*stInfoFile.fs;
    tEnd = 18.375*stInfoFile.fs;
    mSignal = mSignal(tStart:tEnd)';
end

version = 1; % JP modified get_psd
[Cxy, Pxx, Pyy] = get_psd(DataPSD, version);

nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);


% set parameters
params.SampleRate = stInfoFile.fs;
params.Range      = [50 800]; % frequency range

% estimate pitch via PEF Matlab
vEstPitch_PEF = PEF_Matlab(real(Pxx)', nFFT, params);
[f0, idx] = pitch(mSignal, params.SampleRate, ...
    'Method', 'PEF', ...
    'Range', params.Range, ...
    'WindowLength', round(params.SampleRate*0.08), ...
    'OverlapLength', round(params.SampleRate*0.05));


% estimate pitch via S.Gonzalez and M. Brookes
[fx,tx,pv,fv] = v_fxpefac(mSignal, params.SampleRate, 0.01,'g');

% estimate pitch via S.Gonzalez and M. Brookes
[vEstPitch_PEFAC, vTime_PEFAC, vProbVoiced, stFeatures] = PEFAC_GB(Pxx, nFFT, stInfoFile.fs);

% find voiced frames as a mask
idxVoiced = vProbVoiced>0.5; 
vPitchVoiced = vEstPitch_PEFAC;
vPitchVoiced(~idxVoiced) = NaN; % allow only good frames
vPitchUnvoiced = vEstPitch_PEFAC;
vPitchUnvoiced(idxVoiced) = NaN; % allow only bad frames


% calculate time vector
nSamples = size(mSignal, 1);
nLen = nSamples/params.SampleRate;
timeVec = linspace(0, nLen, nSamples);

% find block indices
idxBlockStart = tStart/stInfoFile.FrameSizeInSamples;
idxBlockEnd = tEnd/stInfoFile.FrameSizeInSamples;
nBlocks = idxBlockEnd - idxBlockStart + 1;
timeVecBlock = linspace(timeVec(1), timeVec(end), nBlocks); 


% plot results
figure('Position', [680,196,1118,902]);
subplot(3,1,1);
plot(timeVec, mSignal);
hold on;
plot(timeVecBlock, vProbVoiced(idxBlockStart:idxBlockEnd), '-ks');
ylabel('Amplitude / P(Voice)');
xlabel('Time in sec');
xlim([timeVec(1) timeVec(end)]);

% PEF Matlab
subplot(3,1,2);
plot(idx/params.SampleRate, f0);
hold on;
plot(timeVecBlock, vEstPitch_PEF(idxBlockStart:idxBlockEnd), '-s');
title('Pitch Estimation PEF');
ylabel('Pitch in Hz');
xlabel('Time in sec');

% PEFAC Gonzalez and Brookes
subplot(3,1,3);
% plot(vTime_PEFAC, vPitchVoiced, '-b', vTime_PEFAC, vPitchUnvoiced, '-r');
plot(timeVecBlock, vEstPitch_PEFAC(idxBlockStart:idxBlockEnd), '-k');
hold on;
h1 = plot(timeVecBlock, vPitchVoiced(idxBlockStart:idxBlockEnd), '-b*', 'MarkerSize', 5);
h2 = plot(timeVecBlock, vPitchUnvoiced(idxBlockStart:idxBlockEnd), '-ro', 'MarkerSize', 5);
plot(tx, fx);
title('Pitch Estimation PEFAC');
xlabel('Time in sec');
ylabel('Pitch in Hz');
legend([h1 h2], 'voiced', 'unvoiced');




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