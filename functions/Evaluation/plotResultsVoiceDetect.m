function []=plotResultsVoiceDetect(stDATA, subj, config, probIDIHABnoise, noiseLabel, FVDFlag)
% function to do something usefull (fill out)
% Usage [outParam]=plotResultsVoiceDetect(inParam)
%
% Parameters
% ----------
% inParam : stDATA, subj, config, probIDIHABnoise, noiseLabel, FVSFlag
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Source: If the function is based on a scientific paper or a web site, 
%         provide the citation detail here (with equation no. if applicable)  
% Version History:
% Ver. 0.01 initial create 12-Sep-2019  JP

% preallocation of result matrices
precOVS_fix = zeros(subj,config);
recOVS_fix = zeros(subj,config);
precOVS_Bilert = zeros(subj,config);
recOVS_Bilert = zeros(subj,config);
precOVS_Schreiber = zeros(subj,config);
recOVS_Schreiber = zeros(subj,config);
precFVS = zeros(subj,config);
recFVS = zeros(subj,config);

for subj = 1:length(probIDIHABnoise)
    precOVS_fix(subj,:) = stDATA(subj).results.precOVS_fix;
    recOVS_fix(subj,:) = stDATA(subj).results.recOVS_fix;
    precOVS_Bilert(subj,:) = stDATA(subj).results.precOVS_Bilert;
    recOVS_Bilert(subj,:) = stDATA(subj).results.recOVS_Bilert;
    precOVS_Schreiber(subj,:) = stDATA(subj).results.precOVS_Schreiber;
    recOVS_Schreiber(subj,:) = stDATA(subj).results.recOVS_Schreiber;
    precFVS(subj,:) = stDATA(subj).results.precFVS;
    recFVS(subj,:) = stDATA(subj).results.recFVS;
end


%% OVD
% calculate F2 score
fBeta = 2; % weighting factor
[F2Score.fix,~,~] = F1M([], [], fBeta, precOVS_fix, recOVS_fix);
[F2Score.Bilert,~,~] = F1M([], [], fBeta, precOVS_Bilert, recOVS_Bilert);
[F2Score.Schreiber,~,~] = F1M([], [], fBeta, precOVS_Schreiber, recOVS_Schreiber);
GroupedBoxplot(F2Score.fix(:), F2Score.Bilert(:), F2Score.Schreiber(:), [size(precOVS_fix)]);
title(['F_2-Score OVD PROBAND (N=' num2str(subj) ')']);
xlabel('noise level');
ylabel('F_2-Score');

% precision
GroupedBoxplot(precOVS_fix(:), precOVS_Bilert(:), precOVS_Schreiber(:), [size(precOVS_fix)]);
title(['precision OVD PROBAND (N=' num2str(subj) ')']);
xlabel('noise level');
ylabel('precision OVS');

% recall
GroupedBoxplot(recOVS_fix(:), recOVS_Bilert(:), recOVS_Schreiber(:), [size(precOVS_fix)]);
title(['recall OVD (N=' num2str(subj) ')']);
xlabel('noise level');
ylabel('recall OVS');


%% FVD
if FVDFlag
    f1 = figure; 
    f1.Position = [400 300 1100 700];
    subplot(2,1,1);
    boxplot(precFVS,'Labels',noiseLabel,'Whisker',1);
    ylim([0 1]);
    title(['precision FVD PROBAND (N=' num2str(subj) ')']);
    xlabel('noise level');
    ylabel('precision FVS');
    
    subplot(2,1,2);
    boxplot(recFVS,'Labels',noiseLabel,'Whisker',1);
    ylim([0 1]);
    title(['recall FVD PROBAND (N=' num2str(subj) ')']);
    xlabel('noise level');
    ylabel('recall FVS');
end
 

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