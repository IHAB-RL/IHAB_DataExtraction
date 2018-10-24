function [matc] = ic2matc(mic)

% converts interleaved complex data to matlab's format

matc = mic(:,1:2:end) + 1i*mic(:,2:2:end);



