function EvaluatePerformanceOVDPitch(obj)
% function to evaluate the performance of OVD (with pitch)
% Usage: EvaluatePerformanceOVDPitch(obj)
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History: (based on AnalysePeaksCorrelation.m)
% Ver. 0.01 initial create 05-Nov-2019 	JP

% reading objective data, desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD, ~, stInfoFile] = getObjectiveDataBilert(obj, szFeature);

% if no feature files are stored, extracted PSD from audio signals
if isempty(DataPSD) 
    
    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);
    
    % re-assign values
    Pxx = stData.Pxx';
    Pyy = stData.Pyy';
    Cxy = stData.Cxy';
    nFFT = stData.nFFT;
    samplerate = stData.fs;
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;
    
    clear stData
else
    
    % extract PSD data
    version = 1; % JP modified get_psd
    [Cxy, Pxx, Pyy] = get_psd(DataPSD, version);
    
    clear DataPSD
    
    % sampling frequency in Hz
    samplerate = stInfoFile.fs;
    
    % number of fast Fourier transform points
    nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
    
    % duration one frame in sec
    nLenFrame = 60/stInfoFile.nFrames;
end

% size of frequency bins
specsize = nFFT/2 + 1;

% number of time frames
nBlocks = size(Pxx, 1);


% % call OVD by Schreiber 2019
% stDataOVD = OVD3(Cxy, Pxx, Pyy, samplerate);
% 
% % % % call OVD by Bilert 2018
% % % stParam = setParamsFeatureExtraction(obj);
% % % stDataOVD = OVD_Bilert(stParam, stData);
% 
% % scale for nicer values in correlation matrix
% Pxx = 10^5*Pxx;
% 
% % calculate correlation of PSD with hannwin combs
% correlation = CalcCorrelation(Pxx, samplerate, specsize);
% 
% 
% % estimate own voice sequences based on correlation
% [stDataPitch] = OVD_Pitch(correlation, nFFT, stDataOVD.movAvgSNR);


% combine coherence, rms, pitch
% estimatedOVS = stDataPitch.vEstOVS;
% estimatedOVS = stDataOVD.vOVS;
% estimatedOVS = stDataOVD.vOVS_adap';
% estimatedOVS = stDataOVD.vOVS | stDataPitch.vEstOVS;
% estimatedOVS = stDataOVD.meanCoheTimesCxy >= stDataOVD.adapThreshCohe & stDataPitch.vEstOVS;
estimatedOVS = ones(nBlocks,1);


% get ground truth voice labels
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get voice labels
[groundTrOVS, ~] = getVoiceLabels(obj);


% calculate F2-Score, precision and recall
[stResults.F2ScoreOVS_Pitch,stResults.precOVS_Pitch,...
    stResults.recOVS_Pitch,stResults.accOVS_Pitch] = F1M(estimatedOVS', groundTrOVS);

% calculate and plot confusion matrix for OVD
stResults.mConfusion_Pitch = getConfusionMatrix(estimatedOVS', groundTrOVS);
vLabels = {'OVS', 'no OVS'};
plotConfusionMatrix(stResults.mConfusion_Pitch, vLabels);

szCondition = 'OVD_AllwaysTrue_';
% build the full directory
if isfield(obj, 'szCurrentFolder')
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder];

    szFile = [szCondition obj.szCurrentFolder '_'  obj.szNoiseConfig];
else
    szDir = obj.szBaseDir;
    
    szFile = [szCondition obj.szNoiseConfig];
end
szFolder_Output = [szDir filesep 'Pitch' filesep 'OVDPitchMatFiles'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

% save results as mat file
save([szFolder_Output filesep szFile], 'stResults');

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
% Institute for Hearing Technology and Audiology
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