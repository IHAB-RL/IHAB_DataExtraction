function AnalysePeaksCorrelation(obj)
% function to analyse the peaks in the correlation (magnitude feature by 
% Basti Bechtold)
% Usage AnalysePeaksCorrelation(obj)
%
% Parameters
% ----------
% inParam :  obj - struct, contains all informations
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 04-Nov-2019  JP
 
% reading objective data, desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,~,stInfoFile] = getObjectiveDataBilert(obj, szFeature);

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


Pxx = 10^5*Pxx;
% Cxy = 10^5*real(Cxy);
% Pyy = 10^5*Pyy;

% calculate correlation
% PSD
[correlation] = CalcCorrelation(Pxx, samplerate, specsize);
% % Cohe
% useFilter = 0; % logical whether to highpass filter the hannwin combs
% [correlation] = CalcCorrelation(real(Cohe), samplerate, specsize, useFilter);


% load basefrequencies 
basefrequencies = logspace(log10(50),log10(450),200);


% get ground truth voice labels
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

idxTrOVS = groundTrOVS == 1;
idxTrFVS = groundTrFVS == 1;
idxTrNone = ~idxTrOVS & ~idxTrFVS;


% calculate the "RMS" of the correlation
CorrRMS = sqrt(sum(correlation.^2, 2));

CorrRMS_OVS = CorrRMS(idxTrOVS, :);
CorrRMS_FVS = CorrRMS(idxTrFVS, :);
CorrRMS_None = CorrRMS(idxTrNone, :);


% determine peaks of correlation
[peaks, locs, hFig, peaksOVS, peaksFVS, peaksNone] = ...
    DeterminePeaksCorrelation(correlation, basefrequencies, nBlocks, idxTrOVS, idxTrFVS, idxTrNone);

                        
% build the full directory
if isfield(obj, 'szCurrentFolder')
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder];

    szFileEnd = [obj.szCurrentFolder '_'  obj.szNoiseConfig];
else
    szDir = obj.szBaseDir;
    
    szFileEnd = obj.szNoiseConfig;
end
szFolder_Output = [szDir filesep 'Pitch' filesep 'PeaksMatFiles'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

% save results as mat file
szFile = ['PeaksLocs_' szFileEnd];
save([szFolder_Output filesep szFile], 'peaks', 'locs', 'peaksOVS', 'peaksFVS', 'peaksNone');
savefig(hFig, [szFolder_Output filesep szFile]);

% save results as mat file
szFile = ['CorrelationRMS_' szFileEnd];
save([szFolder_Output filesep szFile], 'CorrRMS_OVS', 'CorrRMS_FVS', 'CorrRMS_None');


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