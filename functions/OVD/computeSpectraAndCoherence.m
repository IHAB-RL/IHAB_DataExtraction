function [stData] = computeSpectraAndCoherence(stParam)
% function to detect the real part of the coherence using the auto- and
% cross spectral power density
% Usage [stData] = computeSpectraAndCoherence(stParam)
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
%------------------------------------------------------------------------

% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Source: If the function is based on a scientific paper or a web site,
%         provide the citation detail here (with equation no. if applicable)
% Version History:
% Ver. 0.01 first implementation 01-Dec-2017  SB

% based on : detectOVSRealCoherence.m
% Unterschiede: 
%   winNorm Verwendung
%   Zeile 58


lFeed       = stParam.lFrame - stParam.lOverlap;

nFrames     = floor((size(stParam.mSignal,1)-stParam.lOverlap)/(lFeed));

% preallocation
mCoherence  = zeros(stParam.nFFT/2+1,nFrames);
Pxx = zeros(stParam.nFFT/2+1,nFrames);
Pyy = zeros(stParam.nFFT/2+1,nFrames);
Cxy = zeros(stParam.nFFT/2+1,nFrames);
mRMS = zeros(stParam.nFFT/2+1,2);

% smoothing factor PSD
alphaPSD    = exp(-lFeed/(0.125*stParam.fs));

win         = repmat((hanning(stParam.lFrame,'periodic')),1,size(stParam.mSignal,2));
%Add by Nils
winNorm = sum(win.^2);
winNorm = (winNorm.* stParam.lFrame)/stParam.nFFT;
winNorm = winNorm(1);

tmpX        = 0;
tmpXc       = 0;

for iFrame = 1:nFrames
    
    vIDX    = ((iFrame-1)*lFeed+1):((iFrame-1)*lFeed+stParam.lFrame);
    
    mSpec   = fft(stParam.mSignal(vIDX,:).*win,stParam.nFFT,1);
%     mSpec   = 2.*mSpec(1:stParam.nFFT/2+1,:); % Nils
    mSpec   = mSpec(1:stParam.nFFT/2+1,:);
    
    curX    = (mSpec.*conj(mSpec))./winNorm;
    tmpX    = alphaPSD*tmpX+(1-alphaPSD)*(curX);
    
    curXc   = mSpec(:,1).*conj(mSpec(:,2));
    tmpXc   = alphaPSD*tmpXc+(1-alphaPSD)*(curXc);
    
    mCoherence(:,iFrame) = tmpXc./(sqrt(tmpX(:,1).*tmpX(:,2))+eps);
    Pxx(:,iFrame) = tmpX(:,1)/stParam.fs;
    Pyy(:,iFrame) = tmpX(:,2)/stParam.fs;
    Cxy(:,iFrame) = tmpXc;
    mRMS(iFrame,:) = rms(stParam.mSignal(vIDX,:));
    
    mRMS(iFrame,:) = rms(stParam.mSignal(vIDX,:));
end % for iFrame

% mean coherence in given frequency range
vFreqIDX        = round(stParam.vFreqRange/stParam.fs*stParam.nFFT);
vCohMeanReal    = mean(real(mCoherence(vFreqIDX(1):vFreqIDX(2),:)),1);

% smoothed coherence
alphaCoh            = exp(-(stParam.lFrame/stParam.fs))./(stParam.tauCoh);
vCohMeanRealSmooth  = filter(1-alphaCoh,[1 -alphaCoh],vCohMeanReal);



if stParam.privacy
    stData.Pxx = Pxx(:,1:10:end);
    stData.Pyy = Pyy(:,1:10:end);
    stData.Cxy = Cxy(:,1:10:end);
    stData.mCoherence           = mCoherence(:,1:10:end);
    stData.vCohMeanReal         = vCohMeanReal(1:10:end);
    stData.vCohMeanRealSmooth   = vCohMeanRealSmooth(1:10:end);
else
    stData.Pxx = Pxx;
    stData.Pyy = Pyy;
    stData.Cxy = Cxy;
    stData.mCoherence           = mCoherence;
    stData.vCohMeanReal         = vCohMeanReal;
    stData.vCohMeanRealSmooth   = vCohMeanRealSmooth;
    
end
stData.mRMS = mRMS;


% eof