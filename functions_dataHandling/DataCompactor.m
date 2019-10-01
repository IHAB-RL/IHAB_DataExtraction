function [DataVecOut,TimeVecOut,TimeVecRes,DataVecRes,NrOfDataPoints]=DataCompactor(DataVec,TimeVec,stControl)
% function to compact feature data by different methods
% Usage [DataVec,TimeVec]=DataCompactor(DataVec,TimeVec,stControl)
%
% Parameters
% ----------
% DataVec :  matrix   NrOfDataPoint x FeatureDimension
%
% TimeVec :  datetime vector
%
% stControl :  struct containing the following information
%               stControl.DataPointRepresentation_s ;
%               stControl.DataPointOverlap_percent;
%               stControl.szTimeCompressionMode ('SubSample', 'Mean', 'Max') ;
%
% Returns
% -------
% DataVecOut :  matrix
%	 The compacted data matrix
% TimeVec :  datetime vector
%	 The new timeline
%
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J. BItzer (c) TGM @ Jade Hochschule applied licence see EOF
% Source: If the function is based on a scientific paper or a web site,
%         provide the citation detail here (with equation no. if applicable)
% Version History:
% Ver. 0.01 initial create (empty) 18-May-2017  Initials (eg. JB)
% Ver. 0.02 add nargout == 3 29-Sept-2019 JP
% Ver. 0.03 save residuals 01-Oct-2019 JP

% pre-allocate output params
TimeVecRes = [];
DataVecRes = [];

if ~isfield(stControl, 'NrOfDataPoints')
    DataLen_s = seconds(TimeVec(end)-TimeVec(1) + TimeVec(end)-TimeVec(end-1));
    NrOfDataPoints = ceil(DataLen_s/(stControl.DataPointRepresentation_s*(1-stControl.DataPointOverlap_percent)));
else
    NrOfDataPoints = stControl.NrOfDataPoints;
end

if nargout == 5
    % just get number of data points and return
    DataVecOut = [];
    TimeVecOut = [];
    return;
end

if strcmpi(stControl.szTimeCompressionMode,'subsample')
    % Subsamplin only
    if (stControl.DataPointOverlap_percent>0)
        warning('SubSampling does not correspond to overlapping block processing ');
    end
    NrOfDataPoints = (DataLen_s/(stControl.DataPointRepresentation_s));
    SubSampleFaktor = round(length(TimeVec)/NrOfDataPoints);
    DataVecOut = DataVec(1:SubSampleFaktor:end,:);
    TimeVecOut= TimeVec((1:SubSampleFaktor:end));
end
% mean
if strcmpi(stControl.szTimeCompressionMode,'mean')
    BlockLen = round(length(TimeVec)*stControl.DataPointRepresentation_s/DataLen_s);
    BlockFeed = round(BlockLen*(1-stControl.DataPointOverlap_percent));
    BlockIndex = 1:BlockLen;
    Counter = 1;
    TimeVecOut = datetime(zeros(NrOfDataPoints,1),zeros(NrOfDataPoints,1),zeros(NrOfDataPoints,1));
    
    DataVecOut = zeros(NrOfDataPoints,size(DataVec,2));
    
    while (BlockIndex(end) <= length(TimeVec))
        % The block time is the middle of the block
        TimeVecOut(Counter) = TimeVec(BlockIndex(round(length(BlockIndex)/2)));
        DataVecOut(Counter,:) = mean(DataVec(BlockIndex,:));
        
        BlockIndex = BlockIndex + BlockFeed;
        Counter = Counter + 1;
        
        if BlockIndex(end) > length(TimeVec) 
            BlockIndex(BlockIndex > length(TimeVec)) = [];
            if ~isempty(BlockIndex) 
                % save residuals
                TimeVecRes = TimeVec(BlockIndex);
                DataVecRes = DataVec(BlockIndex,:);
            end
            
            DataVecOut(Counter:end,:) = [];
            TimeVecOut(Counter:end,:) = [];
            return;
        end
    end
end

if strcmpi(stControl.szTimeCompressionMode,'max')
    BlockLen = round (length(TimeVec)*stControl.DataPointRepresentation_s/DataLen_s);
    BlockFeed = round(BlockLen*(1-stControl.DataPointOverlap_percent));
    BlockIndex = 1:BlockLen;
    Counter = 1;
    TimeVecOut = datetime(zeros(NrOfDataPoints,1),zeros(NrOfDataPoints,1),zeros(NrOfDataPoints,1));
    
    DataVecOut = zeros(NrOfDataPoints,size(DataVec,2));
    
    while (BlockIndex(end) <= length(TimeVec) )
        % The block time is the middle of the block
        TimeVecOut(Counter) = TimeVec(BlockIndex(round(length(BlockIndex)/2)));
        DataVecOut(Counter,:) = max(DataVec(BlockIndex,:));
        
        BlockIndex = BlockIndex + BlockFeed;
        Counter = Counter + 1;
    end
    DataVecOut(Counter:end,:) = [];
    TimeVecOut(Counter:end,:) = [];
end




%--------------------Licence ---------------------------------------------
% Copyright (c) <2017> J. Bitzer
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