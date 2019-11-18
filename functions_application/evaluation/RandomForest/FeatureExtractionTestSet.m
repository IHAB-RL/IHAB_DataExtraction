function FeatureExtractionTestSet(obj)
% function to save extracted features as mat files
%   - mean real coherence
%   - RMS
%   - power spectral densities (auto | cross)
%   - correlation mean real coherence scaled to RMS with hann window combs
%           - peak height maximum
%           - prominence maximum
%           - "RMS" over all basefrequencies
%   - MFCCs
%   - ZCR
%   - Speech presence probability according to Gerkmann 2010
%   -
%   -
% Usage FeatureExtractionTestSet(obj)
%
% Parameters
% ----------
%  obj - struct with specific informations about the current subject, data
%        folder etc.
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 15-Nov-2019  JP
% TO DO: not ready jet
%   - RMS linear or dB SPL
%   - weighted mean of PSD or bandwise analysis
%   - calculation of MFCCs
%   - integration of "Pitch"

% reading objective data, desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,~,stInfo] = getObjectiveDataBilert(obj, szFeature);

% extract PSD data
version = 1; % JP modified get_psd
[Cxy,Pxx,Pyy] = get_psd(DataPSD, version);

% set minimum time length in blocks
nMinLen = 960;

% if no or all feature files are stored, extract PSD from audio signals
if isempty(DataPSD) || size(Cxy, 1) <= nMinLen
    
    obj.isPrivacy = false;
    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);
    
    % re-assign values
    Pxx = stData.Pxx';
    Pyy = stData.Pyy';
    Cxy = stData.Cxy';
    mRMS = stData.mRMS;
    nFFT = stData.nFFT;
    samplerate = stData.fs;
    
    % calculate ZCR
    [mZCR] = calcZCRframebased(stData.mSignal, samplerate, stData.privacy);
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;
    
    clear stData
else
    
    % sampling frequency in Hz
    samplerate = stInfo.fs;
    
    % number of fast Fourier transform points
    nFFT = (stInfo.nDimensions - 2 - 4)/2;
    
    % duration one frame in sec
    nLenFrame = stInfo.HopSizeInSamples/stInfo.fs;
    
    % desired feature RMS
    szFeature = 'RMS';

    % get all available feature file data
    mRMS = getObjectiveDataBilert(obj, szFeature);
end
 
% number of time frames
nBlocks = size(Pxx, 1);

    
% Empirischer Quartilsdispersionskoeffizient calculated on 10 adjacent RMS 
% frames
mEQD = EQD(mRMS, nBlocks);


% subsample RMS by factor 10 (according to privacy option)
nRemain = rem(size(mRMS, 1), 10*nBlocks);
if nRemain ~= 0
    mRMS(end-nRemain+1:end, :) = [];
end
mRMS = mRMS(1:10:end, :);


% call OVD by Schreiber 2019
stDataOVD = OVD3(Cxy, Pxx, Pyy, samplerate, mRMS);

% mean real coherence (400 - 1000 Hz)
mMeanRealCoherence = stDataOVD.meanCoheTimesCxy;

% a posteriori speech presence probability according to Gerkmann 2010
vFreqRange = [400 1000];
vFreqBins = round(vFreqRange./samplerate*nFFT);
mMeanSPP = mean(stDataOVD.PH1(vFreqBins(1):vFreqBins(2),:),1);



% get ground truth labels for voice activity
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
groundTrFVS = 2*groundTrFVS; % set label for fvs to 2
    
% combine OV and FV labels
vGroundTruthVS = groundTrOVS; % first ovs
% at no ovs look for fvs
vGroundTruthVS(vGroundTruthVS == 0) = groundTrFVS(vGroundTruthVS == 0); 
    
    
    

% build the full directory
if isfield(obj, 'szCurrentFolder')
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder];

    szFileEnd = [obj.szCurrentFolder '_'  obj.szNoiseConfig];
else
    szDir = obj.szBaseDir;
    
    szFileEnd = obj.szNoiseConfig;
end
szFolder_Output = [szDir filesep 'FeatureExtraction'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

% save results as mat file
szFile = ['Features_' szFileEnd];
save([szFolder_Output filesep szFile], 'mRMS', 'mZCR', ...
    'mMeanRealCoherence', 'mMeanSPP', 'mEQD', 'vGroundTruthVS');

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