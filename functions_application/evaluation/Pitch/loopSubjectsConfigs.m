% test script to loop over several parameters, e.g. number of subjects or
% number of noise/ measurement configuration
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 22-Oct-2019  JP
% Ver. 0.1 just for subject data 23-Oct-2019 JP
% Ver. 0.2 generalized loop function 05-Nov-2019 JP

clear;
% close all;

% choose between data from Bilert or Schreiber or Pohlhausen
isBilert = 1;
isOutdoor = 1;
isSchreiber = 0;

% path to main data folder (needs to be customized)
if isBilert
    obj.szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB';
    
    if isOutdoor
        obj.szBaseDir = [obj.szBaseDir filesep 'OUTDOOR'];
        
        % list of measurement configurations
        nConfig = [1; 4];
        vConfig = {'CAR'; 'CITY'; 'COFFEE'; 'STREET'};
        
    else
        obj.szBaseDir = [obj.szBaseDir filesep 'PROBAND'];
        
        % number of first and last noise configuration
        nConfig = [1; 6];
    end
    
elseif isSchreiber
    obj.szBaseDir = 'I:\IHAB_DB\OVD_nils';
    
    % number of first and last noise configuration
    nConfig = [1; 6];
    
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
isDirectory = arrayfun(@(x)(x.isdir == 1), subjectDirectories);
subjectDirectories = subjectDirectories(isDirectory);

% number of subjects
nSubject = max(size(subjectDirectories, 1), 1);


% loop over all subjects
for subj = 1:nSubject
    
    % choose one subject directoy
    if ~isempty(subjectDirectories)
        obj.szCurrentFolder = subjectDirectories(subj).name;
    end
    
    % loop over all noise configurations
    for config = nConfig(1):nConfig(2)
        
        if isOutdoor
            % choose measurement configuration
            obj.szNoiseConfig = vConfig{config};
            
            % build the full directory
            obj.szDir = [obj.szBaseDir filesep obj.szNoiseConfig];
            
            % select audio file
            obj.audiofile = fullfile(obj.szDir, ['IHAB_' obj.szNoiseConfig '.wav']);
        else
            % choose noise/ measurement configuration
            obj.szNoiseConfig = ['config' num2str(config)];
            
            % build the full directory
            obj.szDir = [obj.szBaseDir filesep obj.szCurrentFolder filesep obj.szNoiseConfig];
            
            % select audio file
            obj.audiofile = fullfile(obj.szDir, [obj.szCurrentFolder '_' obj.szNoiseConfig '.wav']);
        end
        
        % function call
        
        % PitchBechtold(obj);
        % CalcCorrelationTest(obj);
        % AnalysePeaksCorrelation(obj);
        % SaveVoiceLabels(obj)
        % EvaluatePerformanceOVDPitch(obj);
        % plotPROBANDData(obj);
        % plotFingerprintAnalysis(obj)
        
        FeatureExtractionTestSet(obj)
        
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