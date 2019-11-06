% test script to loop over several parameters, e.g. number of subjects or
% number of noise/ measurement configuration
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 22-Oct-2019  JP
% Ver. 0.1 just for subject data 23-Oct-2019 JP
% Ver. 0.2 generalized loop function 05-Nov-2019 JP

clear;
close all;

% choose between data from Bilert or Schreiber or Pohlhausen
isBilert = 0;
isSchreiber = 0;

% path to main data folder (needs to be customized)
if isBilert
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';
    
    % number of first and last noise configuration
    nConfig = [1; 6];
elseif isSchreiber
    obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
    
    % number of first and last noise configuration
    nConfig = [0; 7];
else
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019';
    
    % number of first and last noise configuration
    nConfig = [1; 3];
end
 
% get all subject directories
subjectDirectories = dir(obj.szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 8), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% number of subjects
nSubject = size(subjectDirectories, 1);


% loop over all subjects
for subj = 1:nSubject
    
    % choose one subject directoy
    obj.szCurrentFolder = subjectDirectories(subj).name;
    
    % loop over all noise configurations
    for config = nConfig(1):nConfig(2)
        % choose noise configurations
        obj.szNoiseConfig = ['config' num2str(config)];
        
        % build the full directory
        obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig]; 
        
        % select audio file
        obj.audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
        
        % function call
%         PitchBechtold(obj);
%         CalcCorrelationTest(obj);
%         AnalysePeaksCorrelation(obj);
%         SaveVoiceLabels(obj)
        EvaluatePerformanceOVDPitch(obj);
        
        close all;
    end
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