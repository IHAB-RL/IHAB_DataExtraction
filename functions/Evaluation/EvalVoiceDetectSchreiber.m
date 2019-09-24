function [stResults]=EvalVoiceDetectSchreiber(dataPath, probID, config, gtFlag, FVDFlag, mode)
% function to evaluate the detection performance of (own, futher) voice
% sequences
% Usage [stResults]=EvalVoiceDetectSchreiber(dataPath, probID, config, gtFlag, stDataFVD.FVDFlag, mode)
%
% Parameters
% ----------
% inParam : dataPath, probID, config, gtFlag, stDataFVD.FVDFlag, mode
%
% Returns
% -------
% outParam :  stResults - struct, containing the calculated results
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: If the function is based on a scientific paper or a web site,
%         provide the citation detail here (with equation no. if applicable)
% Version History:
% Ver. 0.01 initial create (empty) 10-Sep-2019  JP

stDataFVD.FVDFlag = FVDFlag;

% preallocation of the foldername
prefix  = 'config';

if contains(lower(probID),'kemar')
    % construct the path where the splitted kemar data are stored
    path = [probID  num2str(config) filesep prefix num2str(config)];
    [stParam.mSignal,fs] = audioread([path filesep probID num2str(config) '_' prefix num2str(config) '.wav']);
else
    % construct the path where the induvidual subject data are
    % stored
    path = [dataPath filesep probID filesep prefix num2str(config)];
    [stParam.mSignal,fs] = audioread([path filesep probID '_' prefix num2str(config) '.wav']);
end

stParam.privacy     = true;
if stParam.privacy
    stParam.fs      = fs/2;
    stParam.mSignal = resample(stParam.mSignal, stParam.fs, fs);
else
    stParam.fs      = fs;
end
sampleLen           = size(stParam.mSignal,1);

% % limit to 60 s chunks
% if strcmp(mode,'features')
%     nMinute         = 60*stParam.fs;
%     sampleLen       = (sampleLen - mod(sampleLen, nMinute));
%     stParam.mSignal = stParam.mSignal(1:sampleLen,:);
% end

timeLen             = sampleLen/stParam.fs;
stParam.vTime        = linspace(0,timeLen,sampleLen);

% set parameters for processing audio data
stParam.tFrame      = 0.025; % block length in sec (Sascha)
stParam.lFrame      = floor(stParam.tFrame*stParam.fs); % block length in samples
stParam.lOverlap    = stParam.lFrame/2; % overlap adjacent blocks
stParam.nFFT        = 1024; % number of fast Fourier transform points
stParam.vFreqRange  = [400 1000]; % frequency range of interest in Hz
stParam.vFreqBins   = round(stParam.vFreqRange./stParam.fs*stParam.nFFT);
stParam.tauCoh      = 1.0; % Sascha
stParam.tFrame      = 0.125; % Nils
stParam.tauCoh      = 0.1; % Nils
stParam.fixThresh   = 0.6; % fixed coherence threshold
stParam.adapThreshWin  = 0.05*stParam.fs; % window length for the adaptive threshold
stParam.winLen      = floor(stParam.nFFT/10); % normalized window length (Nils)


if strcmp(mode,'features')
    % Load feature files for PSD and RMS data
    d = dir([path filesep 'PSD*.feat']);
    d2 = dir([path filesep 'RMS*.feat']);
    stDataReal.Cxy = [];
    stDataReal.Pxx = [];
    stDataReal.Pyy = [];
    nD = numel(d);
    if nD > 1
        for pp = 1:nD
            mPSDData = LoadFeatureFileDroidAlloc([path filesep d(pp).name]);
            [tmpCxy,tmpPxx,tmpPyy] = get_psd(mPSDData);
            stDataReal.Cxy = [stDataReal.Cxy tmpCxy.'];
            stDataReal.Pxx = [stDataReal.Pxx tmpPxx.'];
            stDataReal.Pyy = [stDataReal.Pyy tmpPyy.'];
            stDataReal.mRMS = LoadFeatureFileDroidAlloc([path filesep d2(pp).name]);
        end
    else
        mPSDData = LoadFeatureFileDroidAlloc([path filesep d.name]);
        [stDataReal.Cxy,stDataReal.Pxx,stDataReal.Pyy] = get_psd(mPSDData);
        stDataReal.Cxy = stDataReal.Cxy.';
        stDataReal.Pxx = stDataReal.Pxx.';
        stDataReal.Pyy = stDataReal.Pyy.';
        stDataReal.mRMS = LoadFeatureFileDroidAlloc([path filesep d2.name]);
    end
    
    % calculate complex coherence
    stDataReal.vCoh = stDataReal.Cxy./(sqrt(stDataReal.Pxx.*stDataReal.Pyy) + eps);
    
    % calculate 'mean real coherence' over a number of bins
    % times the factor where cross power density is also high
    stDataReal.vCohMeanReal = mean(real(stDataReal.vCoh(stParam.vFreqBins(1):stParam.vFreqBins(2),:)),1);
    
    % smooth coherence
    alphaCoh = exp(-stParam.tFrame/stParam.tauCoh);
    stDataReal.vCohMeanRealSmooth = filter(1-alphaCoh,[1 -alphaCoh], stDataReal.vCohMeanReal);
    
    
elseif strcmp(mode,'audio')
    [stDataReal] = detectOVSRealCoherence(stParam);
    % [stDataReal] = computeSpectraAndCoherence(stParam);
    
end

% calculate a time vector for the coherence data
stParam.vTimeCoh = linspace(0,timeLen,size(stDataReal.Pxx,2));


%% DETECTION
% Bilert 2018
[stDataBilert] = OVD_Bilert(stParam, stDataReal);


% Schreiber 2019
[stDataOVD] = OVD3(stDataReal.Cxy,stDataReal.Pxx,stDataReal.Pyy,stParam.fs);

if stDataFVD.FVDFlag
    [stDataFVD] = FVD3(stDataOVD.vOVS,stDataOVD.snrPrio,stDataOVD.movAvgSNR);
    stDataFVD.FVDFlag = FVDFlag;
end



%% Ground truths
if stParam.privacy == true
    fsOVD = 8;
else
    fsOVD = 80;
end

gtFile = fullfile(path,[probID '_config' num2str(config) '_Voice.txt']);

if ~exist(gtFile,'file')
    if contains(lower(probID),'kemar')
        try
            gtFile = fullfile(path,[probID num2str(config) '_config' num2str(config) '.txt']);
        catch e
            error(e.message);
        end
    else
        try
            gtFile = fullfile(path,[probID '_config' num2str(config) '.txt']);
        catch e
            error(e.message);
        end
    end
end

vActVoice = importdata(gtFile);


%% OVD
if gtFlag && contains(lower(probID),'kemar')
    ovsIndicator = 0; % Nils labeled KEMAR data
    startTime = vActVoice(vActVoice(:,3)==ovsIndicator, 1);
    endTime = vActVoice(vActVoice(:,3)==ovsIndicator, 2);
else
    ovsIndicator = 0; % Sascha labeled data
    startTime = vActVoice(vActVoice(:,3)>ovsIndicator, 1);
    endTime = vActVoice(vActVoice(:,3)>ovsIndicator, 2);
end
startIdx = round(startTime*fsOVD);
startIdx(startIdx==0) = 1;
endIdx = round(endTime*fsOVD);
outOfBounceStart = find(startIdx>size(stDataOVD.vOVS(:)',2),1);
outOfBounceEnd = find(endIdx>size(stDataOVD.vOVS(:)',2),1);
if ~isempty(outOfBounceEnd) && ~isempty(outOfBounceStart)
    endIdx(outOfBounceEnd:end) = [];
    startIdx(outOfBounceEnd:end) = [];
    
elseif ~isempty(outOfBounceEnd) && startIdx(outOfBounceEnd) <= size(stDataOVD.vOVS(:)',2)
    endIdx(outOfBounceEnd) = size(stDataOVD.vOVS(:)',2);
    if length(endIdx)>outOfBounceEnd
        endIdx(outOfBounceEnd+1:end) = [];
        startIdx(outOfBounceEnd+1:end) = [];
    end
end

stDataReal.vActivOVS = zeros(1,size(stDataOVD.vOVS(:)',2));

for ll = 1:size(startIdx,1)
    stDataReal.vActivOVS(startIdx(ll):endIdx(ll)) = 1;
end

%% evaluate performace OVD
disp(['prob: ' probID ' conf' num2str(config) ':'])
% fix
[F1ScoreOVS_fix,stResults.precOVS_fix,stResults.recOVS_fix] = F1M(stDataBilert.vOVS_fix, stDataReal.vActivOVS);
stResults.mConfusion_fix = getConfusionMatrix(stDataBilert.vOVS_fix, stDataReal.vActivOVS);

% adaptiv Bilert
[F1ScoreOVS_Bilert,stResults.precOVS_Bilert,stResults.recOVS_Bilert] = F1M(stDataBilert.vOVS_adap, stDataReal.vActivOVS);
stResults.mConfusion_Bilert = getConfusionMatrix(stDataBilert.vOVS_adap, stDataReal.vActivOVS);

% adaptiv Nils
[F1ScoreOVS_Schreiber,stResults.precOVS_Schreiber,stResults.recOVS_Schreiber] = F1M(stDataOVD.vOVS, stDataReal.vActivOVS);
stResults.mConfusion_Schreiber = getConfusionMatrix(stDataOVD.vOVS, stDataReal.vActivOVS);


%% FVD
if stDataFVD.FVDFlag
    gtFVDFile = fullfile(path,[probID '_config' num2str(config) '_VoiceOthers.txt']);
    
    if ~exist(gtFVDFile,'file')
        if contains(lower(probID),'kemar')
            try
                gtFVDFile = fullfile(path,[probID num2str(config) '_config' num2str(config) '.txt']);
            catch e
                error(e.message);
            end
        else
            gtFVDFile = gtFile;
            %             try
            %                 gtFVDFile = fullfile(path,[probID '_config' num2str(config) '.txt']);
            %             catch e
            %                 error(e.message);
            %             end
        end
    end
    
    vActVoice = importdata(gtFVDFile);
    
    if gtFlag && contains(lower(probID),'kemar')
        fvsIndicator = [1 2 3]; % Nils labeled KEMAR data
        startTime = vActVoice((vActVoice(:,3)==fvsIndicator(1) | vActVoice(:,3)==fvsIndicator(2) | vActVoice(:,3)==fvsIndicator(3)),1);
        endTime = vActVoice((vActVoice(:,3)==fvsIndicator(1) | vActVoice(:,3)==fvsIndicator(2) | vActVoice(:,3)==fvsIndicator(3)),2);
        
    elseif gtFlag && ~contains(gtFVDFile,'Others')
        fvsIndicator = 0; % Jule labeled PROBAND data
        startTime = vActVoice((vActVoice(:,3)==fvsIndicator),1);
        endTime = vActVoice((vActVoice(:,3)==fvsIndicator),2);
        
    else % Nils labeled PROBAND or subject data
        startTime = vActVoice(:,1);
        endTime = vActVoice(:,2);
    end
    
    startIdx                = round(startTime*fsOVD);
    startIdx(startIdx==0)   = 1;
    endIdx                  = round(endTime*fsOVD);
    outOfBounceStart = find(startIdx>size(stDataFVD.vFVS(:)',2),1);
    outOfBounceEnd = find(endIdx>size(stDataFVD.vFVS(:)',2),1);
    if ~isempty(outOfBounceEnd) && ~isempty(outOfBounceStart)
        endIdx(outOfBounceEnd:end) = [];
        startIdx(outOfBounceEnd:end) = [];
        
    elseif ~isempty(outOfBounceEnd) && startIdx(outOfBounceEnd) <= size(stDataFVD.vFVS(:)',2)
        endIdx(outOfBounceEnd) = size(stDataFVD.vFVS(:)',2);
        if length(endIdx)>outOfBounceEnd
            endIdx(outOfBounceEnd+1:end) = [];
            startIdx(outOfBounceEnd+1:end) = [];
        end
    end
    stDataReal.vActivFVS = zeros(1,size(stDataFVD.vFVS(:)',2));
    
    for ll = 1:size(startIdx,1)
        stDataReal.vActivFVS(startIdx(ll):endIdx(ll)) = 1;
    end
    
    %% evaluate performace FVD
    [F1ScoreFVS,stResults.precFVS,stResults.recFVS] = F1M(stDataFVD.vFVS, stDataReal.vActivFVS);
    
else
    % set unrealistic values
    stResults.precFVS = 100;
    stResults.recFVS = 100;
end

% decide whether to display F2-Score, precision and recall 
printMode = 0;
if printMode
    disp(['FIX: F1ScoreOVS:' num2str(F1ScoreOVS_fix,'%1.4f') ' prec: ' num2str(stResults.precOVS_fix,'%1.4f') ' rec: ' num2str(stResults.recOVS_fix,'%1.4f')])
    disp(['Bilert: F1ScoreOVS:' num2str(F1ScoreOVS_Bilert,'%1.4f') ' prec: ' num2str(stResults.precOVS_Bilert,'%1.4f') ' rec: ' num2str(stResults.recOVS_Bilert,'%1.4f')])
    disp(['Schreiber: F1ScoreOVS:' num2str(F1ScoreOVS_Schreiber,'%1.4f') ' prec: ' num2str(stResults.precOVS_Schreiber,'%1.4f') ' rec: ' num2str(stResults.recOVS_Schreiber,'%1.4f')])
    disp(['F1ScoreFVS:' num2str(F1ScoreFVS,'%1.4f') ' prec: ' num2str(stResults.precFVS,'%1.4f') ' rec: ' num2str(stResults.recFVS,'%1.4f')])
end

% decide whether to plot OVD/FVD performance over time signal
plot_time = 0;
if plot_time
    plotResultsVoiceDetectTime(stDataReal, stDataOVD, stDataBilert, stDataFVD, stParam);
    pause;
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

% eof