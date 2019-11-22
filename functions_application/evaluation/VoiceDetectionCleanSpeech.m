function [mVS1,mVS2]=VoiceDetectionCleanSpeech(obj)
% function to do something usefull (fill out)
% Usage [outParam]=VoiceDetectionCleanSpeech(inParam)
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
% Ver. 0.01 initial create (empty) 13-Nov-2019  JP


% read in clean speech signal
[mSignal, fs] = audioread(obj.szAudioFile);

% length of time signal in samples
nLen = length(mSignal);

% duration of time signal in sec
nDur = nLen/fs;

% calculate time vector for audio signal
time = linspace(0, nDur, nLen);

% calculate frame based (25ms) rms
mRMS = calcRMSframebased(mSignal, fs);
% mRMS = 20*log10(mRMS); % dB

% determine number of frames
nFrames = length(mRMS);

% length of one frame
nLenOneFrame = nDur/nFrames;

% calculate time vector for rms
timeRMS = linspace(0, nDur, nFrames);


% define threshold
mThreshold = 0.008*ones(size(mRMS));
idxVS = mRMS >= mThreshold;

[mVS1] = findVoiceSequences(obj.szPath, obj.szSubject1, idxVS(:, 1), nLenOneFrame);
[mVS2] = findVoiceSequences(obj.szPath, obj.szSubject2, idxVS(:, 2), nLenOneFrame);


bPlot = 0;
if bPlot 
    % plot results
    figure;
    ax1 = axes('Position',[0.1300 0.6900 0.7750 0.25]);
    plot(time, mSignal(:, 1));
    hold on;
    plot(timeRMS, mVS1, 'b');
    title(obj.szAudioFile);
    ylabel('signal amplitude');

    ax2 = axes('Position',[0.1300 0.40 0.7750 0.25]);
    plot(time, mSignal(:, 2), 'm');
    hold on;
    plot(timeRMS, mVS2, 'r');
    ylabel('signal amplitude');

    ax3 = axes('Position',[0.1300 0.1100 0.7750 0.25]);
    plot(timeRMS, mRMS);
    hold on;
    plot(timeRMS, mThreshold(:, 1), 'b:');
    plot(timeRMS, mThreshold(:, 2), 'r:');
    xlabel('Time in sec');
    ylabel('RMS in dB');
    xlim([timeRMS(1) timeRMS(end)]);
    linkaxes([ax1 ax2 ax3],'x');

end

function [mVS] = findVoiceSequences(szPath, szSubject, idxVS, nLenOneFrame)
    IdxFinder = diff(idxVS);
    IdxFinder(end+1,:) = 0;
    vStartIdx = find(IdxFinder==1)+1; % on set
    vEndIdx = find(IdxFinder==-1)+1; % off set

    % detect too short sequences
    vLength = vEndIdx - vStartIdx;
    isValidLen = vLength >= 2; 

    vStartIdx(~isValidLen) = [];
    vEndIdx(~isValidLen) = [];

    mVS = zeros(nFrames, 1);
    for ii = 1:size(vStartIdx,1)
        mVS(vStartIdx(ii):vEndIdx(ii)) = 1;
    end
    
    % set to time base
    vStartIdx = vStartIdx*nLenOneFrame;
    vEndIdx = vEndIdx*nLenOneFrame;
    
    % save in text file
    saveAsTextFile(szPath, szSubject, vStartIdx, vEndIdx);

end

function saveAsTextFile(szPath, szSubject, vStartIdx, vEndIdx)
    vLabel = ones(size(vEndIdx));
    mALL = [vStartIdx vEndIdx vLabel]';
    filename = [szPath filesep 'VoiceLabels' filesep szSubject '_config0_Voice.txt'];
    fileID = fopen(filename,'w');
    fprintf(fileID, '%6.8f %12.8f %1.0f\n', mALL);
    fclose(fileID);
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