% script to analyse the distribution of peaks in the correlation (magnitude
% feature by Basti Bechtold)
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 04-Nov-2019  JP
% Ver. 0.1 add locs 06-Nov-2019  JP

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
    vLabels = {'Ruhe';'40 dB(A)';'50 dB(A)';'60 dB(A)';'65 dB(A)';'70 dB(A)'};
    
    % define maximum number of blocks
    nBlocksMax = 5*60/0.125; % 5 minutes recorded frames a 0.125 ms
    
elseif isSchreiber
    obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
    
    % number of first and last noise configuration
    nConfig = [0; 7];
    
    % labels of all noise configurations
    vLabels = {'friend';'car+friend';'car+friend';'kitchen';'conv.+music';'canteen';'silence';'canteen'};
    
    % define maximum number of blocks
    nBlocksMax = 25*60/0.125; % 25 minutes recorded frames a 0.125 ms
else
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
    
    % number of first and last noise configuration
    nConfig = [1; 3];
    
    % labels of all noise configurations
    vLabels = {'office';'canteen';'by foot'};
    
    % define maximum number of blocks
    nBlocksMax = 25*60/0.125; % 25 minutes recorded frames a 0.125 ms
    
end

% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% number of subjects
nSubject = size(subjectDirectories, 1);

% preallocate result matrix
nValuesMax = nSubject * nBlocksMax;
mPeaksOVS = NaN(nValuesMax, nConfig(2));
mPeaksFVS = NaN(nValuesMax, nConfig(2));
mPeaksNone = NaN(nValuesMax, nConfig(2));

nCountVS = zeros(nConfig(2), nSubject, 3);
nCountPeaks = zeros(nConfig(2), nSubject, 3, 3);

nHarmRatio12 = NaN(nValuesMax, nConfig(2), 3);
nHarmRatio13 = NaN(nValuesMax, nConfig(2), 3);

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
        szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep 'Pitch' filesep 'PeaksMatFiles'];
        szFile = ['PeaksLocs_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
        
        if exist([szDir filesep szFile '.mat'], 'file')
            load([szDir filesep szFile], 'peaksOVS', 'peaksFVS', 'peaksNone', 'locs');
            
            % count number of specific voice sequences
            nCountVS(config, subj, 1) = size(peaksOVS,1);
            nCountVS(config, subj, 2) = size(peaksFVS,1);
            nCountVS(config, subj, 3) = size(peaksNone,1);
            
            % count number of no NaNs in peak vector
            nCountPeaks(config, subj, 1, :) = sum(~isnan(peaksOVS));
            nCountPeaks(config, subj, 2, :) = sum(~isnan(peaksFVS));
            nCountPeaks(config, subj, 3, :) = sum(~isnan(peaksNone));
            
            % construct matrix with pooled data
            mPeaksOVS(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config) = peaksOVS(:, 1);
            mPeaksFVS(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config) = peaksFVS(:, 1);
            mPeaksNone(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config) = peaksNone(:, 1);
            
            % load voice labels
            szVoiceFile = ['VoiceLabels_' obj.szCurrentFolder '_'  obj.szNoiseConfig];
            szVoiceFile = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig filesep szVoiceFile];
            load(szVoiceFile, 'idxTrOVS', 'idxTrFVS', 'idxTrNone');
            
            % index voice sequences
            locsOVS = locs(idxTrOVS, :);
            locsFVS = locs(idxTrFVS, :);
            locsNone = locs(idxTrNone, :);
            
            % calculate harmonic ratio of the frequencies at the highest
            % and second highest peak
            nHarmRatio12(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config, 1) = locsOVS(:, 1)./locsOVS(:, 2);
            nHarmRatio12(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config, 2) = locsFVS(:, 1)./locsFVS(:, 2);
            nHarmRatio12(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config, 3) = locsNone(:, 1)./locsNone(:, 2);
            
            % calculate harmonic ratio of the frequencies at the highest
            % and third highest peak
            nHarmRatio13(StartIdx(1):StartIdx(1)+nCountVS(config, subj, 1)-1, config, 1) = locsOVS(:, 1)./locsOVS(:, 3);
            nHarmRatio13(StartIdx(2):StartIdx(2)+nCountVS(config, subj, 2)-1, config, 2) = locsFVS(:, 1)./locsFVS(:, 3);
            nHarmRatio13(StartIdx(3):StartIdx(3)+nCountVS(config, subj, 3)-1, config, 3) = locsNone(:, 1)./locsNone(:, 3);
            
            % adjust index
            StartIdx(1) = StartIdx(1) + nCountVS(config, subj, 1);
            StartIdx(2) = StartIdx(2) + nCountVS(config, subj, 2);
            StartIdx(3) = StartIdx(3) + nCountVS(config, subj, 3);
            
            clear peaksOVS peaksFVS peaksNone locsOVS locsFVS locsNone locs
        end
    end
    
end

% get maximum of number of peak values
nPeakValues = max(max(sum(nCountVS(:, :, :), 2)));

% adjust peak vectors to one length
mPeaksOVS(nPeakValues+1:end, :) = [];
mPeaksFVS(nPeakValues+1:end, :) = [];
mPeaksNone(nPeakValues+1:end, :) = [];


% %% GroupedBoxplot(mPeaksOVS, mPeaksFVS, mPeaksNone, [nPeakValues config])
% hFig = figure;
% subplot(1,3,1);
% boxplot(mPeaksOVS,'Labels',vLabels, 'Colors', 'r','Whisker', 1);
% title('Peak Height at OVS');
% xlabel('noise configuration');
% ylabel('Peak Height F^M_t(f_0)');
% ylim([0 100]);
% 
% subplot(1,3,2);
% boxplot(mPeaksFVS,'Labels',vLabels, 'Colors', 'b','Whisker', 1);
% title('Peak Height at FVS');
% xlabel('noise configuration');
% ylabel('Peak Height F^M_t(f_0)');
% ylim([0 100]);
% 
% subplot(1,3,3);
% boxplot(mPeaksNone,'Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% title('Peak Height at no VS');
% xlabel('noise configuration');
% ylabel('Peak Height F^M_t(f_0)');
% ylim([0 100]);


%% display distribution
% vMarkers = {'+', 'o', '*', 'x', 's', 'v'};
% hold on;
% xbins = 0:5:200;
% for config = nConfig(1):nConfig(2)
%     [counts(config,:),centers] = hist(mPeaksOVS(:,config), xbins);
% end
% [hPatch, width] = plotBarOverlay(counts', centers, vLabels);
% xlim([centers(1)-width  centers(end)+width]);
% title('Distribution Peak Height at OVS');
% xlabel('Peak Height F^M_t(f_0)');
% ylabel('number of occurrence');

% 
% %% calculate and plot results of NaN/ Peak detection
% nCountPeakRel = 100*nCountPeaks./nCountVS; % relative values in %
% hFig = figure;
% % ovs
% subplot(3,3,1);
% if isBilert
%     boxplot(nCountPeakRel(:,:,1,1)','Labels',vLabels, 'Colors', 'r','Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,1,1)','r');
% end
% title('at least 1 Peak at OVS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% subplot(3,3,4);
% if isBilert
%     boxplot(nCountPeakRel(:,:,1,2)','Labels',vLabels, 'Colors', 'r','Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,1,2)','r');
% end
% title('at least 2 Peaks at OVS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% subplot(3,3,7);
% if isBilert
%     boxplot(nCountPeakRel(:,:,1,3)','Labels',vLabels, 'Colors', 'r','Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,1,3)','r');
% end
% title('3 Peaks at OVS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% 
% % fvs
% subplot(3,3,2);
% if isBilert
%     boxplot(nCountPeakRel(:,:,2,1)','Labels',vLabels, 'Colors', 'b','Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,2,1)','b');
% end
% title('at least 1 Peak at FVS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% subplot(3,3,5);
% if isBilert
%     boxplot(nCountPeakRel(:,:,2,2)','Labels',vLabels, 'Colors', 'b','Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,2,2)','b');
% end
% title('at least 2 Peaks at FVS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% subplot(3,3,8);
% if isBilert
%     boxplot(nCountPeakRel(:,:,2,3)','Labels',vLabels, 'Colors', 'b','Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,2,3)','b');
% end
% title('3 Peaks at FVS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% 
% % no vs
% subplot(3,3,3);
% if isBilert
%     boxplot(nCountPeakRel(:,:,3,1)','Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,3,1)', 'FaceColor', [0 0.6 0.2]);
% end
% title('at least 1 Peak at no VS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% subplot(3,3,6);
% if isBilert
%     boxplot(nCountPeakRel(:,:,3,2)','Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,3,2)', 'FaceColor', [0 0.6 0.2]);
% end
% title('at least 2 Peaks at no VS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);
% subplot(3,3,9);
% if isBilert
%     boxplot(nCountPeakRel(:,:,3,3)','Labels',vLabels, 'Colors', [0 0.6 0.2],'Whisker', 1);
% else
%     bar(categorical(vLabels), nCountPeakRel(:,:,3,3)', 'FaceColor', [0 0.6 0.2]);
% end
% title('3 Peaks at no VS');
% xlabel('noise configuration');
% ylabel('relative occurrence in %');
% ylim([0 100]);


%% plot results harmonic ratio
hFig2 = figure;
subplot(2,3,1);
violinplot(nHarmRatio12(:,:,1),vLabels,'ViolinColor',[1 0 0]);
title('Ratio 1. to 2. highest Peak at OVS');
xlabel('noise configuration');
ylabel('Ratio 1. to 2. highest Peak');
ylim([0 10]);

subplot(2,3,2);
violinplot(nHarmRatio12(:,:,2),vLabels,'ViolinColor',[0 0 1]);
title('Ratio 1. to 2. highest Peak at FVS');
xlabel('noise configuration');
ylabel('Ratio 1. to 2. highest Peak');
ylim([0 10]);

subplot(2,3,3);
violinplot(nHarmRatio12(:,:,3),vLabels,'ViolinColor',[0 0.6 0.2]);
title('Ratio 1. to 2. highest Peak at no VS');
xlabel('noise configuration');
ylabel('Ratio 1. to 2. highest Peak');
ylim([0 10]);

subplot(2,3,4);
violinplot(nHarmRatio13(:,:,1),vLabels,'ViolinColor',[1 0 0]);
title('Ratio 1. to 3. highest Peak at OVS');
xlabel('noise configuration');
ylabel('Ratio 1. to 3. highest Peak');
ylim([0 10]);

subplot(2,3,5);
violinplot(nHarmRatio13(:,:,2),vLabels,'ViolinColor',[0 0 1]);
title('Ratio 1. to 3. highest Peak at FVS');
xlabel('noise configuration');
ylabel('Ratio 1. to 3. highest Peak');
ylim([0 10]);

subplot(2,3,6);
violinplot(nHarmRatio13(:,:,3),vLabels,'ViolinColor',[0 0.6 0.2]);
title('Ratio 1. to 3. highest Peak at no VS');
xlabel('noise configuration');
ylabel('Ratio 1. to 3. highest Peak');
ylim([0 10]);

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