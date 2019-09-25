function caDates = getdatesonesubject(obj)
% function to get all dates of one subject
%
% Usage: caDates = getdatesonesubject(obj)
%
% Parameters
% ----------
% inParam :  obj - struct, contains all informations about the subject,
%                  foldername, path...
%
% Returns
% -------
% outParam :  caDates - datetime array, contains all dates of one subject
%
% Author:  (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create
% Ver. 1.0 updated to actual version 25-Sep-2019 JP


% List the whole content in the subject directory
stFeatFiles = dir([obj.szBaseDir filesep obj.stSubject.FolderName, filesep, ...
    obj.stSubject.SubjectID  '_AkuData']);

% Get rid of '.' and '..'
stFeatFiles(1:2) = [];

% Get files only
stFeatFiles = stFeatFiles(~[stFeatFiles.isdir]);
caFileNames = {stFeatFiles.name};

% Filter for .feat-files
stFeatFiles = stFeatFiles(cellfun(@(x) ~isempty(regexpi(x,'.feat')), caFileNames));
caFileNames = {stFeatFiles.name};

% Delete filenames belonging to corrupt files ...
% (see ../Tools/CheckDataIntegrety.m)
corruptTxtFile = fullfile(obj.szBaseDir, obj.stSubject.FolderName,'corrupt_files.txt');
if ~exist(corruptTxtFile,'file')
    CheckDataIntegrety(obj.stSubject.FolderName, obj.szBaseDir);
end
fid = fopen(corruptTxtFile,'r');
corruptFiles = textscan(fid,'%s\n');
fclose(fid);
corruptFiles = corruptFiles{:};

[caFileNames, ~] = setdiff(caFileNames,corruptFiles,'stable');

% Get all numeric content of each name that correspond to date and time
caDatesWithTime = cellfun(@(x) regexpi(x,'\d+', 'match'), caFileNames,...
    'UniformOutput',false);

% Only take the date -> second last entry in each cell
caDatesWithoutTime = cellfun(@(x) x(end-1), caDatesWithTime);

% Filter for unique dates
caUniqueDates = unique(caDatesWithoutTime);

% Convert them to desired output format
caDates = datetime(caUniqueDates,'InputFormat','yyyyMMdd');
T = table();
T.(obj.stSubject.SubjectID) = caDates;

%--------------------Licence ---------------------------------------------
% Copyright (c) <201x> 
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

% eof