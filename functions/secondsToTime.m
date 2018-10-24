function sFormatTime = secondsToTime(nIn)

sTimeString = '%02d:%02d:%02d';

nHours = floor(nIn/60/60);
nMinutes = floor((nIn - nHours*60*60)/60); 
nSeconds = floor(nIn - nHours*60*60 - nMinutes*60);

sFormatTime = sprintf(sTimeString, nHours, nMinutes, nSeconds);

end