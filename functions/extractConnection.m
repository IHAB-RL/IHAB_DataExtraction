function [] = extractConnection(sPath, obj)

sFileName = 'log2.txt';

cLog = fileread(fullfile(sPath,sFileName));

bIncludeAll = 0;
bNormalise = 1;


sOccBTOn = 'Bluetooth: connected';
sOccBTOff = 'Bluetooth: disconnected';
sOccBatteryLevel = 'battery level';
sOccTimeReset = 'Device Time reset';
sOccDisplayOn = 'Display: on';
sOccDisplayOff = 'Display: off';
sOccVibration = 'Vibration:';

sMinTimeString = '2018-04-25-09:00:00:000';
nMinTime = stringToTimeMs(sMinTimeString);


vOccBTOn = strfind(cLog, sOccBTOn);
vOccBTOff = strfind(cLog, sOccBTOff);
vOccDisplayOn = strfind(cLog, sOccDisplayOn);
vOccDisplayOff = strfind(cLog, sOccDisplayOff);
vOccLevelBattery = strfind(cLog, sOccBatteryLevel);
vOccVibration = strfind(cLog, sOccVibration);

vLevelBattery = zeros(length(vOccLevelBattery),1);
vTimeBattery = zeros(length(vOccLevelBattery),1);
vTimeBTOn = zeros(length(vOccBTOn),1);
vTimeBTOff = zeros(length(vOccBTOff),1);
vTimeDisplayOn = zeros(length(vOccDisplayOn),1);
vTimeDisplayOff = zeros(length(vOccDisplayOff),1);
vTimeVibration = zeros(length(vOccVibration),1);

for iLog = 1:length(vOccLevelBattery)
    if (stringToTimeMs(cLog(vOccLevelBattery(iLog)-24:vOccLevelBattery(iLog)-2)) > nMinTime)
        nMinTime = stringToTimeMs(cLog(vOccLevelBattery(iLog)-24:vOccLevelBattery(iLog)-2));
        break;
    end
end


for iLog = 1:length(vOccLevelBattery)
    nTime = stringToTimeMs(cLog(vOccLevelBattery(iLog)-24:vOccLevelBattery(iLog)-2));
    nLevel = str2double(cLog(vOccLevelBattery(iLog)+15:vOccLevelBattery(iLog)+18));
    if (nTime > nMinTime || bIncludeAll)
        if bNormalise
            vTimeBattery(iLog) = nTime-nMinTime;
            vLevelBattery(iLog) = nLevel;
        else
            vTimeBattery(iLog) = nTime-nMinTime;
            vLevelBattery(iLog) = nLevel;
        end
    end
end
nZero = length(find(vTimeBattery));
vLevelBattery = vLevelBattery(1:nZero);
vTimeBattery = vTimeBattery(1:nZero);

for iLog = 1:length(vOccBTOn)
    nTime = stringToTimeMs(cLog(vOccBTOn(iLog)-24:vOccBTOn(iLog)-2));
    if (nTime > nMinTime || bIncludeAll)
        if bNormalise
            vTimeBTOn(iLog) = nTime-nMinTime;
        else
            vTimeBTOn(iLog) = nTime;
        end
    end
end
vTimeBTOn(vTimeBTOn==0) = [];

for iLog = 1:length(vOccBTOff)
    nTime = stringToTimeMs(cLog(vOccBTOff(iLog)-24:vOccBTOff(iLog)-2));
    if (nTime > nMinTime || bIncludeAll)
        if bNormalise
            vTimeBTOff(iLog) = nTime-nMinTime;
        else
            vTimeBTOff(iLog) = nTime;
        end
    end
end
vTimeBTOff(vTimeBTOff==0) = [];

for iLog = 1:length(vOccDisplayOn)
    nTime = stringToTimeMs(cLog(vOccDisplayOn(iLog)-24:vOccDisplayOn(iLog)-2));
    if (nTime > nMinTime || bIncludeAll)
        if bNormalise
            vTimeDisplayOn(iLog) = nTime-nMinTime;
        else
            vTimeDisplayOn(iLog) = nTime;
        end
    end
end
vTimeDisplayOn(vTimeDisplayOn==0) = [];

for iLog = 1:length(vOccDisplayOff)
    nTime = stringToTimeMs(cLog(vOccDisplayOff(iLog)-24:vOccDisplayOff(iLog)-2));
    if (nTime > nMinTime || bIncludeAll)
        if bNormalise
            vTimeDisplayOff(iLog) = nTime-nMinTime;
        else
            vTimeDisplayOff(iLog) = nTime;
        end
    end
end
vTimeDisplayOff(vTimeDisplayOff==0) = [];

for iLog = 1:length(vOccVibration)
    nTime = stringToTimeMs(cLog(vOccVibration(iLog)-24:vOccVibration(iLog)-2));
    if (nTime > nMinTime || bIncludeAll)
        if bNormalise
            vTimeVibration(iLog) = nTime-nMinTime;
        else
            vTimeVibration(iLog) = nTime;
        end
    end
end
vTimeDisplayOff(vTimeDisplayOff==0) = [];

vTimeDisplay = [vTimeDisplayOn; vTimeDisplayOff];
[vTimeDisplay, idx] = sort(vTimeDisplay);
vDisplay = [ones(size(vTimeDisplayOn)); zeros(size(vTimeDisplayOff))];
vDisplay = vDisplay(idx);

vTimeBluetooth = [vTimeBTOn; vTimeBTOff];
[vTimeBluetooth, idx] = sort(vTimeBluetooth);
vBluetooth = [ones(size(vTimeBTOn))-0.1; zeros(size(vTimeBTOff))];
vBluetooth = vBluetooth(idx);

nMin = min([vTimeBTOn; vTimeBTOn; vTimeBattery;...
    vTimeDisplayOn; vTimeDisplayOff; vTimeVibration]);

vTimeBluetooth = vTimeBluetooth - nMin;
vTimeBattery = vTimeBattery - nMin;
vTimeDisplayOn = vTimeDisplayOn - nMin;
vTimeDisplayOff = vTimeDisplayOff - nMin;
vTimeVibration = vTimeVibration - nMin;


gca = obj.hAxes;
hold all;
stem(vTimeVibration, 1.1*ones(length(vTimeVibration),1),'x');
stairs(vTimeBluetooth, vBluetooth);
stairs(vTimeDisplay, vDisplay);
plot(vTimeBattery, vLevelBattery);

hold off;
box on;
grid on;

ylim([-0.5,1.5]);
xLims = get(gca,'XLim');
xDyn = abs(diff(xLims));
xlim([xLims(1)-0.1*xDyn, xLims(2)+0.1*xDyn]);

[cTime, sXString] = timeMsToString(get(gca,'XTick'));
set(gca, 'XTickLabel',cTime);
set(gca ,'YTickLabel',{});
xlabel(sXString);

legend('Vibration', 'Bluetooth', 'Display', 'Battery Level')


end