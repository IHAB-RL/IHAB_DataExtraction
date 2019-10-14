function [dateVal,isFeatFile]=Filename2date(szFileName,szFeatureNameShort)
% function to convert a typical HALLO objective data filename into a
% date/time variable
% Usage dateVal=Filename2date(szFileName)
%
% Parameters
% ----------
% szFileName :  string with the filename (no path)
% szFeatureNameShort: string with the short name of the feature that is
% used to identify the begin of the name-
%                     'PSD' is default
% Returns
% -------
% dateVal :  date/time datatype with the date and time
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Ver. 0.01 initial create (empty) 14-May-2017  Initials (eg. JB)
% Version 1.0 works for 3 letter short names

% ToDo: generalization with idx = find ShortName_ and fileparts to allow
% fullfilenames
%------------Your function implementation here---------------------------

if nargin < 2
    szFeatureNameShort = 'PSD';
end

if iscell(szFileName) && ~isempty(szFeatureNameShort)
    szFileName = szFileName(:);
    splitNames = regexpi(szFileName{1}, '[_]', 'split');
    numFilenameParts = numel(splitNames);
    
    if numFilenameParts < 4
        isOldFormat = true;
    else
        isOldFormat = false;
    end
    
    if isOldFormat
        checkLength = @(x)(length(x)> 21); % old comparison value was 4
    else
        checkLength = @(x)(length(x)> 28); % old comparison value was 4
    end
    isValidLength = cellfun(checkLength, szFileName);
    
    if isempty(isValidLength)
        warning(['The length of the file name/s do not match the convention.'...
            'Returning...'])
        return;
    end
    
    szFileName = szFileName(isValidLength);
    
    % look for the right Feature File Type in the directory
    checkFeatFile = @(x) (strcmpi(x(1:3),szFeatureNameShort));
    isFeatFile = cellfun(checkFeatFile, szFileName);
    
    if isempty(isFeatFile)
        dateVal = [];
        warning(['There were no valid feature files found. The first three '...
            'letters do not match the short name of the feature. Returning ...'])
        return;
    end
    
    szFileName = szFileName(isFeatFile);
    
    if isOldFormat
        offset = 0;
    else
        offset = 7;
    end
    
    szYear = str2double(cellfun(@(x)(x(5+offset:8+offset)),szFileName,'UniformOutput',false));
    szMonth = str2double(cellfun(@(x)(x(9+offset:10+offset)),szFileName,'UniformOutput',false));
    szDay = str2double(cellfun(@(x)(x(11+offset:12+offset)),szFileName,'UniformOutput',false));
    szHour = str2double(cellfun(@(x)(x(14+offset:15+offset)),szFileName,'UniformOutput',false));
    szMin = str2double(cellfun(@(x)(x(16+offset:17+offset)),szFileName,'UniformOutput',false));
    szSec = str2double(cellfun(@(x)(x(18+offset:19+offset)),szFileName,'UniformOutput',false));
    dateVal = datetime(szYear,szMonth,szDay,szHour,szMin,szSec);
        
elseif iscell(szFileName) % added for wav files 14-Oct-2019  JP
    szFileName = szFileName(:);
    splitNames = regexpi(szFileName{1}, '[_]', 'split');
    numFilenameParts = numel(splitNames);
    
    if numFilenameParts < 4
        isOldFormat = true;
    else
        isOldFormat = false;
    end
    
    if isOldFormat
        checkLength = @(x)(length(x)> 21); % old comparison value was 4
    else
        checkLength = @(x)(length(x)> 28); % old comparison value was 4
    end
    isValidLength = cellfun(checkLength, szFileName);
    
    if isempty(isValidLength)
        warning(['The length of the file name/s do not match the convention.'...
            'Returning...'])
        return;
    end
    
    szFileName = szFileName(isValidLength);
    
    if isOldFormat
        offset = 0;
    else
        offset = 7;
    end
    
    szYear = str2double(cellfun(@(x)(x(1+offset:4+offset)),szFileName,'UniformOutput',false));
    szMonth = str2double(cellfun(@(x)(x(5+offset:6+offset)),szFileName,'UniformOutput',false));
    szDay = str2double(cellfun(@(x)(x(7+offset:8+offset)),szFileName,'UniformOutput',false));
    szHour = str2double(cellfun(@(x)(x(10+offset:11+offset)),szFileName,'UniformOutput',false));
    szMin = str2double(cellfun(@(x)(x(12+offset:13+offset)),szFileName,'UniformOutput',false));
    szSec = str2double(cellfun(@(x)(x(14+offset:15+offset)),szFileName,'UniformOutput',false));
    dateVal = datetime(szYear,szMonth,szDay,szHour,szMin,szSec);
    
    isFeatFile = isValidLength;
else
    % Get numeric parts of file name
    splitNames = regexpi(szFileName,'[_]','split');
    
    numFilenameParts = numel(splitNames);
    
    if numFilenameParts < 4
        isOldFormat = true;
    else
        isOldFormat = false;
    end
    
    % 17/24 is standard length for a valid file name (wo. '.feat')
    if isOldFormat
        validNameLength = 27;
    else
        validNameLength = 34;
    end
    
    if (length(szFileName) == validNameLength) % old comparison value was 4
        if (strcmp(szFileName(1:3),szFeatureNameShort)) % szFeatData must be the string at the beginning
            % now extract date and time of writing
            
            if isOldFormat
                offset = 0;
            else
                offset = 7;
            end
            szYear = szFileName(5+offset:8+offset);
            szMonth = szFileName(9+offset:10+offset);
            szDay = szFileName(11+offset:12+offset);
            szHour = szFileName(14+offset:15+offset);
            szMin = szFileName(16+offset:17+offset);
            szSec = szFileName(18+offset:19+offset);
            
            dateVal  =  datetime(str2double(szYear),str2double(szMonth)...
                ,str2double(szDay),str2double(szHour),str2double(szMin),str2double(szSec));
            isFeatFile = true;
        else
            dateVal = NaT;
            isFeatFile = false;
            return;
        end
    else
        dateVal = NaT;
        isFeatFile = false;
        return;
    end
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2017> J.Bitzer
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