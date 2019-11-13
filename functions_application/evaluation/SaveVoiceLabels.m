function SaveVoiceLabels(obj)
% function to save voice labels as mat file
% Usage SaveVoiceLabels(inParam)
%
% Parameters
% ----------
% inParam :  obj - struct, contains all informations
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 06-Nov-2019  Initials JP
 
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
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;
    
    clear stData
else
    
    % extract PSD data
    version = 1; % JP modified get_psd
    [~, Pxx, ~] = get_psd(DataPSD, version);
    
    clear DataPSD
    
    % duration one frame in sec
    nLenFrame = 60/stInfoFile.nFrames;
end

% number of time frames
nBlocks = size(Pxx, 1);

% get ground truth voice labels
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
% get labels for new blocksize
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);

idxTrOVS = groundTrOVS == 1;
idxTrFVS = groundTrFVS == 1;
idxTrNone = ~idxTrOVS & ~idxTrFVS;

if isfield(obj, 'szCurrentFolder')                     
    % build the full directory
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

    szFile = ['VoiceLabels_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
else
    % build the full directory
    szDir = [obj.szBaseDir filesep obj.szNoiseConfig];

    szFile = ['VoiceLabels_' obj.szNoiseConfig];
end

% save results as mat file
save([szDir filesep szFile], 'idxTrOVS', 'idxTrFVS', 'idxTrNone', 'nLenFrame', 'nBlocks');

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