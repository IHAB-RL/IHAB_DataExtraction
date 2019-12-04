% Script to test the function analyseDistributionOVSperDay.m
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019 	JP

% clear;
close all;

% path to data folder (needs to be customized)
szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 18), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);
isDirectory = arrayfun(@(x)(x.isdir == 1), subjectDirectories);
subjectDirectories = subjectDirectories(isDirectory);
subjectDirectories = subjectDirectories([12 20]);

% number of subjects
nSubject = size(subjectDirectories, 1);

% preallocate struct for date values
stDate = struct('StartTime', [], 'EndTime', [], 'StartDay', [], 'EndDay', []);

mStartTime = 8:20;

% preallocate matrix with relative OV per day
nMaxDays = 5; % maximum of days with EMA
mOVperDay = NaN(nMaxDays, nSubject);
mOVperHour = NaN(nMaxDays*length(mStartTime), nSubject);
nFrames = 0;
nOV = 0;

% loop over all subjects
for subj = 1:nSubject
    
    % get current subject directoy
    szCurrentFolder = subjectDirectories(subj).name;
    
    % get object
    [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);
    
    % get all dates of current subject
    caDates = getdatesonesubject(obj);
    
    % analyse only valid dates, i.e. after the 01-May-2018
    dProjectStart = datetime(2018,05,01);
    isValidDate = arrayfun(@(x)(x >= dProjectStart), caDates);
    caDates = caDates(isValidDate);
    
    % current number of days with EMA
    nDays = numel(caDates);
    
    if nDays > nMaxDays
        disp('adjust NaN')
    end
    
    counter = 1;
    
    % loop over all days with EMA
    for day = 1:nDays
        
        % adjust day in struct
        stDate.StartDay = caDates(day);
        stDate.EndDay = stDate.StartDay;
        
        % loop over 1h intervalls
        for time = 1:length(mStartTime)
        
            % adjust time in struct
            stDate.StartTime = duration(mStartTime(time), 0, 1);
            stDate.EndTime = duration(mStartTime(time)+1, 0, 0);

            % call function to analyse distribution of OVS in the morning
            [~, nOVTemp, nFramesTemp] = analyseDistributionOVSperDay(obj, stDate);

            % total number of frames per day
            nFrames = nFrames + nFramesTemp;

            % total number of OV per day
            nOV = nOV + nOVTemp;
        
            % OV per hour relative to number of frames per hour
            mOVperHour(counter, subj) = nOVTemp/nFramesTemp; 
            
            counter = counter + 1;
        end
        
        % OV per day relative to number of frames per day
        mOVperDay(day, subj) = nOV/nFrames; 
    end
    
    clear obj
end

% plot results
figure;
% histogram(mOVperDay(:))
boxplot(100*mOVperHour,'Labels', {subjectDirectories.name});
ylabel('estimated own voice per day in %');

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