
%VALIDATECHUNKTEST
% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 11-Dec-2017 			 NS
% ---------------------------------------------------------
clearvars;
close all;

szFile = fullfile(pwd,'IHAB_Rohdaten_EMA2018','JB11JB11','JB11JB11_AkuData','RMS_001872_20180417_151309782.feat');

% This is the lower frequency bin that is taken into account for the
% calculation of the mean from a specific range of frequency bands.
configStruct.lowerBinCohe = 100;

% This is the upper frequency bin that is taken into account for the
% calculation of the mean from a specific range of frequency bands.
configStruct.upperBinCohe = 1000;

% If the mean value is over this threshold and .thresholdRMSforMSC then the
% respective time is invalid
configStruct.upperThresholdCohe = 0.9;

% If mean of MSC undercuts this threshold the time is taken as invalid
%configStruct.lowerThresholdMSC = 0.2;

% See comment for .upperThresholdMSC
%configStruct.thresholdRMSforCohe = -40; % -40 dB

% If this threshold is exceeded the time is invalid
configStruct.upperThresholdRMS = -6; % -6 dB

% If this threshold is undercut the time is invalid
configStruct.lowerThresholdRMS = -70; % -60 dB

% If this tolerance is exceeded by any invalidity check then the chunk is
% taken is invalid
configStruct.errorTolerance = 0.05; % 2 percent

% Compute validity of a chunk
errorCodes = validatechunk(szFile, configStruct)