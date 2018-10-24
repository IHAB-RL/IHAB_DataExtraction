function [Pxy, Pxx, Pyy] = get_psd(mData)

% split PSDs 
% mData: 514 Pxy (complex), 257 Pxx, 257: Pyy; x: left
% mData: 1026 Pxy (complex), 513 Pxx, 513: Pyy; x: left
% i.e: 

n(1) = size(mData,2) / 2; 
n(2) = n(1) / 2; 

Pxy = ic2matc(mData(:,1:n(1)));
Pxx = mData(:,n(1)+1:n(1)+n(2));
Pyy = mData(:,n(1)+n(2)+1:end);

% Pxy = ic2matc(mData(:,1:514));
% Pxx = mData(:,515:771);
% Pyy = mData(:,772:end);
