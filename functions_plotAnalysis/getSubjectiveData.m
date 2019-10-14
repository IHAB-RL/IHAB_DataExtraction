function [hasSubjectiveData,FinalTableOneSubject,FinalTimeQ,ReportedDelay]=getSubjectiveData(obj,varargin)
% function to save subjective data of one test subject for a specific time
% frame
% Usage [Data,TimeVec]=getObjectiveDataOneDay(szTestSubject,desiredDay, szFeature)
%
% Parameters
% ----------
% obj : struct, containing all informations
%
% szFeature : string, specifies which feature data should be read in
%             possible: 'PSD', 'RMS', 'ZCR'
%
% varargin :  specifies optional parameter name/value pairs.
%             getObjectiveData(obj 'PARAM1', val1, 'PARAM2', val2, ...)
%     'StartTime'    duration to specify the start time of desired data
%                    syntax duration(H,MI,S);
%                    or a number between [0 24], which will be transformed
%                    to a duration;
%
%     'EndTime'      duration to specify the end time of desired data
%                    syntax duration(H,MI,S);
%                    or a number between [0 24], which will be transformed
%                    to a duration; obviously EndTime should be greater
%                    than StartTime;
%
%     'StartDay'     to specify the start day of desired data, allowed
%                    formats are datetime, numeric (i.e. 1 for day one),
%                    char (i.e. 'last')
%
%     'EndDay'      to specify the end day of desired data, allowed
%                   formats are datetime, numeric (i.e. 1 for day one),
%                   char (i.e. 'last'); obviously EndDay should be greater
%                   than or equal to StartDay;
%
%     'stInfo'      struct which contains valid date informations about the
%                   aboved named 4 parameters; this struct results from
%                   calling checkInputFormat.m
%
%   'isPrintMode'   logical whether to save subjective data as mat file
%
% Returns
% -------
% hasSubjectiveData : logical, nomen est omen
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Source: based on functions by Nils Schreiber (2019) 
% Version History:
% Ver. 0.01 initial create 01-Oct-2019 	JP

% preallocate output parameters
FinalTableOneSubject = [];
FinalTimeQ = [];
ReportedDelay = [];

% parse input arguments
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('obj', @(x) isa(x,'IHABdata') && ~isempty(x));

p.addParameter('StartTime', 0, @(x) isduration(x) || isnumeric(x));
p.addParameter('EndTime', 24, @(x) isduration(x) || isnumeric(x));
p.addParameter('StartDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('EndDay', NaT, @(x) isdatetime(x) || isnumeric(x) || ischar(x));
p.addParameter('stInfo', [], @(x) isstruct(x));
p.addParameter('isPrintMode', 0, @(x) isnumeric(x));
p.parse(obj,varargin{:});

% re-assign values
isPrintMode = p.Results.isPrintMode;
stInfo = p.Results.stInfo;

if isempty(stInfo)
    % call function to check input date format and plausibility
    stInfo = checkInputFormat(obj, p.Results.StartTime, p.Results.EndTime, ...
        p.Results.StartDay, p.Results.EndDay);
end


% get subjective data from mat file or call import_EMA2018.m
quest = dir([obj.stSubject.Folder filesep 'Questionnaires_*.mat']);
if ~isempty(quest)
    load([obj.stSubject.Folder filesep quest.name]);
else
    import_EMA2018(obj);
end

if isempty(QuestionnairesTable)
    hasSubjectiveData = 0;
else
    hasSubjectiveData = 1;
end

if hasSubjectiveData
    
    SubjectIDTable = QuestionnairesTable.SubjectID;
    
    idx = strcmp(obj.stSubject.Name, SubjectIDTable);
    
    if all(idx == 0)
        error('Subject not found in questionnaire table')
        return;
    end
    
    TableOneSubject = QuestionnairesTable(idx,:);
    
    for kk = 1:height(TableOneSubject)
        szDate = TableOneSubject.Date{kk};
        szTime = TableOneSubject.Start{kk};
        szYear = szDate(1:4);
        szMonth = szDate(6:7);
        szDay = szDate(9:10);
        szHour = szTime(1:2);
        szMin = szTime(4:5);
        szSec = szTime(7:8);
        
        dateVecOneSubjectQ(kk) = datetime(str2num(szYear),str2num(szMonth)...
            ,str2num(szDay),str2num(szHour),str2num(szMin),str2num(szSec));
    end
    
    
    %% reduce to data of specific date/ time
    dateVecDayOnlyQ = dateVecOneSubjectQ-timeofday(dateVecOneSubjectQ);
    idxDate = find(dateVecDayOnlyQ >= stInfo.StartDay & dateVecDayOnlyQ <= stInfo.EndDay);
    
    if ~isempty(idxDate)
        % filter data for specific time frame
        FinalTimeQ = dateVecOneSubjectQ(idxDate);
        FinalTableOneSubject = TableOneSubject(idxDate,:);
        
        % calculate reported delay
        ReportedDelay = zeros(height(FinalTableOneSubject),1);
        if str2double(szYear) < 2017
            for kk = 1:height(FinalTableOneSubject)
                if iscell(FinalTableOneSubject.AssessDelay)
                    AssessDelay = FinalTableOneSubject.AssessDelay{kk};
                elseif isnumeric(FinalTableOneSubject.AssessDelay)
                    AssessDelay = FinalTableOneSubject.AssessDelay(kk);
                end
                if (~ischar(AssessDelay))
                    if (AssessDelay <= 5)
                        ReportedDelay(kk) = (AssessDelay-1)*5;
                    elseif (AssessDelay == 5)
                        ReportedDelay(kk) = 30;
                    elseif (AssessDelay >= 6)
                        ReportedDelay(kk) = 40; % Could be everything
                    end
                else
                    ReportedDelay(kk) = 0;
                end
            end
        else
            for kk = 1:height(FinalTableOneSubject)
                if iscell(FinalTableOneSubject.AssessDelay)
                    AssessDelay = FinalTableOneSubject.AssessDelay{kk};
                elseif isnumeric(FinalTableOneSubject.AssessDelay)
                    AssessDelay = FinalTableOneSubject.AssessDelay(kk);
                end
                if (~ischar(AssessDelay))
                    switch AssessDelay
                        case 1
                            ReportedDelay(kk) = 0;
                        case 2
                            ReportedDelay(kk) = 2.5;
                        case 3
                            ReportedDelay(kk) = 5;
                        case 4
                            ReportedDelay(kk) = 10;
                        case 5
                            ReportedDelay(kk) = 15;
                        case 6
                            ReportedDelay(kk) = 20;
                        case 7
                            ReportedDelay(kk) = 30;
                        otherwise
                    end
                end
            end
        end
        
        if isPrintMode
            % save as mat file
            szSaveName = [obj.stSubject.Folder filesep 'SubjectiveData_' obj.stSubject.Name];
            save(szSaveName, 'FinalTableOneSubject', 'FinalTimeQ', 'ReportedDelay');
        end
    else
        hasSubjectiveData = 0;
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