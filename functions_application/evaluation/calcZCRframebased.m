function [mZCR] = calcZCRframebased(mSignal,fs,isPrivacy)
% function to calculate frame based the zero crossing rate of given 
% input signal and its first derivation
% Usage [mZCR] = calcZCRframebased(mSignal,fs,isPrivacy)
%
% Parameters
% ----------
% mSignal - matrix contains time signal
%
% fs - sampling frequency in Hz
%
% isPrivacy - logical whether it is privacy mode or not; if true just every
%             10th frame is saved; by default false
%
% Returns
% -------
% mZCR - matrix contains for each channel zero crossing rate
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 18-Nov-2019 JP

if nargin == 2
    isPrivacy = false;
end

tFrame      = 0.025;
lFrame      = floor(tFrame*fs);
lOverlap    = lFrame/2;
lFeed       = lFrame-lOverlap;

lSig       = size(mSignal,1);
nFrames     = floor((lSig-lOverlap)/lFeed);

if isPrivacy
    mZCR    = zeros(floor(nFrames/10)+1, 4);
else
    mZCR    = zeros(nFrames, 4);
end

% calculate first derivation of input signal
mDiffSignal = diff(mSignal);
mDiffSignal(end+1, :) = 0;

counter = 1;

for iFrame = 1:nFrames
    
    vIDX = ((iFrame-1)*lFeed+1):((iFrame-1)*lFeed+lFrame);
    
    if isPrivacy
        if mod(iFrame,10) == 0
            mZCR(counter, 1:2) = ZCR(mSignal(vIDX,:));
            mZCR(counter, 3:4) = ZCR(mDiffSignal(vIDX,:));
            counter = counter+1;
        end
    else
        mZCR(iFrame, 1:2) = ZCR(mSignal(vIDX,:));
        mZCR(iFrame, 3:4) = ZCR(mDiffSignal(vIDX,:));
    end
    
end

% set to absolute value
mZCR = mZCR*lFrame; 

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