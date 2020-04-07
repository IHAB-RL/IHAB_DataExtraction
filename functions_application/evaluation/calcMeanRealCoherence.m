function calcMeanRealCoherence(obj)
% function to calcualte the mean real coherence
% Usage calcMeanRealCoherence(obj)
%
% Parameters
% ----------
%  obj : struct, contains all informations
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 21-Jan-2020  JP

obj = checkNrOfFeatFiles(obj);

% if no or not all feature files are stored, extract data from audio
if obj.UseAudio
    
    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);
    
    % re-assign values
    Pxx = stData.Pxx';
    Pyy = stData.Pyy';
    Cxy = stData.Cxy';
    SampleRate = stData.fs;
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;
    
else
    
    % reading objective data, desired feature PSD
    szFeature = 'PSD';
    
    % get all available feature file data
    [DataPSD, ~, stInfo] = getObjectiveDataBilert(obj, szFeature);
    
    % extract PSD data
    version = 1; % JP modified get_psd
    [Cxy, Pxx, Pyy] = get_psd(DataPSD, version);
    
    % sampling frequency in Hz
    SampleRate = stInfo.fs;
    
    % number of fast Fourier transform points
    nFFT = (stInfo.nDimensions - 2 - 4)/2;
    
    % duration one frame in sec
    nLenFrame = stInfo.HopSizeInSamples/SampleRate;
    
end

% call OVD by Schreiber 2019
stDataOVD = OVD3(Cxy, Pxx, Pyy, SampleRate);

% number of time frames
nBlocks = size(Pxx, 1);

% get ground truth voice labels
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get voice labels
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
groundTrOVS = logical(groundTrOVS);
groundTrFVS = logical(groundTrFVS);

isBoth = groundTrOVS & groundTrFVS;
isNoVS = ~groundTrOVS & ~groundTrFVS;
groundTrOVS(isBoth) = 0;
groundTrFVS(isBoth) = 0;

mCoherenceOVS = stDataOVD.meanCoheTimesCxy(groundTrOVS);
mCoherenceFVS = stDataOVD.meanCoheTimesCxy(groundTrFVS);
mCoherencenoVS = stDataOVD.meanCoheTimesCxy(isNoVS);

% build the full directory
if isfield(obj, 'szCurrentFolder')
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder];

    szFile = ['MeanRealCoherence_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
else
    szDir = obj.szBaseDir;
    
    szFile = ['MeanRealCoherence_'  obj.szNoiseConfig];
end
szFolder_Output = [szDir filesep 'FeatureExtraction'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

% save results as mat file
save([szFolder_Output filesep szFile], 'mCoherenceOVS', 'mCoherenceFVS', 'mCoherencenoVS', 'nBlocks');

%--------------------Licence ---------------------------------------------
% Copyright (c) <2020> J. Pohlhausen
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