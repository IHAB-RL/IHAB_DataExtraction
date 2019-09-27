function [F1Score,precision,recall] = F1M(x, vResampledGroundTruth, fBeta, precision, recall)

if nargin == 2
    fBeta = 2;
end

if ~exist('precision')
    vResampledGroundTruth(isnan(vResampledGroundTruth)) = 0;
    x(isnan(x))= 0;
    x = double(x);
    
    tp = sum((x == 1) & (vResampledGroundTruth == 1));
    tn = sum((x == 0) & (vResampledGroundTruth == 0));
    fp = sum((x == 1) & (vResampledGroundTruth == 0));
    fn = sum((x == 0) & (vResampledGroundTruth == 1));
    
    precision = tp/(tp + fp);
    recall    = tp/(tp + fn);
end

F1Score =(1+fBeta^2)*((precision.*recall) ./ (fBeta^2 * precision + recall));