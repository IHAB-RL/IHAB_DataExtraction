% Script to compare the results scores for OVD
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% run first: plotResultsOVD_TestData.m
% Version History:
% Ver. 0.01 initial create (empty) 26-Nov-2019 	JP

clear;

% path to data
szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Results';

% list algorithms for comparison
szCondition = {'OVD_Bitzer2016_'; 'OVD_Bilert2018_'; 'OVD_Schreiber2019_'; 'OVD_RandomForest_'};

for cond = 1:length(szCondition)
    % construct desired filename
    szFile = ['ResultScores_' szCondition{cond} 'TestDataRF'];

    % load results from matfile
    load([szDir filesep szFile], 'mF2Score', 'mPrecision', 'mRecall', 'mAccuracy');
    
    F2Score(:, cond) = mF2Score;
    Precision(:, cond) = mPrecision;
    Recall(:, cond) = mRecall;
    Accuracy(:, cond) = mAccuracy;
end

% adjust condition names
szCondition = strrep(szCondition, '_', '');
szCondition = strrep(szCondition, 'OVD', '');

% plot result scores
figure;
subplot(1,4,1);
boxplot(F2Score, 'Labels', szCondition);
ylim([0 1]);
ylabel('F_2-Score');

subplot(1,4,2);
boxplot(Precision, 'Labels', szCondition);
ylim([0 1]);
ylabel('Precision');

subplot(1,4,3);
boxplot(Recall, 'Labels', szCondition);
ylim([0 1]);
ylabel('Recall');

subplot(1,4,4);
boxplot(Accuracy, 'Labels', szCondition);
ylim([0 1]);
ylabel('Accuracy');

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