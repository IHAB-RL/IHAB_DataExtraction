function [mConfusion]=getConfusionMatrix(vPredicted, vGroundTruth)
% function to calculate the confusion matrix
% Usage [mConfusion]=getConfusionMatrix(vPredicted, vGroundTruth)
%
% Parameters
% ----------
% vPredicted   - vector, containing predicted values
% vGroundTruth - vector, containing true values
%
% Returns
% -------
% mConfusion - confusion matrix
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 24-Sep-2019  JP
% Ver. 1.0 generalized 15-Nov-2019  JP

% determine unique numbers in ground truth vector
vUniqueNums = unique(vGroundTruth);

% number of categories/ dimensions
nDim = length(vUniqueNums);

% preallocate
mConfusion = zeros(nDim, nDim);

for row = 1:nDim
    nPred = vUniqueNums(row);
    for column = 1:nDim
        nGT = vUniqueNums(column);
        mConfusion(row, column) = sum((vPredicted == nPred) & (vGroundTruth == nGT));
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