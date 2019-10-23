function [vActivOVS,vActivFVS]=getVoiceLabels(obj)
% function to return the labels of own or futher voice sequences (OVS/FVS)
% Usage [vActivOVS,vActivFVS]=getVoiceLabels(obj)
%
% Parameters
% ----------
%	 obj - struct, contains all informations, e.g. datafolder, subject ...
%
% Returns
% ------- 
%	 vActivOVS - logical vector, 1 = OVS
%
%    vActivFVS - logical vector, 1 = FVS
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 15-Oct-2019 JP

% preallocate output vector
vActivOVS = zeros(1,obj.NrOfBlocks);
vActivFVS = zeros(1,obj.NrOfBlocks);

% build the full directory
szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

gtFile = fullfile(szDir,[obj.szCurrentFolder '_' obj.szNoiseConfig '_Voice.txt']);

if ~exist(gtFile)
    % NS measured
    isNS = 1;
    gtFile = fullfile(szDir,[obj.szCurrentFolder '_' obj.szNoiseConfig '.txt']);
else
    isNS = 0;
end

vActVoice = importdata(gtFile);

%% FVS
if isNS
    fvsIndicator = 1 ; % NS
else
    fvsIndicator = 0; % JP
end

idxFVS = vActVoice(:,3) == fvsIndicator;

if ~any(idxFVS == 1)
    % NS labeled
    gtFile = fullfile(szDir,[obj.szCurrentFolder '_' obj.szNoiseConfig '_VoiceOthers.txt']);
    vActVoiceFVS = importdata(gtFile);
    
    startTimeFVS = vActVoiceFVS(:, 1);
    endTimeFVS = vActVoiceFVS(:, 2);
else
    
    startTimeFVS = vActVoice(idxFVS, 1);
    endTimeFVS = vActVoice(idxFVS, 2);
end


% check bounds
[startIdxFVS,endIdxFVS] = checkBounds(obj,startTimeFVS,endTimeFVS);

for ll = 1:size(startIdxFVS,1)
    vActivFVS(startIdxFVS(ll):endIdxFVS(ll)) = 1;
end


%% OVS
if exist('vActVoiceFVS', 'var')
    startTimeOVS = vActVoice(:, 1);
    endTimeOVS = vActVoice(:, 2);
elseif isNS
    ovsIndicator = 0;
    idxOVS = vActVoice(:,3) == ovsIndicator;
    
    startTimeOVS = vActVoice(idxOVS, 1);
    endTimeOVS = vActVoice(idxOVS, 2);
else
    startTimeOVS = vActVoice(~idxFVS,1);
    endTimeOVS = vActVoice(~idxFVS,2);
end

% check bounds
[startIdxOVS,endIdxOVS] = checkBounds(obj,startTimeOVS,endTimeOVS);

for ll = 1:size(startIdxOVS,1)
    vActivOVS(startIdxOVS(ll):endIdxOVS(ll)) = 1;
end


function [startIdx, endIdx] = checkBounds(obj, startTime, endTime)
    startIdx = round(startTime*obj.fsVD);
    startIdx(startIdx==0) = 1;
    endIdx = round(endTime*obj.fsVD);
    outOfBoundsStart = find(startIdx>obj.NrOfBlocks,1);
    outOfBoundsEnd = find(endIdx>obj.NrOfBlocks,1);
    if ~isempty(outOfBoundsEnd) && ~isempty(outOfBoundsStart)
        endIdx(outOfBoundsEnd:end) = [];
        startIdx(outOfBoundsEnd:end) = [];

    elseif ~isempty(outOfBoundsEnd) && startIdx(outOfBoundsEnd) <= obj.NrOfBlocks
        endIdx(outOfBoundsEnd) = obj.NrOfBlocks;
        if length(endIdx)>outOfBoundsEnd
            endIdx(outOfBoundsEnd+1:end) = [];
            startIdx(outOfBoundsEnd+1:end) = [];
        end
    end
end
end
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