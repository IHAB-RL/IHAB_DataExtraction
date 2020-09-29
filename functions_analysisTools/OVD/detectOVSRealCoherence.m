function [stData] = detectOVSRealCoherence(stParam, obj)
% function to detect the real part of the coherence using the auto- and
% cross spectral power density
% Usage [stData] = detectOVSRealCoherence(stParam, obj)
%
% Parameters
% ----------
% stParam - struct with constant parameters for feature extraction and the
%           audio signal; if isempty, setParamsFeatureExtraction.m gets
%           called
%
% obj - struct with specific informations about the current subject, data
%        folder etc.
%
% Returns
% -------
% stData - struct that contains stParam and the frame based extracted 
%          features like RMS, PSD etc
%
% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 first implementation 01-Dec-2017  SB
% Ver. 1.0 modified by NS 2018/2019
% Ver. 1.1 add setParamsFeatureExtraction 12-Nov-2019  JP

if nargin == 2 && isempty(stParam)
    % call funtion to set parameters for processing audio data
    stParam = setParamsFeatureExtraction(obj);
    
    if isfield(obj, 'isPrivacy')
        stParam.privacy = obj.isPrivacy;
    end
end

lFeed       = stParam.lFrame - stParam.lOverlap;
nFrames     = floor((size(stParam.mSignal,1)-stParam.lOverlap)/(lFeed));

% preallocation
if stParam.privacy 
    % set number of privacy aware frames
    nPrivateFrames = floor(nFrames/10);
    
    mCoherence  = zeros(stParam.nFFT/2+1, nPrivateFrames);
    Pxx = zeros(stParam.nFFT/2+1, nPrivateFrames);
    Pyy = zeros(stParam.nFFT/2+1, nPrivateFrames);
    Cxy = zeros(stParam.nFFT/2+1, nPrivateFrames);
else
    mCoherence  = zeros(stParam.nFFT/2+1, nFrames);
    Pxx = zeros(stParam.nFFT/2+1, nFrames);
    Pyy = zeros(stParam.nFFT/2+1, nFrames);
    Cxy = zeros(stParam.nFFT/2+1, nFrames);
end
mRMS = zeros(nFrames, 2);

% smoothing factor PSD
alphaPSD    = exp(-lFeed/(0.125*stParam.fs));

win         = repmat((hanning(stParam.lFrame,'periodic')),1,size(stParam.mSignal,2));
%Add by Nils/ Jule
winNorm = 10*stParam.lFrame*sum(win.^2)./stParam.nFFT;

tmpX        = 0;
tmpXc       = 0;
counter     = 1;

for iFrame = 1:nFrames
    
    vIDX    = ((iFrame-1)*lFeed+1):((iFrame-1)*lFeed+stParam.lFrame);
    
    mSpec   = fft(stParam.mSignal(vIDX,:).*win,stParam.nFFT,1);
    mSpec   = mSpec(1:stParam.nFFT/2+1,:)./winNorm;
    
    curX    = mSpec.*conj(mSpec);
    tmpX    = alphaPSD*tmpX+(1-alphaPSD)*(curX);

    curXc   = mSpec(:,1).*conj(mSpec(:,2));
    tmpXc   = alphaPSD*tmpXc+(1-alphaPSD)*(curXc);
    
    if stParam.privacy 
        if mod(iFrame,10) == 0
            mCoherence(:,counter) = tmpXc./(sqrt(tmpX(:,1).*tmpX(:,2))+eps);
            Pxx(:,counter) = tmpX(:,1);
            Pyy(:,counter) = tmpX(:,2);
            Cxy(:,counter) = tmpXc;
            
            counter = counter+1;
        end
    else
        mCoherence(:,iFrame) = tmpXc./(sqrt(tmpX(:,1).*tmpX(:,2))+eps);
        Pxx(:,iFrame) = tmpX(:,1);
        Pyy(:,iFrame) = tmpX(:,2);
        Cxy(:,iFrame) = tmpXc;
    end
    
    mRMS(iFrame,:) = rms(stParam.mSignal(vIDX,:));
    
end % for iFrame

% mean coherence in given frequency range
vFreqIDX        = round(stParam.vFreqRange/stParam.fs*stParam.nFFT);
vCohMeanReal    = mean(real(mCoherence(vFreqIDX(1):vFreqIDX(2),:)),1);

% smoothed coherence
alphaCoh            = exp(-stParam.tFrame./stParam.tauCoh);
vCohMeanRealSmooth  = filter(1-alphaCoh,[1 -alphaCoh],vCohMeanReal);

stData                    = stParam;
stData.mCoherence         = mCoherence;
stData.vCohMeanReal       = vCohMeanReal;
stData.vCohMeanRealSmooth = vCohMeanRealSmooth;
stData.Pxx  = Pxx;
stData.Pyy  = Pyy;
stData.Cxy  = Cxy;
stData.mRMS = mRMS;

end

% eof