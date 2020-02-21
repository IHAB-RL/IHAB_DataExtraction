% test script to plot a fingerprint for a specific time frame
%
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 04-Feb-2020 	JP

% clear; 
% close all;

% % path to data folder (needs to be customized)
% szBaseDir = 'I:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';
% 
% % subject folder
% szCurrentFolder = 'NN07IS04_180611_ks';
% 
% % get object
% [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);

% set time infos
StartDay = datetime(2018,6,13);
EndDay = StartDay;
StartTime = 7;
EndTime = 8;

% preallocate
vOVS_RandomForest = [];
vFVS_RandomForest = [];
vTimeVD = [];

stDate.StartDay = StartDay;
stDate.EndDay = EndDay;

vStartTime = StartTime:EndTime;

% loop over 1h intervalls
for time = 1:length(vStartTime)

    % adjust time in struct
    stDate.StartTime = duration(vStartTime(time), 0, 1);
    stDate.EndTime = duration(vStartTime(time)+1, 0, 0);

    % predict voice sequences with a trained random forest
    szMode = 'OVD';
    [vPredictedOVS, vTimeTemp] = detectVoiceRandomForest(obj, stDate, szMode);
    szMode = 'FVD';
    [vPredictedFVS] = detectVoiceRandomForest(obj, stDate, szMode);

    vOVS_RandomForest = [vOVS_RandomForest; vPredictedOVS];
    vFVS_RandomForest = [vFVS_RandomForest; vPredictedFVS];
    vTimeVD = [vTimeVD; vTimeTemp];
end