% Script to plot the results of OVD
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 05-Nov-2019 	JP

clear;
% close all;

% choose between data from Bilert or Pohlhausen
isBilert = 0;

% path to main data folder (needs to be customized)
if isBilert
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
    
    % number of first and last noise configuration
    nConfig = [1; 6];
    
    % labels of all noise configurations
    vConfigLabels = {'Ruhe';'40 dB(A)';'50 dB(A)';'60 dB(A)';'65 dB(A)';'70 dB(A)'};
    
else
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
    
    % number of first and last noise configuration
    nConfig = [1; 3];
    
    % labels of all noise configurations
    vConfigLabels = {'office';'canteen';'by foot'};
    
end

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% number of subjects
nSubject = size(subjectDirectories, 1);

% select parameter condition
% szCondition = 'OVD_Schreiber_Min03_';
% szCondition = 'OVD_Cohe_Min03_rmsCorr_movmean';
szCondition = 'OVD_Schreiber_Pitch_rmsCorr_';

% preallocate result vectors
F2OVS = NaN(nSubject, nConfig(2));
precOVS = NaN(nSubject, nConfig(2));
recOVS = NaN(nSubject, nConfig(2));
mConfusion = zeros(2,2);

idx = 1;
% loop over all subjects
for subj = 1:nSubject
    
    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(subj).name;
    
    % build the full directory
    szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep 'Pitch' filesep 'OVDPitchMatFiles'];
    
    % loop over all noise configurations
    for config = nConfig(1):nConfig(2)
        
        % choose noise configurations
        obj.szNoiseConfig = ['config' num2str(config)];
        
        % construct name of desired matfile
        szFile = [szCondition obj.szCurrentFolder '_'  obj.szNoiseConfig '.mat'];
        
        if exist([szDir filesep szFile])
            load([szDir filesep szFile], 'stResults');
            
            % store results
            F2OVS(subj, config)   = stResults.F2ScoreOVS_Pitch;
            precOVS(subj, config) = stResults.precOVS_Pitch;
            recOVS(subj, config)  = stResults.recOVS_Pitch;
            mConfusion = mConfusion + stResults.mConfusion_Pitch;
        end
    end
end


hFig1 = figure;
% F2 score
subplot(1,3,1);
if isBilert
    boxplot(F2OVS,'Labels',vConfigLabels,'Whisker', 1);
    title('F_2-Score OVD with Pitch PROBAND');
else
    bar(categorical(vConfigLabels), F2OVS);
    title('F_2-Score OVD with Pitch JP');
end
xlabel('noise level');
ylabel('F_2-Score');
ylim([0 1]);

% precision
subplot(1,3,2);
if isBilert
    boxplot(precOVS,'Labels',vConfigLabels,'Whisker', 1);
    title('precision OVD with Pitch PROBAND');
else
    bar(categorical(vConfigLabels), precOVS);
    title('precision OVD with Pitch JP');
end
xlabel('noise level');
ylabel('precision OVS');
ylim([0 1]);

% recall
subplot(1,3,3);
if isBilert
    boxplot(recOVS,'Labels',vConfigLabels,'Whisker', 1);
    title('recall OVD with Pitch PROBAND');
else
    bar(categorical(vConfigLabels), recOVS);
    title('recall OVD with Pitch JP');
end
xlabel('noise level');
ylabel('recall OVS');
ylim([0 1]);


% call function to plot confusion matrix for all subjects and configs
vLabels = {'OVS', 'no OVS'};
hFig2 = plotConfusionMatrix(mConfusion, vLabels, strrep(szCondition,'_',' '));


% logical to save figure
bPrint = 1;
if bPrint
    szDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\Pitch\Results';
    
    if strcmp(szCondition(end), '_') 
        szCondition = szCondition(1:end-1);
    end
    if ~isBilert
        szCondition = [szCondition '_JP'];
    end
    
    exportName1 = [szDir filesep 'Results_' szCondition];
    
    savefig(hFig1, exportName1);
    
    exportName2 = [szDir filesep 'ConfMatrix_' szCondition];
    
    savefig(hFig2, exportName2);
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