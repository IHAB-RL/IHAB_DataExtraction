% test script to evaluate the Own Voice Detection (OVD) and Futher Voice 
% Detection (FVD) on real IHAB data
% OVD and FVD by Nils Schreiber (Master 2019)
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 10-Sep-2019 	JP


% clear; 
% close all;

% path to data folder (needs to be customized)
szBaseDir = 'I:\IHAB_2_EMA2018\IHAB_Rohdaten_EMA2018';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 18), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% choose a subject randomly  (adjust for a specific subject)
nSubject = round(size(subjectDirectories,1)*rand(1));
nSubject = 7;

% get one subject directoy
szCurrentFolder = subjectDirectories(nSubject).name;

% get object
[obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

OneSubjectOneDayOVD(obj,'startDay',1,'EndDay',1);

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> Jule Pohlhausen
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