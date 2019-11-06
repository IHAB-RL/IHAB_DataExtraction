function [estimatedOVS]=OVD_Pitch(peaks)
% function to estimate own voice sequences (OVS) based on "Pitch"
% work in progress
% Usage [estimatedOVS]=OVD_Pitch(peaks)
%
% Parameters
% ----------
% inParam :  
%   peaks - matrix, contains for each time frame the height of maximal 3 
%           detected peaks in the correlation of PSD and synthetic spectra
%
% Returns
% -------
% outParam :  
%   estimatedOVS - logical array, 1 = OVS
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 05-Nov-2019  JP

% define minimum height of correlation peak
minHeight = 10;

% calculate harmonic ratio

% detect peaks that are higher than the minimum height
estimatedOVS = peaks(:, 1) >= minHeight;

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