% Script to get the feature files of the last approx. 30 min of EMA with 
% conversation (maybe)
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 24-Sep-2019 	JP
% based on: getObjectiveDataOneDay.m

clear;
% close all;
clc;

% path to data folder (needs to be customized)
szBaseDir = 'K:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% preallocate result struct
stFilesLastDay = struct('subjectDir', [], 'featFiles', [], 'endTime', []);

% set counter for invalid folder names
counterInvalid = 0;

for subj = 1:size(subjectDirectories,1)
    % get one subject directoy
    szCurrentFolder = subjectDirectories(subj).name;
    
    % check if current subject folder contains valid data
    if size(szCurrentFolder,2) == 18
        
        % check if the test person exist
        stSubject = getsubject(szBaseDir, szCurrentFolder);
        
        % build the full directory with feature data
        szSubjectDir = [szBaseDir filesep szCurrentFolder filesep stSubject.SubjectID '_AkuData'];
        
        % get all PSD feature files
        featData = dir([szSubjectDir filesep 'PSD*.feat']);
        featFiles = {featData.name}';
        
        % get the dates of the feature files
        [dateVecAll,~] = Filename2date(featFiles,'PSD');
        
        % get unique days only
        timeVecAll = timeofday(dateVecAll);
        dateVecDayOnly = dateVecAll - timeVecAll;
        UniqueDays = unique(dateVecDayOnly);
        
        % get last day
        LastDay = max(UniqueDays);
        NonDataIdx = LastDay ~= dateVecDayOnly;
        dateVecAll(NonDataIdx) = [];
        timeVecAll(NonDataIdx) = [];
        featFiles(NonDataIdx) = [];
        
        % get feature files of the last 30 min
        EndTime(subj) = max(timeVecAll);
        Last30Min = EndTime(subj) - duration(0,30,0);
        NonDataIdx = Last30Min > timeVecAll;
        dateVecAll(NonDataIdx) = [];
        timeVecAll(NonDataIdx) = [];
        featFiles(NonDataIdx) = [];
        
        % put infos into struct
        stFilesLastDay(subj-counterInvalid).subjectDir = szCurrentFolder;
        stFilesLastDay(subj-counterInvalid).featFiles = featFiles;
        stFilesLastDay(subj-counterInvalid).endTime = EndTime(subj);
        
    else
        counterInvalid = counterInvalid + 1;
    end
end

% save results as mat file
save('FilesLastDay', 'stFilesLastDay');

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