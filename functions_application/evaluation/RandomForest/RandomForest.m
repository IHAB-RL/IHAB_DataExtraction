% Script to train a random forest
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 20-Nov-2019 	JP

clear;
close all;


% set variables
szVarNames = {'mMeanRealCoherence', 'mRMS', 'vGroundTruthVS'};
vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'}; %; 'CPSD'; 'PH1'; 'PH2'; 'PH3'

% create training data set
isTraining = true;
[mDataSet, vVoiceLabels] = createTestSet(szVarNames, isTraining);

% set number of trees
nTrees = 50;

%% Train an ensemble of bagged classification trees 
tic
Mdl = TreeBagger(nTrees, mDataSet, vVoiceLabels, 'OOBPrediction', 'On',...
    'Method', 'classification', 'OOBPredictorImportance', 'On',...
    'PredictorNames', vNames); % 'Prior', 'Uniform'
toc

% % view for example decision tree nr. 1
% view(Mdl.Trees{1},'Mode','graph');

% TreeBagger stores predictor importance estimates in the property
% OOBPermutedPredictorDeltaError. Compare the estimates using a bar graph
imp = Mdl.OOBPermutedPredictorDeltaError;

figure;
bar(imp);
ylabel('Predictor importance estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel = Mdl.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

% Plot the out-of-bag error over the number of grown classification trees
figure;
oobErrorBaggedEnsemble = oobError(Mdl);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';


%% Test the ensemble of bagged classification trees 
% create test data set
isTraining = false;
[mTestDataSet, vGroundTruthVS] = createTestSet(szVarNames, isTraining);

% start prediction with trained ensemble of bagged classification trees
vPredictedVS = predict(Mdl, mTestDataSet);
vPredictedVS = str2num(cell2mat(vPredictedVS));

% display results as confusion matrix
vLabels = {'no VS', 'OVS', 'FVS'};
plotConfusionMatrix([], vLabels, vGroundTruthVS, vPredictedVS)


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