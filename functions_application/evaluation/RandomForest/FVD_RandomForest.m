% Script to train a random forest; first only OV; second on residual data FV
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019 	JP

clear;
% close all;


% set variables
% szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'mEQD', 'mMeanSPP', 'mCorrRMS', 'vGroundTruthVS'};
% vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1'; 'ZCRdiff2'; 'EQD1'; 'EQD2'; 'MeanSPP'; 'rms(Corr)'};
szVarNames = {'mMeanRealCoherence', 'mRMS', 'Cxy', 'mEQD', 'mMeanSPP', 'mCorrRMS', 'vGroundTruthVS'};
vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; 'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; 'CPSD12'; 'EQD1'; 'EQD2'; 'MeanSPP'; 'rms(Corr)'};
% szVarNames = {'mMeanRealCoherence', 'Pxx', 'Cxy', 'vGroundTruthVS'};
% vNames = {'Re(Cohe)'; 'APSD1'; 'APSD2'; 'APSD3'; 'APSD4'; 'APSD5'; 'APSD6'; 'APSD7'; 'APSD8'; 'APSD9'; 'APSD10'; 'APSD11'; 'APSD12'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; 'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; 'CPSD12'};
% szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'mfcc', 'mEQD', 'mMeanSPP', 'mCorrRMS', 'vGroundTruthVS'};
% vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1'; 'ZCRdiff2'; 'MFCC1'; 'MFCC2'; 'MFCC3'; 'MFCC4'; 'MFCC5'; 'MFCC6'; 'MFCC7'; 'MFCC8'; 'MFCC9'; 'MFCC10'; 'MFCC11'; 'MFCC12'; 'MFCC13'; 'EQD1'; 'EQD2'; 'MeanSPP'; 'rms(Corr)'};
% szVarNames = {'mMeanRealCoherence', 'mfcc', 'Cxy', 'mEQD', 'mCorrRMS', 'vGroundTruthVS'};
% vNames = {'Re(Cohe)'; 'MFCC1'; 'MFCC2'; 'MFCC3'; 'MFCC4'; 'MFCC5'; 'MFCC6'; 'MFCC7'; 'MFCC8'; 'MFCC9'; 'MFCC10'; 'MFCC11'; 'MFCC12'; 'MFCC13'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; 'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; 'CPSD12'; 'EQD1'; 'EQD2'; 'rms(Corr)'};


% create training data set
isTraining = true;
[mDataSet, vVoiceLabels] = createTestSet(szVarNames, isTraining);

% only OVS, 'delete' FVS
vOVSLabels = vVoiceLabels;
vOVSLabels(vOVSLabels == 2) = 0;

% set number of trees
nTrees = 50;

%% Train an ensemble of bagged classification trees for OVD
RandomForest_OVD = TreeBagger(nTrees, mDataSet, vOVSLabels, 'OOBPrediction', 'On',...
    'Method', 'classification', 'OOBPredictorImportance', 'On',...
    'PredictorNames', vNames); % 'Prior', 'Uniform'


%% Test the ensemble of bagged classification trees for OVD
% create test data set
isTraining = false;
[mTestDataSet, vGroundTruthVS] = createTestSet(szVarNames, isTraining);

% only OVS, 'delete' FVS
vGroundTruthOVS = vGroundTruthVS;
vGroundTruthOVS(vGroundTruthOVS == 2) = 0;

% start prediction with trained ensemble of bagged classification trees
vPredictedOVS = predict(RandomForest_OVD, mTestDataSet);
vPredictedOVS = str2num(cell2mat(vPredictedOVS));

vLabels = {'no OVS', 'OVS'};
plotConfusionMatrix([], vLabels, vGroundTruthOVS, vPredictedOVS)


% remove all entries for predicted OVS
vPredictedOVS = logical(vPredictedOVS);
mTestDataSet(vPredictedOVS, :) = [];

% only FVS, 'delete' OVS
vFVSLabels = vVoiceLabels;
vFVSLabels(vFVSLabels == 1) = 0;
vGroundTruthFVS = vGroundTruthVS;
vGroundTruthFVS(vPredictedOVS) = [];
vGroundTruthFVS(vGroundTruthFVS == 1) = 0;

%% Train an ensemble of bagged classification trees for FVD
RandomForest_FVD = TreeBagger(nTrees, mDataSet, vFVSLabels, 'OOBPrediction', 'On',...
    'Method', 'classification', 'OOBPredictorImportance', 'On',...
    'PredictorNames', vNames); % 'Prior', 'Uniform'


%% Test the trained ensemble of bagged classification trees for FVD
vPredictedFVS = predict(RandomForest_FVD, mTestDataSet);
vPredictedFVS = str2num(cell2mat(vPredictedFVS));

% display results as confusion matrix
vLabels = {'no FVS', 'FVS'};
plotConfusionMatrix([], vLabels, vGroundTruthFVS, vPredictedFVS)

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
% Institute for Hearing Technology and Audiology
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