function MCC=calcMCC(mConfusion)
% function to calculate Matthews correlation coefficient for binary
% classification
% Usage MCC=calcMCC(mConfusion)
%
% Parameters
% ----------
% mConfusion - confusion matrix, contains [true positives  false positives;
%                                          false negatives  true negatives]
%
% Returns
% -------
% MCC - Matthews correlation coefficient
%
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 23-Jan-2020 JP

% true positives
TP = mConfusion(1,1);

% false positives
FP = mConfusion(1,2);

% true negatives
TN = mConfusion(2,2);

% false negatives
FN = mConfusion(2,1);

% if confusion matrix has only one non-zero entry, this means that all
% samples in the dataset belong to one class, and they are either all
% correctly (for TP ~= 0 or TN ~= 0) or incorrectly (for FP ~= 0
% or FN ~= 0) classified
if sum(mConfusion(:) == 0) == 3
    if TP ~= 0 || TN ~= 0 % perfect classification
        MCC = 1;
        return;
    elseif FP ~= 0 || FN ~= 0 % perfect misclassification
        MCC = -1;
        return;
    end
end

if sum(mConfusion(:) == 0) == 2
    
    if TP ~= 0 && FP ~= 0
        a = TP;
        b = FP;
    elseif TP ~= 0 && FN ~= 0
        a = TP;
        b = FN;
    elseif TP ~= 0 && FN ~= 0
        a = TP;
        b = FN;
    elseif TN ~= 0 && FP ~= 0
        a = TN;
        b = FP;
    elseif TN ~= 0 && FN ~= 0
        a = TN;
        b = FN;
    end
    
    if ~(TP ~= 0 && TN ~= 0)
        MCC = eps/sqrt(eps)*(a-b)/(sqrt(2*(a+b)*(a+eps)*(b+eps)));
        return;
    end
end

denominator = sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));

if denominator == 0
    denominator = 1;
end

% Matthews correlation coefficient
MCC = (TP*TN-FP*FN)/denominator;

%--------------------Licence ---------------------------------------------
% Copyright (c) <2020> J. Pohlhausen
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