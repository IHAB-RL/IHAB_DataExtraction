function [F1Score,precision,recall,accuracy] = F1M(vPredicted, vGroundTruth, fBeta, precision, recall)

% set weighting factor
if nargin == 2
    fBeta = 2;
end

if ~exist('precision', 'var')
    vGroundTruth(isnan(vGroundTruth)) = 0;
    vPredicted(isnan(vPredicted))= 0;
    vPredicted = double(vPredicted);
    
    tp = sum((vPredicted == 1) & (vGroundTruth == 1));
    tn = sum((vPredicted == 0) & (vGroundTruth == 0));
    fp = sum((vPredicted == 1) & (vGroundTruth == 0));
    fn = sum((vPredicted == 0) & (vGroundTruth == 1));
    
    precision = tp/(tp + fp);
    recall    = tp/(tp + fn);
    accuracy  = (tp + tn)/(tp + fp + tn + fn);
end

F1Score =(1+fBeta^2)*((precision.*recall) ./ (fBeta^2 * precision + recall));