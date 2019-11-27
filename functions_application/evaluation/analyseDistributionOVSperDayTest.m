% Script to test the function analyseDistributionOVSperDay.m
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019 	JP

clear;
close all;

% path to data folder (needs to be customized)
szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';
% szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Jule_Pohlhausen2019\NN08IA10';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 18), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);
isDirectory = arrayfun(@(x)(x.isdir == 1), subjectDirectories);
subjectDirectories = subjectDirectories(isDirectory);

% number of subjects
nSubject = size(subjectDirectories, 1);

% preallocate struct for date values
stDate = struct('StartTime', 0, 'EndTime', 24, 'StartDay', [], 'EndDay', []);

% preallocate matrix with relative OV per day
nMaxDays = 5; % maximum of days with EMA
mOVperDay = NaN(nMaxDays, nSubject);

% loop over all subjects
for subj = 1:nSubject
    
    % get current subject directoy
    szCurrentFolder = subjectDirectories(subj).name;
    
    % get object
    [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);
    
    % get all dates of current subject
    caDates = getdatesonesubject(obj);
    
    %  number of days with EMA
    nDays = numel(caDates);
    
    if nDays > nMaxDays
        disp('adjust NaN')
    end
    
    % loop over all days with EMA
    for day = 1:nDays
        
        % adjust day in struct
        stDate.StartDay = caDates(day);
        stDate.EndDay = stDate.StartDay;
        
        % call function to analyse distribution of OVS per day
        [mOVperDay(day, subj)] = analyseDistributionOVSperDay(obj, stDate);
    end
end

% plot results
figure;
histogram(mOVperDay(:))

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