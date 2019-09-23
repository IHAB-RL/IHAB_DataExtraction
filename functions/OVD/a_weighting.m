function [A,a] = a_weighting(nfft,fs)

nBins = nfft/2+1;
nNyquist = fs/2;
vFreqs = (0:nBins-1)/(nBins-1) * nNyquist;

a = 12194^2.*vFreqs.^4 ./ ((vFreqs.^2+20.6^2) .* sqrt((vFreqs.^2 + 107.7^2) .* (vFreqs.^2 + 737.9^2)) .* (vFreqs.^2+12194^2));
a = a(:);
A = 20*log10(a(:))+2;