% Script to train a random forest with different feature sets
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 20-Nov-2019 	JP

clear;
close all;

szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\RandomForests';

% set number of combis of predictors for classification
nPredSet = 1:6;
    
% choose between only OVD, OVD and FVD (default) or only FVD
% szMode = [];
szMode = 'OVD';
% szMode = 'FVD';

for n = 1:length(nPredSet)
    
    % set predictors for classification
    [szVarNames, vNames] = setPredictors(nPredSet(n));
    
    % create training data set
    isTraining = true;
    [mDataSet, vVoiceLabels] = createTestSet(szVarNames, isTraining, szMode);
    [mDataSet_GL, vVoiceLabels_GL] = createTestSetDirect(szVarNames, isTraining, szMode);
    
    % add data form gesture lab
    mDataSet = [mDataSet; mDataSet_GL];
    vVoiceLabels = [vVoiceLabels; vVoiceLabels_GL];
    
    % set number of trees
    nTrees = 100;
    
    %% Train an ensemble of bagged classification trees
    MRandomForest = TreeBagger(nTrees, mDataSet, vVoiceLabels, 'OOBPrediction', 'On',...
        'Method', 'classification', 'OOBPredictorImportance', 'On',...
        'PredictorNames', vNames); % 'Prior', 'Uniform'
    
    % % view for example decision tree nr. 1
    % view(MRandomForest.Trees{1},'Mode','graph');
    
    % Plot the predictor importance estimates
    figure;
    imp = MRandomForest.OOBPermutedPredictorDeltaError;
    bar(categorical(MRandomForest.PredictorNames), imp);
    ylabel('Predictor importance estimates');
    xlabel('Predictors');
    h = gca;
    h.XTickLabelRotation = 45;
    h.TickLabelInterpreter = 'none';
    
    % Plot the out-of-bag error over the number of grown classification trees
    figure;
    oobErrorBaggedEnsemble = oobError(MRandomForest);
    plot(oobErrorBaggedEnsemble)
    xlabel 'Number of grown trees';
    xlabel 'Anzahl Entscheidungsbäume';
    ylabel 'Out-of-bag classification error';
    
    % save trained ensemble
    if isempty(szMode)
        szMode = 'VD';
    end
    szFile = ['RandomForest_' num2str(nTrees) 'Trees_' szMode '_PredictorSet' num2str(nPredSet(n))];
    save([szDir filesep szFile], 'MRandomForest', 'szVarNames');
    
end

%% Test the ensemble of bagged classification trees
% create test data set
isTraining = false;
[mTestDataSet, vGroundTruthVS] = createTestSet(szVarNames, isTraining, szMode);
[mTestDataSet_GL, vGroundTruthVS_GL] = createTestSetDirect(szVarNames, isTraining, szMode);

% add data form gesture lab
mTestDataSet = [mTestDataSet; mTestDataSet_GL];
vGroundTruthVS = [vGroundTruthVS; vGroundTruthVS_GL];

% start prediction with trained ensemble of bagged classification trees
vPredictedVS = predict(MRandomForest, mTestDataSet);
vPredictedVS = str2num(cell2mat(vPredictedVS));

% display results as confusion matrix
if strcmp(szMode, 'OVD')
    vLabels = {'no OVS', 'OVS'};
elseif strcmp(szMode, 'FVD')
    vLabels = {'no FVS', 'FVS'};
else
    vLabels = {'no VS', 'OVS', 'FVS'};
end
plotConfusionMatrix([], vLabels, vGroundTruthVS, vPredictedVS)


function [szVarNames, vNames] = setPredictors(nPredSet)

switch nPredSet
    
    case 1
        szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'vGroundTruthVS'};
        vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1'; 'ZCRdiff2'};
        
    case 2
        szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'Pxx', 'vGroundTruthVS'};
        vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1';...
            'ZCRdiff2'; 'APSD1'; 'APSD2'; 'APSD3'; 'APSD4'; 'APSD5'; ...
            'APSD6'; 'APSD7'; 'APSD8'; 'APSD9'; 'APSD10'; 'APSD11'; 'APSD12'};
        
    case 3
        szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'Cxy', 'vGroundTruthVS'};
        vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1';...
            'ZCRdiff2'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; ...
            'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; 'CPSD12'};
    case 4
        szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'Cxy', 'mEQD', 'vGroundTruthVS'};
        vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1';...
            'ZCRdiff2'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; ...
            'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; ...
            'CPSD12'; 'EQD1'; 'EQD2'};
    case 5
        szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'Cxy', 'mEQD', 'mMeanSPP', 'mCorrRMS', 'vGroundTruthVS'};
        vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1';...
            'ZCRdiff2'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; ...
            'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; ...
            'CPSD12'; 'EQD1'; 'EQD2'; 'MeanSPP'; 'rms(Corr)'};
    case 6
        szVarNames = {'mMeanRealCoherence', 'mRMS', 'mZCR', 'Cxy', 'mEQD', 'mMeanSPP', 'mCorrRMS', 'mfcc', 'vGroundTruthVS'};
        vNames = {'Re(Cohe)'; 'RMS1'; 'RMS2'; 'ZCR1'; 'ZCR2'; 'ZCRdiff1';...
            'ZCRdiff2'; 'CPSD1'; 'CPSD2'; 'CPSD3'; 'CPSD4'; 'CPSD5'; ...
            'CPSD6'; 'CPSD7'; 'CPSD8'; 'CPSD9'; 'CPSD10'; 'CPSD11'; ...
            'CPSD12'; 'EQD1'; 'EQD2'; 'MeanSPP'; 'rms(Corr)'; 'MFCC1'; ...
            'MFCC2'; 'MFCC3'; 'MFCC4'; 'MFCC5'; 'MFCC6'; 'MFCC7'; ...
            'MFCC8'; 'MFCC9'; 'MFCC10'; 'MFCC11'; 'MFCC12'; 'MFCC13'};
end
end
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