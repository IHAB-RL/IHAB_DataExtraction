function [mConfusion]=getConfusionMatrix(vPredicted, vGroundTruth)
% function to calculate the confusion matrix
% Usage [outParam]=getConfusionMatrix(inParam)
%
% Parameters
% ----------
% inParam :  vPredicted   - vector, containing logicals
%            vGroundTruth - vector, containing logicals
%
% Returns
% -------
% outParam :  tp - number of true positive detection
%             tn - number of true negative detection
%             fp - number of false positive detection
%             fn - number of false negative detection
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 24-Sep-2019  JP

tp = sum((vPredicted == 1) & (vGroundTruth == 1));
tn = sum((vPredicted == 0) & (vGroundTruth == 0));
fp = sum((vPredicted == 1) & (vGroundTruth == 0));
fn = sum((vPredicted == 0) & (vGroundTruth == 1));

mConfusion = [tp fp; fn tn];


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