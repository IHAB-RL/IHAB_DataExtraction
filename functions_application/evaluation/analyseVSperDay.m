function [vVS,vTimeVD]=analyseVSperDay(obj,stDate,nDurBlock,nCritRatio,nOverlap,szMode)
% function to analyse distribution of OVS per day
% Usage [vVS,vTimeVD]=analyseVSperDay(obj,stDate,nDurBlock,nCritRatio,nOverlap,szMode)
%
% Parameters
% ----------
% obj - class IHABdata, contains all informations
%
% stDate - struct which contains valid date informations about the time
%          informations: start and end day and time; this struct results
%          from calling checkInputFormat.m
%
% nDurBlock - number, blocksize in sec to build an overall decision 
%             voiced or not
% 
% nCritRatio - threshold to decide whether a block with a length of 
%              nDurBlock is voiced or not (based on prediction with a 
%              trained random forest); it is a ratio (so <= 1)
%
% nOverlap - number, overlap of adjacent blocks; [0 1[ ; by default 0.5
%
% szMode - string, mode of voice detection; 'OVD' - own voice detection, by
%          default; 'FVD' - further voices detection
%
% Returns
% -------
% vVS - vector, contains block based 1 (==voice) | 0 (==no voice)
%
% vTimeVD - corresponding time vector
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019 JP
% Ver. 1.0 new input options 6-Apr-2020 JP

if ~exist('szMode', 'var')
    szMode = 'OVD';
end

if ~exist('nOverlap', 'var')
    nOverlap = 0.5;
end

% predict voice sequences with a trained random forest
[vPredictedVS, vTimePSD,Cxy] = detectVoiceRandomForest(obj, stDate, szMode);

% number of frames (each 125ms)
nFrames = size(vPredictedVS, 1);

if isempty(nFrames)
    disp('no data found...');
    vVS = []; 
    vTimeVD = []; 
    return;
end

% decide over a given time intervall/block (e.g. nDurBlock = 5s / 40 frames);
% duration of one frame in sec
nDurFrame = 0.125;

% determine number of frames per block
nFramesPerBlock = nDurBlock/nDurFrame; 

% feed between adjacent blocks
nFeed = (1 - nOverlap) * nFramesPerBlock;

% total number of blocks
nBlocksTotal = floor((nFrames - (nFramesPerBlock-nFeed))/nFeed);
  
% define threshold ratio
nThresVS = nFramesPerBlock * nCritRatio;

% preallocate voice vector
vVS = zeros(nBlocksTotal, 1);

% decision based on blocks
for nBlock = 1:nBlocksTotal
    
    % select block
    vIndices = ((nBlock-1)*nFeed+1) : ((nBlock-1)*nFeed+nFramesPerBlock);
    vPredVSBlock = vPredictedVS(vIndices);
    
    % check threshold
    if sum(vPredVSBlock) >= nThresVS
        vVS(nBlock) = 1;
    end
end

% adjust time vector
vTimeVD = vTimePSD(nFramesPerBlock/2 : nFeed : nFrames - nFeed);


% debug plot
% figure;
% subplot(2,1,1)
% plot(vTimePSD, vPredictedVS);
% subplot(2,1,2)
% plot(vTimeVD, vVS, 'x');
isPlot = true;
if isPlot
    
    vTime = datenum(vTimeVD);
    vTimePSD = datenum(vTimePSD);
    
    figure('Position',[128 236 792 462]);
    axCPSD = axes('Position',[0.07 0.07 0.9 0.45]);
    nFS = 24000; % sampling frequency
    nFFT = 1024; % fft size
    vFreq = 0 : nFS/nFFT : nFS/2;
    Cxy_log = real(10*log10(Cxy'));
    imagesc(vTimePSD, vFreq, Cxy_log);
    axis xy;
    c = colorbar;
    xlabel('time in HH:MM \rightarrow');
    ylabel('frequency in Hz');
    ylabel(c,'CPSD');
    datetickzoom(gca,'x','HH:MM');
    xlim([vTime(1) vTime(end)]);
    drawnow;
    vPosition = get(axCPSD,'Position');
    
    axVD = axes('Position',[vPosition(1) 0.82 vPosition(3) 0.14]);
    plot(vTimePSD, vPredictedVS);
    title([szMode ' based on ' num2str(nDurFrame) 's']);
    datetickzoom(gca,'x','HH:MM');
    xlim([vTime(1) vTime(end)]);

    axVDBlock = axes('Position',[vPosition(1) 0.59 vPosition(3) 0.14]);
    plot(vTime, vVS);
    title([szMode ' based on ' num2str(nDurBlock) 's blocks with ' num2str(100*nOverlap) '% overlap']);
    datetickzoom(gca,'x','HH:MM');
    xlim([vTime(1) vTime(end)]);
    
    linkaxes([axCPSD,axVD,axVDBlock],'x');
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