function [Data,TimeVec]=getAudioSignal(obj)
% function to load the audio signal and labels of own / futher voice for
% one test subject
% Usage [Data,TimeVec]=getAudioSignalLabels(obj)
%
% Parameters
% ----------
% obj : struct, contains all informations
%
% Returns
% -------
% Data :  a matrix containg the feature data
%
% TimeVec :  a date/time vector with the corresponding time information
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: the function is based on getObjectiveData.m
% Version History:
% Ver. 0.01 initial create 14-Oct-2019  JP

% preallocate output parameters
Data = [];
TimeVec = [];

% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

% List all feat files
AllWavFiles = listFiles(szDir,'*.wav');
AllWavFiles = {AllWavFiles.name}';

% Get names wo. path
[~,AllWavFiles] = cellfun(@fileparts, AllWavFiles,'UniformOutput',false);

% Append '.wav' extension for comparison to corrupt file names
AllWavFiles = strcat(AllWavFiles,'.wav');

% isFeatFile filters for the wanted feature dates, such as all of 'RMS'
[dateVecAll,isFeatFile] = Filename2date(AllWavFiles,[]);

% Also filter the corresponding file list
AllWavFiles = AllWavFiles(logical(isFeatFile));


%% read the data

% get number of available feature files in current time frame
NrOfFiles = numel(AllWavFiles);

if ~isempty(AllWavFiles)
    
    % loop over each feature file
    Startindex = 1;
    for fileIdx = 1:NrOfFiles
        
        szFileName =  AllWavFiles{fileIdx};
        
        % load data from feature file
        [WavData, fs] = audioread([szDir filesep szFileName]);
        
        ActBlockSize = size(WavData,1);
        
        Data(Startindex:Startindex+ActBlockSize-1,:) = WavData;
        
        % calculate time vector
        DateTimeValue = dateVecAll(fileIdx);
        TimeVec(Startindex:Startindex+ActBlockSize-1) = linspace(DateTimeValue,DateTimeValue+minutes(1-1/ActBlockSize),ActBlockSize);
        
        Startindex = Startindex + ActBlockSize;
    end
    
end % if: ~isempty(AllFeatFiles)


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