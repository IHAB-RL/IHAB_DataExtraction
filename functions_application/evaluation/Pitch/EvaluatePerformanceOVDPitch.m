function EvaluatePerformanceOVDPitch(obj)
% function to evaluate the performance of OVD with pitch
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History: (based on AnalysePeaksCorrelation.m)
% Ver. 0.01 initial create 05-Nov-2019 	JP


% reading objective data, desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD, ~, stInfoFile] = getObjectiveDataBilert(obj, szFeature);

if isempty(DataPSD)
    return;
end

% extract PSD data
version = 1; % JP modified get_psd
[Cxy, Pxx, Pyy] = get_psd(DataPSD, version);

% call OVD by Schreiber 2019
stDataOVD = OVD3(Cxy, Pxx, Pyy, stInfoFile.fs);


nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);

% load basefrequencies 
basefrequencies = logspace(log10(50),log10(450),200);

% scale for nicer values in correlation matrix
Pxx = 10^5*Pxx; 


% calculate correlation
correlation = CalcCorrelation(Pxx, stInfoFile.fs, specsize);


% % find peaks in the correlation matrix
% [peaks,locs] = DeterminePeaksCorrelation(correlation,basefrequencies,nBlocks);


% estimate own voice sequences based on pitch
[stDataPitch] = OVD_Pitch(correlation, nFFT, stDataOVD.movAvgSNR);

% combine coherence, rms, pitch
% estimatedOVS = stDataOVD.vOVS | stDataPitch.vEstOVS;
estimatedOVS = stDataOVD.meanCoheTimesCxy >= stDataOVD.adapThreshCohe & stDataPitch.vEstOVS;

% duration one frame in sec
nLenFrame = 60/stInfoFile.nFrames; 
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get voice labels
[groundTrOVS, ~] = getVoiceLabels(obj);


% calculate F2-Score, precision and recall
[stResults.F2ScoreOVS_Pitch,stResults.precOVS_Pitch,stResults.recOVS_Pitch] = F1M(estimatedOVS', groundTrOVS);

% calculate and plot confusion matrix for OVD
stResults.mConfusion_Pitch = getConfusionMatrix(estimatedOVS', groundTrOVS);
vLabels = {'OVS', 'no OVS'};
plotConfusionMatrix(stResults.mConfusion_Pitch, vLabels);


% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
szFolder_Output = [szDir filesep 'Pitch' filesep 'OVDPitchMatFiles'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

% save results as mat file
szFile = ['OVD_Cohe_rmsCorr_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
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