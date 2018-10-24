% Script to test the function dateVal=Filename2date(szFileName).m 
% Author: J.Bitzer (c) TGM @ Jade Hochschule applied licence see EOF 
% Version History:
% Ver. 0.01 initial create (empty) 14-May-2017 			 Initials (eg. JB)

clear;
close all;
clc;

%------------Your script starts here-------- 

%Define your parameters and adjust your function call
szFileName = ...
    {'RMS_000001_20180419_073432728.feat',...
    'RMS_002237_20180417_211931487.feat',...
    'RMS_002238_20180417_212007402.feat',...
    'RMS_002239_20180417_212119078.feat',...
    'RMS_002240_20180417_212147573.feat',...
    'RMS_002505_20180418_115949487.feat',...
    'RMS_003243_20180419_093108992.feat',...
    'RMS_003248_20180419_113020651.feat'}
szFeat = 'RMS';
dateVal=Filename2date(szFileName,szFeat)

szFileName = 'PSD_20161027_074545478';
szFeat = 'PS';
dateVal=Filename2date(szFileName,szFeat)

szFileName = '_20161027_074545478';
szFeat = 'PSD';
dateVal=Filename2date(szFileName,szFeat)

szFileName = 'PSD_20161007_074545478';
szFeat = 'PSD';
dateVal=Filename2date(szFileName,szFeat)

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