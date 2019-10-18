function [TimeVecOut, DataVecOut]=FillTimeGaps(TimeVec, DataVec)
% function to find time gaps and fill them with NaNs in the data vector
% -> cave: the time vector is filled as well
% Usage [TimeVecOut, DataVecOut]=FillTimeGaps(TimeVec, DataVec)
%
% Parameters
% ----------
% inParam :
%	 TimeVec - datetime array
%
%    DataVec - vector, contains data values of the coherence or PSD
%              the values dependent on frequency and time
%
% Returns
% -------
% outParam :
%   TimeVecOut - datetime array with filled time gaps 
%
%   DataVecOut - data vector with filled time gaps (NaNs)
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 15-Oct-2019 JP

% assign output vectors
TimeVecOut = TimeVec;
DataVecOut = DataVec;

% calculate time gap between adjacent samples in seconds
vGaps = seconds(TimeVec(2:end) - TimeVec(1:end-1));

% get usual time gap, i.e. the most occurrent value of the distribution of
% all calculated time gaps
[NrOfOccurrences,Values] = hist(vGaps, unique(vGaps));
[~,idxSort] = sort(NrOfOccurrences,'descend');
UsualValue = Values(idxSort(1));

% detect gaps that are significant greater, i.e. 5 times, than the usual
% time gap
idxGaps = find(vGaps > 10*UsualValue);

if ~isempty(idxGaps)
    
    % number of detected gaps
    NrOfGaps = numel(idxGaps);
    
    % get usual value as duration in sec
    UsualValue = seconds(UsualValue);
    
    % define insert expressions; based on:
    % https://de.mathworks.com/matlabcentral/answers/48942-insert-element-in-vector
    insertTime = @(a, x, n) cat(1, x(1:n), a, x(n+1:end));
    insertData = @(a, x, n) cat(2, x(:,1:n), a, x(:,n+1:end));
    
    % time values at the edges of the time gaps
    t1 = TimeVec(idxGaps) + UsualValue;
    t2 = TimeVec(idxGaps+1) - UsualValue;
    
    % loop over all detected time gaps
    for gap = 1:NrOfGaps
        
        if gap > 1
            % shift index vector
            idxGaps = idxGaps + NrOfNaN(gap-1);
        end
        
        % calculate time values to fill gap
        newTimes = [t1(gap):UsualValue:t2(gap)]';
        
        % add corresponding time values into time vector
        TimeVecOut = insertTime(newTimes, TimeVecOut, idxGaps(gap));
        
        % calculate number of needed NaNs for filling the time gap
        NrOfNaN(gap) = size(newTimes,1);
        
        % insert NaNs into data vector
        DataVecOut = insertData(NaN(size(DataVec,1),NrOfNaN(gap)), DataVecOut, idxGaps(gap));
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