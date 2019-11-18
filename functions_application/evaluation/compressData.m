function [DataOut] = compressData(Data, nFramesOld, stControl)
% function to compress given data
% Usage [DataOut] = compressData(Data, nFramesOld, stControl)
%
% Parameters
% ----------
%   Data       - data vector
%
%   nFramesOld - actual number of time frames per minute
%
%   stControl  - optional, struct with control parameters
%
% Returns
% -------
%   Data       - compressed data vector
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 13-Nov-2019  JP

% set parameters for data compression
if ~exist('stControl', 'var')
    stControl.nDataPointOverlap_percent = 0;
    stControl.szTimeCompressionMode = 'mean';
    stControl.nDataPointRepresentation_s = 0.125;
    
    % define compression ratio, old/new
    stControl.nCompRatio = 10;
end

% new number of frames per minute
nFramesNew = round(nFramesOld / stControl.nCompRatio);

nRemain = rem(size(Data, 1),  stControl.nCompRatio*nFramesNew);
if nRemain ~= 0
    Data(end-nRemain+1:end, :) = [];
end

nDataLen_min = size(Data, 1)/(stControl.nCompRatio*nFramesNew);
nDataLen_s = nDataLen_min*60;
nDataPoints = nDataLen_min * nFramesNew;

BlockLen = round(size(Data, 1)*stControl.nDataPointRepresentation_s/nDataLen_s);
BlockFeed = round(BlockLen*(1-stControl.nDataPointOverlap_percent));
BlockIndex = 1:BlockLen;
Counter = 1;

DataOut = zeros(nDataPoints,size(Data,2));

while (BlockIndex(end) <= size(Data, 1))
    % The block time is the middle of the block
    DataOut(Counter,:) = mean(Data(BlockIndex,:));
    
    BlockIndex = BlockIndex + BlockFeed;
    Counter = Counter + 1;
    
    if BlockIndex(end) > size(Data, 1)
        DataOut(Counter:end,:) = [];
        return;
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