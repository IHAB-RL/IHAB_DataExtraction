function [cTime, sXString] = timeMsToString(vTime)

nTime = length(vTime);
cTime = cell(nTime, 1);
nMin = min(vTime);
nMax = max(vTime);

    for iTime = 1:nTime
        if (nMax - nMin > 2*60*60*1000)
            cTime{iTime} = num2str(vTime(iTime)/1000/60/60);
            sXString = 'Time [h]';
        else 
            cTime{iTime} = num2str(vTime(iTime)/1000);
            sXString = 'Time [s]';
        end
    end

end