function EvaluatePerformanceFVD(obj)
% function to evaluate the performance of FVD 
% Usage: EvaluatePerformanceFVD(obj)
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Ver. 0.01 initial create 27-Nov-2019 	JP


% check whether the number of feature files is valid or not
obj = checkNrOfFeatFiles(obj);

% if no or not all feature files are stored, extract data from audio 
if obj.UseAudio
    
    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);
    
    % re-assign values
    Pxx = stData.Pxx';
    Pyy = stData.Pyy';
    Cxy = stData.Cxy';
    nFFT = stData.nFFT;
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

% number of time frames
nBlocks = size(Pxx, 1);


% call OVD by Schreiber 2019
stDataOVD = OVD3(Cxy, Pxx, Pyy, SampleRate);

% call FVD by Schreiber 2019
[stDataFVD] = FVD3(stDataOVD.vOVS, stDataOVD.snrPrio, stDataOVD.movAvgSNR);

% save estimated FVS
estimatedFVS = stDataFVD.vFVS;


% get ground truth voice labels
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get voice labels
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

% select only 'pure' FVS (i.e. OV+FV=>OV)
isPureFVS = true;
if isPureFVS
    idxBoth = groundTrOVS & groundTrFVS;
    groundTrFVS(idxBoth) = 0;
end

% calculate F2-Score, precision and recall
[stResults.F2ScoreFVS,stResults.precFVS, stResults.recFVS,stResults.accFVS] = F1M(estimatedFVS, groundTrFVS);

% calculate and plot confusion matrix for OVD
vUniqueNums = [0 1];
stResults.mConfusion = getConfusionMatrix(estimatedFVS, groundTrFVS, vUniqueNums);
vLabels = {'no FVS', 'FVS'};
plotConfusionMatrix(stResults.mConfusion, vLabels);

szCondition = 'FVD_Schreiber2019_';
if isPureFVS
    szCondition = [szCondition 'pureFVS_'];
end

% build the full directory
if isfield(obj, 'szCurrentFolder')
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder];

    szFile = [szCondition obj.szCurrentFolder '_'  obj.szNoiseConfig];
else
    szDir = obj.szBaseDir;
    
    szFile = [szCondition obj.szNoiseConfig];
end
szFolder_Output = [szDir filesep 'Pitch' filesep 'FVDMatFiles'];
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