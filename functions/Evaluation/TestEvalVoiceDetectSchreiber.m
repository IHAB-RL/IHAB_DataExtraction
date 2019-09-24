% test script to evaluate the Own Voice Detection (OVD) and Futher Voice
% Detection (FVD) by Nils Schreiber (Master 2019)
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
%
% contains mainTest.m and main.m by Nils Schreiber (IHAB_DB)
% make use of recordings from Sascha Bilert (Bachelor 2018):
%   measurements of 8 subjects in quiet and 5 different surroundig
%   cafeteria noise levels [40, 50, 60, 65, 70 dB(A)] talking about Diapix
% ground truth ovs are labeled with 0 (Schreiber) or not (Bilert used to
% label ovs with increasing numbers >=1, i.e. counting ovs)
% ground truth fvs are labeled with 1, 2, 3 (Schreiber) dependent on the
% number of voices or with 0 (Jule)
%
% Version History:
% Ver. 0.01 initial create 10-Sep-2019 	JP


clear;
% close all;

% set path to data folder (needs to be customized)
dataPath = 'K:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data';

% used smartphone measurement system
system = 'IHAB';

% choose measurement set PROBAND
folder = 'PROBAND';

dataPath = fullfile(dataPath, system, folder);

% labels for the 6 different noise levels
configNoise = [1 2 3 4 5 6];
noiseLabel = {'quiet','40 dB(A)','50 dB(A)','60 dB(A)','65 dB(A)','70 dB(A)'};

% subject IDs
probIDIHABnoise = {'EL10AN18'; 'ER06NG15'; 'ER06RL07'; 'ER09LD07'; 'KI07NS22'; 'PP06NG14'; 'TA05TH13'; 'TZ06ES18'};

% flag whether to use ground truth data
gtFlag = 1;

% flag whether to analyse FVD
FVDFlag = 1;

% choose calculation based on audio or features
mode = 'audio'; %'features'; %

% specify subjects that have stored feature data
if strcmp(mode,'features')
    probIDIHABnoise = {'EL10AN18'; 'ER06NG15'; 'ER06RL07'; 'TZ06ES18'};
end

% preallocation of the result struct
stDATA = struct('subject', [], 'results', [], 'mConfusion', []);
pre = 2*ones(size(configNoise));
stResults = struct('config',configNoise,'precOVS_fix',pre,'recOVS_fix',pre,...
    'precOVS_Bilert',pre,'recOVS_Bilert',pre,'precOVS_Schreiber',pre,'recOVS_Schreiber',pre,'precFVS',pre,'recFVS',pre);

% loop for each subject over all noise configurations
for subj = 1:length(probIDIHABnoise)
    stDATA(subj).subject = probIDIHABnoise{subj};
    stDATA(subj).mConfusion_fix = zeros(2,2);
    stDATA(subj).mConfusion_Bilert = zeros(2,2);
    stDATA(subj).mConfusion_Schreiber = zeros(2,2);
    
    for config = 1:length(configNoise)
        
        [stResultsProb] = EvalVoiceDetectSchreiber(dataPath, probIDIHABnoise{subj}, configNoise(config), gtFlag, FVDFlag, mode);
        
        stResults.precOVS_fix(config) = stResultsProb.precOVS_fix;
        stResults.recOVS_fix(config) = stResultsProb.recOVS_fix;
        stResults.precOVS_Bilert(config) = stResultsProb.precOVS_Bilert;
        stResults.recOVS_Bilert(config) = stResultsProb.recOVS_Bilert;
        stResults.precOVS_Schreiber(config) = stResultsProb.precOVS_Schreiber;
        stResults.recOVS_Schreiber(config) = stResultsProb.recOVS_Schreiber;
        stResults.precFVS(config) = stResultsProb.precFVS;
        stResults.recFVS(config) = stResultsProb.recFVS;
        
        stDATA(subj).results = stResults;
        
        stDATA(subj).mConfusion_fix = stDATA(subj).mConfusion_fix + stResultsProb.mConfusion_fix;
        stDATA(subj).mConfusion_Bilert = stDATA(subj).mConfusion_Bilert + stResultsProb.mConfusion_Bilert;
        stDATA(subj).mConfusion_Schreiber = stDATA(subj).mConfusion_Schreiber + stResultsProb.mConfusion_Schreiber;
    end
end

% save results as mat file
save('Results_OVD_FVD_123456config_8Prob_feat_mConfusion', 'stDATA');


% load('Results_OVD_123456config_8Prob_VGL.mat');
% subj = length(probIDIHABnoise);
% config = length(configNoise);

% call function to plot results (F2-Score, precision, recall)
plotResultsVoiceDetect(stDATA, subj, config, probIDIHABnoise, noiseLabel, FVDFlag);

% call function to plot confusion matrix
mConfusion_fix = zeros(2,2);
mConfusion_Bilert = zeros(2,2);
mConfusion_Schreiber = zeros(2,2);
for subj = 1:length(probIDIHABnoise)
    mConfusion_fix = mConfusion_fix + stDATA(subj).mConfusion_fix;
    mConfusion_Bilert = mConfusion_Bilert + stDATA(subj).mConfusion_Bilert;
    mConfusion_Schreiber = mConfusion_Schreiber + stDATA(subj).mConfusion_Schreiber;
end
vLabels = {'OVS', 'no OVS'};
plotConfusionMatrix(mConfusion_fix, vLabels);
plotConfusionMatrix(mConfusion_Bilert, vLabels);
plotConfusionMatrix(mConfusion_Schreiber, vLabels);

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

% eof