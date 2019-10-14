function [vCalibConst]=getCalibConst(szSubjectID)
% function to get the system specific calibration constant
% informations are based on calibration measurements (Aug-2019), the
% returned calibration constant is channel (right+left) dependent
%
% Usage [vCalibConst]=getCalibConst(szSubjectID)
%
% Parameters
% ----------
% inParam :  szSubjectID - string, contains subject ID, e.g. AA00BB11
%
% Returns
% -------
% outParam :  vCalibConst - cell array, contains system specific 
%                           calibration constants
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create 25-Sep-2019 JP
% Ver. 0.02 switched to map 01-Oct-2019 JP

% load assignment of IHAB systems and subjects
load(fullfile('functions_helper', 'IHAB', 'IdentificationProbandSystem_Maps.mat'));

% get used IHAB system
szSystem = values(mapSubject_1, {szSubjectID});

% get system specific calibration constant
vCalibConst = values(mapSystem, szSystem);

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

% eof