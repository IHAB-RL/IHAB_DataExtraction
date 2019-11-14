function [mRMS] = calcRMSframebased(mSignal,fs,isPrivacy)
% function to do something usefull (fill out)
% Usage [mRMS] = calcRMSframebased(mSignal,fs,isPrivacy)
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
% mRMS - matrix contains for each channel rms values for frames of 25ms
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Source: detectRMSBlocks.m by S. Bilert 2017  
% Version History:
% Ver. 0.01 initial create 13-Nov-2019 JP

if nargin == 2
    isPrivacy = false;
end

tFrame      = 0.0125;
lFrame      = floor(tFrame*fs);

lSig       = size(mSignal,1);
lOverlap    = lFrame/2;

lFeed       = lFrame-lOverlap;
nFrames     = floor((lSig-lOverlap)/lFeed);

if isPrivacy
    mRMS    = zeros(floor(nFrames/10)+1,size(mSignal,2));
else
    mRMS    = zeros(nFrames,size(mSignal,2));
end

counter = 1;

for iFrame = 1:nFrames
    
    vIDX = ((iFrame-1)*lFeed+1):((iFrame-1)*lFeed+lFrame);
    
    if isPrivacy
        if mod(iFrame,10) == 0
            mRMS(counter,:) = rms(mSignal(vIDX,:),1);
            counter = counter+1;
        end
    else
        mRMS(iFrame,:) = rms(mSignal(vIDX,:),1);
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