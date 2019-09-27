function [Pxy, Pxx, Pyy] = get_psd(mData, version)

% split PSDs 
% mData: 514 Pxy (complex), 257 Pxx, 257: Pyy; x: left
% mData: 1026 Pxy (complex), 513 Pxx, 513: Pyy; x: left


if nargin < 2
    version = 0;
end

n(1) = size(mData,2) / 2; 
n(2) = n(1) / 2; 

if ~version % old
    Pxy = ic2matc(mData(:,1:n(1)));
else        % new
    temp = mData(:,1:n(1));
    Pxy = temp(:,1:2:end) + 1i*temp(:,2:2:end);
end
Pxx = mData(:,n(1)+1:n(1)+n(2));
Pyy = mData(:,n(1)+n(2)+1:end);

% Pxy = ic2matc(mData(:,1:514));
% Pxx = mData(:,515:771);
% Pyy = mData(:,772:end);
