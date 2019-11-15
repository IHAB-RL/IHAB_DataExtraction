function [mWeighted]=weightingFrequency(mUnweighted, samplerate, specsize)
% function to do something usefull (fill out)
% Usage [mWeight]=weightingFrequency(mUnweight, samplerate, specsize)
%
% Parameters
% ----------
% mUnweighted - matrix to be weighted 
%
% samplerate - sampling frequency in Hz 
%
% specsize - number of frequency bins 
%
% Returns
% -------
% mWeighted - weighted input matrix
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 15-Nov-2019 JP

% calculate frequency vector
vFrequencies = linspace(0, samplerate/2, specsize);

% weight according to acoustical perception:
log_f_weight =  1 ./ (samplerate/2).^(vFrequencies / (samplerate/2));

mWeighted = mUnweighted .* log_f_weight;


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