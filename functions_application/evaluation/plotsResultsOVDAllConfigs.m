% Script to do something usefull (fill out)
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 06-Nov-2019 	JP

clear;
% close all;

% choose between data from Bilert or Schreiber or Pohlhausen
isBilert = 0;
isSchreiber = 0;

% path to main data folder (needs to be customized)
if isBilert
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
    
    % number of first and last noise configuration
    nConfig = [1; 6];
    
    % labels of all noise configurations
    vConfigLabels = {'Ruhe';'40 dB(A)';'50 dB(A)';'60 dB(A)';'65 dB(A)';'70 dB(A)'};
    
elseif isSchreiber
    obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
    
    % number of first and last noise configuration
    nConfig = [0; 7];
    
    % labels of all noise configurations
    vConfigLabels = {'friend';'car+friend';'car+friend';'kitchen';'conv.+music';'canteen';'silence';'canteen'};
    
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

% preallocate confusion matrix
mConfusion_fix = zeros(2,2);
mConfusion_Bilert = zeros(2,2);
mConfusion_Schreiber = zeros(2,2);

% loop over all noise configurations
for config = nConfig(1):nConfig(2)
    % choose noise configurations
    obj.szNoiseConfig = ['config' num2str(config)];
    
    StartIdx = ones(3,1);
    % loop over all subjects
    for subj = 1:nSubject
        
        % choose one subject directoy
        obj.szCurrentFolder = subjectDirectories(subj).name;
        
        % load analysed data
        szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
        szFile = ['Results_OVD_FVD_' obj.szCurrentFolder];
        
        if exist([szDir filesep szFile '.mat'], 'file')
            load([szDir filesep szFile], 'stResults');
            
            mConfusion_fix = mConfusion_fix + stResults.mConfusion_fix;
            mConfusion_Bilert = mConfusion_Bilert + stResults.mConfusion_Bilert;
            mConfusion_Schreiber = mConfusion_Schreiber + stResults.mConfusion_Schreiber;
            
        end
    end
end

% call function to plot confusion matrix for all subjects and configs
vLabels = {'OVS', 'no OVS'};
plotConfusionMatrix(mConfusion_fix, vLabels, 'Bitzer et al. 2016');
plotConfusionMatrix(mConfusion_Bilert, vLabels, 'Bilert 2018');
plotConfusionMatrix(mConfusion_Schreiber, vLabels, 'Schreiber 2019');

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