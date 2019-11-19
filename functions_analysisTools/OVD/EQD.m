function [eqd]=EQD(x,nBlocks)
% function to calculate the Empirischen Quartilsdispersionskoeffizient -EQD
% Usage [eqd]=EQD(x,nBlocks)
%
% Parameters
% ----------
% x - input data vector, e.g. RMS values
%
% nBlocks - number of time frames
%
% Returns
% -------
% eqd - vector containing the calculated EQD
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% formula according to https://de.wikipedia.org/wiki/Variationskoeffizient  
% Version History:
% Ver. 0.01 initial create (empty) 18-Nov-2019  JP

eqd = NaN(nBlocks, 2);
for iLoop = 1:nBlocks

    % adjust indices
    vIdx = 1+(iLoop-1)*10 : iLoop*10;
    
    if vIdx(end) > length(x)
        vIdx(vIdx > length(x)) = [];
    end
    
    % select 10 adjacent frames
    mBlock = x(vIdx, :);

    % calculate EQD
    eqd(iLoop, :) = ((prctile(mBlock, 75)-prctile(mBlock, 25))./ median(mBlock))';

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