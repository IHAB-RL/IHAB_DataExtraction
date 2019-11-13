function [stData] = detectOVSRealCoherence(stParam, obj)
% function to detect the real part of the coherence using the auto- and
% cross spectral power density
% Usage [stData] = detectOVSRealCoherence(stParam)
%
% Parameters
% ----------
% stParam :  type
%	 explanation
%
% Returns
% -------
% stData :  type
%	 explanation
%
% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Source: If the function is based on a scientific paper or a web site,
%         provide the citation detail here (with equation no. if applicable)
% Version History:
% Ver. 0.01 first implementation 01-Dec-2017  SB
% Ver. 1.0 modified by NS 2018/2019
% Ver. 1.1 add setParamsFeatureExtraction 12-Nov-2019  JP

if nargin == 2 && isempty(stParam)
    % call funtion to set parameters for processing audio data
    stParam = setParamsFeatureExtraction(obj);
end

lFeed       = stParam.lFrame - stParam.lOverlap;
nFrames     = floor((size(stParam.mSignal,1)-stParam.lOverlap)/(lFeed));

% preallocation
if stParam.privacy 
    mCoherence  = zeros(stParam.nFFT/2+1,floor(nFrames/10)+1);
    Pxx = zeros(stParam.nFFT/2+1,floor(nFrames/10)+1);
    Pyy = zeros(stParam.nFFT/2+1,floor(nFrames/10)+1);
    Cxy = zeros(stParam.nFFT/2+1,floor(nFrames/10)+1);
    mRMS = zeros(floor(nFrames/10)+1, 2);
else
    mCoherence  = zeros(stParam.nFFT/2+1,nFrames);
    Pxx = zeros(stParam.nFFT/2+1,nFrames);
    Pyy = zeros(stParam.nFFT/2+1,nFrames);
    Cxy = zeros(stParam.nFFT/2+1,nFrames);
    mRMS = zeros(nFrames,2);
end
mRMStemp = zeros(nFrames,2);

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
    
    
    mRMStemp(iFrame,:) = rms(stParam.mSignal(vIDX,:));
        
    if stParam.privacy 
        if mod(iFrame,10) == 0
            mCoherence(:,counter) = tmpXc./(sqrt(tmpX(:,1).*tmpX(:,2))+eps);
            Pxx(:,counter) = tmpX(:,1);
            Pyy(:,counter) = tmpX(:,2);
            Cxy(:,counter) = tmpXc;
            mRMS(counter,:) = mean(mRMStemp(iFrame-9:iFrame));
            counter = counter+1;
        end
    else
        mCoherence(:,iFrame) = tmpXc./(sqrt(tmpX(:,1).*tmpX(:,2))+eps);
        Pxx(:,iFrame) = tmpX(:,1);
        Pyy(:,iFrame) = tmpX(:,2);
        Cxy(:,iFrame) = tmpXc;
        mRMS(iFrame,:) = mRMStemp;
    end
    
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