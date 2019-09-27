function sOut = formatSeconds(tIn)

% Output input time in seconds to formatted string as HHh:MMm:SSs

nHours = floor(tIn/60/60);
nMinutes = floor((tIn - nHours*60*60)/60);
nSeconds = floor((tIn - nHours*60*60 - nMinutes*60));

if (nHours > 0)
    sOut = sprintf('%dh%dm%ds', nHours, nMinutes, nSeconds);
elseif (nMinutes > 0)
    sOut = sprintf('%dm%ds', nMinutes, nSeconds);
else
    sOut = sprintf('%ds', nSeconds);    
end

end