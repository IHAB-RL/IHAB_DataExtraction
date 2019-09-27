% test script belonging to getdatesonesubject.m
%
% Author: (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 
% Ver. 1.0 updated to actual version 25-Sep-2019 JP

% path to data folder (needs to be customized)
obj.szBaseDir = 'K:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';

% name of subject folder
szCurrentFolder =  'HN06MA10_180613_aw'; 
obj.stSubject = getsubject(obj.szBaseDir, szCurrentFolder);

% get all dates of one subject
caDates = getdatesonesubject(obj);

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