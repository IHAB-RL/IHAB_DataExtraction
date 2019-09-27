function [stData] = OVD_Bilert(stParam, stData)
%% Own Voice Detection by Bilert 2018
% system: HALLO, IHAB
%
% type: Messkondition; KEMAR,
%
% date: 'complete', enthält alle Messtermine
%
% config: aka cLabels{:,kk}, Bezeichner für verchiedene Messungen
% 
% debug: boolean
% 
% szPath: Pfad zum Daten-Ordner OVD_Data


% Zur Berechnung der neuen adaptiven Schwelle wurden blockweise jeweils das 
% Maximum und das Minimum der berechneten zeitlichen Kohärenzen verwendet
stData.adapThreshMax = movmax(stData.vCohMeanRealSmooth,floor(stParam.adapThreshWin));
stData.adapThreshMin = movmin(stData.vCohMeanRealSmooth,floor(stParam.adapThreshWin));
% arithmetischer Mittelwert der maximalen und minimalen Kohärenz + 25%
stData.offset = 1.25;
% stData.offset = 1;
stData.adapThresh = stData.offset*((stData.adapThreshMax + stData.adapThreshMin)./2);

% OVD
vOVS_fix = zeros(size(stData.vCohMeanRealSmooth));
vOVS_fix(stData.vCohMeanRealSmooth >= stParam.fixThresh) = 1;
stData.vOVS_fix = vOVS_fix;

vOVS_adap = zeros(size(stData.vCohMeanRealSmooth));
vOVS_adap(stData.vCohMeanRealSmooth >= stData.adapThresh) = 1;
stData.vOVS_adap = vOVS_adap;

debugPlot = 0;
if debugPlot
    figure;
    plot(stData.vCohMeanReal);
    hold on;
    plot(stData.vCohMeanRealSmooth);
    plot(stData.adapThresh,'r');
    plot(0.6*ones(size(stData.adapThresh)),'k');
    pause;
end

% eof