function [vActivOVS,vActivFVS]=getVoiceLabels(obj)
% function to return the labels of own or futher voice sequences (OVS/FVS)
% because three different person labeled the audio data, there are
% differences in the label settings.
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

% list with all persons that collected and labeled audio data
stPersons = {'nils'; 'PROBAND'; 'OUTDOOR'; 'Jule'};


% open file with labeled ground truth data
if contains(obj.szBaseDir, stPersons{1}) % NS measured
    gtFile = fullfile(obj.szDir,[obj.szCurrentFolder '_' obj.szNoiseConfig '.txt']);
    
elseif contains(obj.szBaseDir, stPersons{3}) % SB Outdoor
    gtFile = fullfile(obj.szDir,['IHAB_' obj.szNoiseConfig '_Voice.txt']);
    
else
    gtFile = fullfile(obj.szDir,[obj.szCurrentFolder '_' obj.szNoiseConfig '_Voice.txt']);
    
end

vActVoice = importdata(gtFile);

if isempty(vActVoice)
    return;
end

%% FVS
if contains(obj.szBaseDir, stPersons{1})
    fvsIndicator = [1 2 3];
    
elseif contains(obj.szBaseDir, stPersons{2}) || contains(obj.szBaseDir, stPersons{3})
    fvsIndicator = 0; % JP labeled SB data
    
else
    fvsIndicator = 1:10; % JP data
end

idxFVS = vActVoice(:,3) == fvsIndicator;
if size(idxFVS,2) > 1
    idxFVS = logical(sum(idxFVS, 2));
end

if ~any(idxFVS == 1) && contains(obj.szBaseDir, stPersons{2})
    % NS labeled SB data
    gtFile = fullfile(obj.szDir,[obj.szCurrentFolder '_' obj.szNoiseConfig '_VoiceOthers.txt']);
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
if contains(obj.szBaseDir, stPersons{2}) && exist('vActVoiceFVS', 'var')
    % NS labeled SB data
    startTimeOVS = vActVoice(:, 1);
    endTimeOVS = vActVoice(:, 2);
elseif contains(obj.szBaseDir, stPersons{2}) || contains(obj.szBaseDir, stPersons{3})
    % SB labeled
    startTimeOVS = vActVoice(~idxFVS,1);
    endTimeOVS = vActVoice(~idxFVS,2);
else
    % JP or NS data
    ovsIndicator = 0;
    idxOVS = vActVoice(:,3) == ovsIndicator;
    
    startTimeOVS = vActVoice(idxOVS, 1);
    endTimeOVS = vActVoice(idxOVS, 2);
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