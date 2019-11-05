function [] = AnalysePeaksCorrelation(obj)
% function to
% Usage AnalysePeaksCorrelation(obj)
%
% Parameters
% ----------
% inParam :  type
%	 explanation
%
% Returns
% -------
% outParam :  type
%	 explanation
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 04-Nov-2019  Initials JP
 
% reading objective data, desired feature PSD
szFeature = 'PSD';

% get all available feature file data
[DataPSD,TimeVecPSD,stInfoFile] = getObjectiveDataBilert(obj, szFeature);

if isempty(DataPSD)
    return;
end

% extract PSD data
version = 1; % JP modified get_psd
[Cxy, Pxx, Pyy] = get_psd(DataPSD, version);

% % calculate coherence
% Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);

nFFT = (stInfoFile.nDimensions - 2 - 4)/2;
specsize = nFFT/2 + 1;  
nBlocks = size(Pxx, 1);

% load basefrequencies 
if stInfoFile.fs == 24000
    szDir = 'I:\IHAB_DataExtraction\functions_application\evaluation\Pitch';
    % matfile = 'SyntheticMagnitudes_80_450_741.mat';
    szFile = 'SyntheticMagnitudes_50_450_200.mat';
    load([szDir filesep szFile], 'basefrequencies');
else
%     basefrequencies = 80:0.5:450;
    basefrequencies = logspace(log10(50),log10(450),200);
end

Pxx = 10^5*Pxx;
% Cxy = 10^5*real(Cxy);
% Pyy = 10^5*Pyy;

% calculate correlation
[correlation] = CalcCorrelation(Pxx, stInfoFile.fs, specsize);

% duration one frame in sec
nLenFrame = 60/stInfoFile.nFrames; 
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get labels for new blocksize
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

idxTrOVS = groundTrOVS == 1;
idxTrFVS = groundTrFVS == 1;
idxTrNone = ~idxTrOVS & ~idxTrFVS;

% determine peaks of correlation
[peaks, locs, hFig, peaksOVS, peaksFVS, peaksNone] = ...
    DeterminePeaksCorrelation(correlation, basefrequencies, nBlocks, idxTrOVS, idxTrFVS, idxTrNone);

                        
% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder];
szFolder_Output = [szDir filesep 'Pitch' filesep 'PeaksMatFiles'];
if ~exist(szFolder_Output, 'dir')
    mkdir(szFolder_Output);
end

% save results as mat file
szFile = ['PeaksLocs_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
save([szFolder_Output filesep szFile], 'peaks', 'locs', 'peaksOVS', 'peaksFVS', 'peaksNone');
savefig(hFig, [szFolder_Output filesep szFile]);

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