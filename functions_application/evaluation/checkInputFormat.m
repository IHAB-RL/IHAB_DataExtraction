function stInfo = checkInputFormat(obj, StartTime, EndTime, StartDay, EndDay)
% function to check the input format of a given input param
% Usage stInfo = checkInputFormat(obj, StartTime, EndTime, StartDay, EndDay)
%
% Parameters
% ----------
% inParam : 
%   obj : class IHABdata, contains all informations
%
%   StartTime : duration to specify the start time of desired data
%               syntax duration(H,MI,S);
%               or a number between [0 24], which will be transformed
%               to a duration;
%
%   EndTime : duration to specify the end time of desired data
%             syntax duration(H,MI,S);
%             or a number between [0 24], which will be transformed
%             to a duration; 
%             obviously EndTime should be greater than StartTime;
%
%   StartDay : to specify the start day of desired data, allowed formats 
%              are datetime, numeric (i.e. 1 for day one), char (i.e. 
%              'first', 'last')
%
%   EndDay : to specify the end day of desired data, allowed formats are 
%            datetime, numeric (i.e. 1 for day one), char (i.e. 'first', 
%            'last'); obviously EndDay should be greater than or equal to 
%            StartDay;
%
% Returns
% -------
% outParam :  
%   stInfo : struct, contains valid time informations based on input args
%            if the input parameters contain invalid data stOnfo is empty
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 26-Sep-2019  JP

% preallocate struct for date values
stInfo = struct('StartTime', [], 'EndTime', [], 'StartDay', [], 'EndDay', []);

% check time input parameters format
if ~isduration(StartTime) && StartTime >= 0 && StartTime <= 24
    stInfo.StartTime = duration(StartTime,0,0);
else
    stInfo.StartTime = StartTime;
end

if ~isduration(EndTime) && EndTime >= 0 && EndTime <= 24
    stInfo.EndTime = duration(EndTime,0,0);
else
    stInfo.EndTime = EndTime;
end

% check time input parameters plausibility
if stInfo.StartTime > stInfo.EndTime
    error('input EndTime must be greater than input StartTime');
end


% get all dates of one subject
caDates = getdatesonesubject(obj);

% check day input parameters format
if isdatetime(StartDay)
    if ~isnat(StartDay)
        stInfo.StartDay = StartDay;
    else
        stInfo.StartDay = caDates(1);
    end
    
elseif isnumeric(StartDay)
    
    if StartDay == -1 % i.e. get all days
        stInfo.StartDay = caDates(1);
        stInfo.EndDay = caDates(end);
        
    elseif StartDay <= length(caDates)
        stInfo.StartDay = caDates(StartDay);
        
    else
        error('input StartDay has an invalid value');
    end
    
elseif ischar(StartDay)
    
    switch StartDay
        case 'first'
            stInfo.StartDay = caDates(1);
        case 'last'
            stInfo.StartDay = caDates(end);
            stInfo.EndDay = caDates(end);
        case 'all'
            stInfo.StartDay = caDates(1);
            stInfo.EndDay = caDates(end);
    end
end


if isempty(stInfo.EndDay)
    if isdatetime(EndDay)
        if ~isnat(EndDay)
            stInfo.EndDay = EndDay;
        elseif isnat(EndDay) && isnat(StartDay)
            % if EndDay and StartDay are not assigned, StartDay = first day
            % EndDay = last day
            stInfo.EndDay = caDates(end);
        else
            % if EndDay is not assigned, EndDay = StartDay
            stInfo.EndDay = stInfo.StartDay;
        end
        
    elseif isnumeric(EndDay)
        
        if EndDay == -1 % i.e. get all days
            stInfo.StartDay = caDates(1);
            stInfo.EndDay = caDates(end);
            
        elseif EndDay <= length(caDates)
            stInfo.EndDay = caDates(EndDay);
            
        else
            error('input EndDay has an invalid value');
        end
        
    elseif ischar(EndDay)
        
        switch EndDay
            case 'first'
                stInfo.EndDay = caDates(1);
            case 'last'
                stInfo.EndDay = caDates(end);
            case 'all'
                stInfo.StartDay = caDates(1);
                stInfo.EndDay = caDates(end);
        end
    end
end

% check day input parameters plausibility
if stInfo.StartDay > stInfo.EndDay
    error('input EndDay must be greater than input StartDay ');
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