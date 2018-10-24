
%VALIDATESUBJECTTEST
% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 14-Dec-2017 			 NS
% ---------------------------------------------------------
szSubject= fullfile('ER08RD13');
szSubject = fullfile('FF08RD02');

configStruct.lowerBinCohe = 1100;
configStruct.upperBinCohe = 3000;
configStruct.upperThresholdCohe = 0.9;
configStruct.upperThresholdRMS = -6; % -6 dB
configStruct.lowerThresholdRMS = -70; % -70 dB
configStruct.errorTolerance = 0.05; % 5 percent

tableSubject = validatesubject(szSubject, configStruct);


% EOF validatesubjectTest.m