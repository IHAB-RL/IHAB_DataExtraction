% Script to test random forests
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 14-Nov-2019 	JP

clear;

%% get some data
obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

% choose one subject directoy
obj.szCurrentFolder = 'EL10AN18';

% number of first and last noise configuration
nConfig = [1; 6];

StartIdx = 1;
% loop over all noise configurations
for config = 4:nConfig(2)

    % choose noise/ measurement configuration
    obj.szNoiseConfig = ['config' num2str(config)];

    % build the full directory
    obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];

    % select audio file
    obj.audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);

    % call funtion to calculate PSDs
    stData = detectOVSRealCoherence([], obj);

    % current number of time frames
    nBlocks = size(stData.vCohMeanReal, 2);

    % re-assign values
    vCohMeanReal(StartIdx:StartIdx+nBlocks-1, 1) = stData.vCohMeanReal';
    mRMS(StartIdx:StartIdx+nBlocks-1, 1) = stData.mRMS(:,1);
%     Pxx(StartIdx:StartIdx+nBlocks-1) = stData.Pxx;
%     Pyy(StartIdx:StartIdx+nBlocks-1) = stData.Pyy;

    % weight real CPSD and build sum over all frequencies
    Cxy = real(stData.Cxy)';
    [Cxy_Weighted] = weightingFrequency(Cxy, stData.fs, stData.nFFT/2+1);
    mCPSD(StartIdx:StartIdx+nBlocks-1, 1) = sum(Cxy_Weighted, 2);

    % calculate correlation of CPSD with hannwin combs
    correlation = CalcCorrelation(Cxy, stData.fs, stData.nFFT/2+1);
    % find peaks in the correlation matrix
    basefrequencies = logspace(log10(50),log10(450),200);
    PeaksCorr(StartIdx:StartIdx+nBlocks-1, :) = DeterminePeaksCorrelation(correlation, basefrequencies, nBlocks);
    
    % duration one frame in sec
    nLenFrame = stData.tFrame;

    % get ground truth labels for voice activity
    obj.fsVD = 1/nLenFrame;
    obj.NrOfBlocks = nBlocks;
    [groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
    groundTrFVS = 2*groundTrFVS; % set label for fvs to 2
    
    % combine OV and FV labels
    vGroundTruthVS = groundTrOVS; % first ovs
    % at no ovs look for fvs
    vGroundTruthVS(vGroundTruthVS == 0) = groundTrFVS(vGroundTruthVS == 0); 
%     % at ovs look for additional fvs
%     groundTrVS(groundTrVS == 1 & groundTrFVS == 2) = 3;
    vVoiceLabels(StartIdx:StartIdx+nBlocks-1, 1) = vGroundTruthVS;
    
    % adjust index
    StartIdx = StartIdx + nBlocks;
    
    figure;plot(PeaksCorr(:,1)); hold on;plot(groundTrOVS,'r');
end


% create training data set
mDataSet = [vCohMeanReal, mRMS, mCPSD, PeaksCorr];
vNames = {'Re(Cohe)'; 'RMS'; 'CPSD'; 'PH1'; 'PH2'; 'PH3'};

% set number of trees
nTrees = 50;

%% Train an ensemble of bagged classification trees using the entire data set.
tic
Mdl = TreeBagger(nTrees, mDataSet, vVoiceLabels, 'OOBPrediction', 'On',...
    'Method', 'classification', 'OOBPredictorImportance', 'On',...
    'PredictorNames', vNames); % 'Prior', 'Uniform'
toc
% % view decision tree
% view(Mdl.Trees{1},'Mode','graph');

% TreeBagger stores predictor importance estimates in the property
% OOBPermutedPredictorDeltaError. Compare the estimates using a bar graph.
imp = Mdl.OOBPermutedPredictorDeltaError;

figure;
bar(imp);
ylabel('Predictor importance estimates');
xlabel('Predictors');
h = gca;
h.XTickLabel = Mdl.PredictorNames;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

% Plot the out-of-bag error over the number of grown classification trees.
figure;
oobErrorBaggedEnsemble = oobError(Mdl);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';


%% test random forest with new subject
obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';

% choose one subject directoy
obj.szCurrentFolder = 'NN08IA10';

% choose noise/ measurement configuration
obj.szNoiseConfig = 'config3';

% build the full directory
obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
            
% select audio file
obj.audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
            
% call funtion to calculate PSDs
stData = detectOVSRealCoherence([], obj);

% current number of time frames
nBlocks = size(stData.vCohMeanReal, 2);

% re-assign values
vCohMeanReal = stData.vCohMeanReal';
mRMS = stData.mRMS(:,1);

% weight real CPSD and build sum over all frequencies
Cxy = real(stData.Cxy)';
[Cxy_Weighted] = weightingFrequency(Cxy, stData.fs, stData.nFFT/2+1);
mCPSD = sum(Cxy_Weighted, 2);

% calculate correlation of CPSD with hannwin combs
correlation = CalcCorrelation(Cxy, stData.fs, stData.nFFT/2+1);
% find peaks in the correlation matrix
basefrequencies = logspace(log10(50),log10(450),200);
PeaksCorr = DeterminePeaksCorrelation(correlation, basefrequencies, nBlocks);

% get ground truth labels for voice activity
obj.fsVD = 1/nLenFrame;
obj.NrOfBlocks = nBlocks;
[groundTrOVS, groundTrFVS] = getVoiceLabels(obj);
groundTrFVS = 2*groundTrFVS; % set label for fvs to 2

% combine OV and FV labels
vGroundTruthVS = groundTrOVS; % first ovs
% at no ovs look for fvs
vGroundTruthVS(vGroundTruthVS == 0) = groundTrFVS(vGroundTruthVS == 0); 
% % at ovs look for additional fvs
% groundTrVS(groundTrVS == 1 & groundTrFVS == 2) = 3;

% create test data set
mTestDataSet = [vCohMeanReal, mRMS, mCPSD, PeaksCorr];

% start prediction with trained ensemble of bagged classification trees
vPredictedVS = predict(Mdl, mTestDataSet);
vPredictedVS = str2num(cell2mat(vPredictedVS));

% display results as confusion matrix
vLabels = {'no VS', 'OVS', 'FVS'};
plotConfusionMatrix([], vLabels, vGroundTruthVS', vPredictedVS)

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