function [stDataReal,stParam,stTime,stDataOVD,stDataFVD] = ovd_main(probID,config,gtFlag)


% preallocation of the foldername
prefix  = 'config';


if contains(lower(probID),'kemar')
    % construct the path where the induvidual subject data are
    % stored
    path    = [probID  num2str(config) filesep prefix num2str(config)];
    [stParam.mSignal,fs] = audioread([path filesep probID num2str(config) '_' prefix num2str(config) '.wav']);
else
    % construct the path where the induvidual subject data are
    % stored
    path    = [probID filesep prefix num2str(config)];
    [stParam.mSignal,fs]    = audioread([path filesep probID '_' prefix num2str(config) '.wav']);
end
stParam.privacy     = true;
if stParam.privacy
    stParam.fs          = fs/2;
else
    stParam.fs          = fs;
end
stParam.mSignal = resample(stParam.mSignal, stParam.fs,fs);
sampleLen               = size(stParam.mSignal,1);
timeLen                 = sampleLen/stParam.fs;
stTime.vTime            = linspace(0,timeLen,sampleLen);

% Load features
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
        stDataReal.mRMS = LoadFeatureFileDroidAlloc([path filesep d2(kk).name]);
    end
else
    
    mPSDData = LoadFeatureFileDroidAlloc([path filesep d.name]);
    [stDataReal.Cxy,stDataReal.Pxx,stDataReal.Pyy] = get_psd(mPSDData);
    stDataReal.Cxy= stDataReal.Cxy.';
    stDataReal.Pxx= stDataReal.Pxx.';
    stDataReal.Pyy= stDataReal.Pyy.';
    d2 = dir([path filesep 'RMS*.feat']);
    stDataReal.mRMS = LoadFeatureFileDroidAlloc([path filesep d2.name]);
end

% calculate a time vector for the coherence data
stTime.vTimeCoh = linspace(0,timeLen,size(stDataReal.Pxx,2));


%% DETECTION
[stDataOVD] = OVD3(stDataReal.Cxy,stDataReal.Pxx,stDataReal.Pyy,stParam.fs);

[stDataFVD] = FVD3(stDataOVD.vOVS,stDataOVD.snrPrio,stDataOVD.movAvgSNR);


% Ground truths
fsOVD = 8;
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
if gtFlag
    ovsIndicator = 0;
    startTime = vActVoice(vActVoice(:,3)==ovsIndicator, 1);
    endTime = vActVoice(vActVoice(:,3)==ovsIndicator, 2);
else
    ovsIndicator = 0;
    startTime = vActVoice(vActVoice(:,3)>ovsIndicator, 1);
    endTime = vActVoice(vActVoice(:,3)>ovsIndicator, 2);
end
startIdx                = round(startTime*fsOVD);
startIdx(startIdx==0)   = 1;
endIdx                  = round(endTime*fsOVD);
if endIdx(end)>size(stDataOVD.vOVS(:)',2)
    endIdx(end) = size(stDataOVD.vOVS(:)',2);
end
stDataReal.vActivOVS       = zeros(1,size(stDataOVD.vOVS(:)',2));

for ll = 1:size(startIdx,1)
    stDataReal.vActivOVS(startIdx(ll):endIdx(ll)) = 1;
end

%% FVD
gtFile = fullfile(path,[probID '_config' num2str(config) '_VoiceOthers.txt']);

if ~exist(gtFile,'file')
    if contains(lower(probID),'kemar')
        try
            gtFile = fullfile(path,[probID num2str(config) '_config' num2str(config) '.txt']);
        catch e
            error(e.message);
        end
%     else
%         try
%             gtFile = fullfile(path,[probID '_config' num2str(config) '.txt']);
%         catch e
%             error(e.message);
%         end
    end
end

vActVoice = importdata(gtFile);

if gtFlag
    fsvIndicator = [1 2 3]; % Nils labeled KEMAR data
    startTime = vActVoice((vActVoice(:,3)==fsvIndicator(1) | vActVoice(:,3)==fsvIndicator(2) | vActVoice(:,3)==fsvIndicator(3)),1);
    endTime = vActVoice((vActVoice(:,3)==fsvIndicator(1) | vActVoice(:,3)==fsvIndicator(2) | vActVoice(:,3)==fsvIndicator(3)),2);
    
else % Nils subjective data
    startTime = vActVoice(:,1);
    endTime = vActVoice(:,2);
end
startIdx                = round(startTime*fsOVD);
startIdx(startIdx==0)   = 1;
endIdx                  = round(endTime*fsOVD);
if endIdx(end)>size(stDataFVD.vFVS(:)',2)
    endIdx(end) = size(stDataFVD.vFVS(:)',2);
end
stDataReal.vActivFVS       = zeros(1,size(stDataFVD.vFVS(:)',2));

for ll = 1:size(startIdx,1)
    stDataReal.vActivFVS(startIdx(ll):endIdx(ll)) = 1;
end

[F1ScoreOVS,precOVS,recOVS] = F1M(stDataOVD.vOVS, stDataReal.vActivOVS);
disp(['prob: ' probID ' conf' num2str(config) ': F1ScoreOVS:' num2str(F1ScoreOVS,'%1.4f') ' prec: ' num2str(precOVS,'%1.4f') ' rec: ' num2str(recOVS,'%1.4f')])

groundTrOVS = stDataReal.vActivOVS;
groundTrOVS(groundTrOVS == 0) = NaN;
groundTrFVS = stDataReal.vActivFVS;
groundTrFVS(groundTrFVS == 0) = NaN;

vOVS = double(stDataOVD.vOVS);
vOVS(vOVS == 0) = NaN;

figure; plot(stDataOVD.meanCoheTimesCxy), hold on
plot(stDataOVD.adapThreshCohe)
plot(vOVS.*0.3,'rx')
plot(groundTrOVS.*0.5,'rx');
title('cohe adap thresh(blue), vOVS.*0.3, groundTrOVS.*0.5')

figure; plot(stDataOVD.curRMSfromPxx), hold on
plot(stDataOVD.adapThreshRMS)
plot(vOVS.*0.3,'rx')
plot(groundTrOVS.*0.5,'rx');
title('rms adap thresh(blue), vOVS.*0.3, groundTrOVS.*0.5')

fSNR = compute_snr(stDataFVD.vFVS,stDataOVD.snrPrio);

figure;
plot(fSNR);
title('fSNR in dB at FVS');

end


% eof