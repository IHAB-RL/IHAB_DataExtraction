function stDataReal = FVD3(isOVS, snrPrio, est_snr_db)

%% Foreign speaker voice detection
mostImportantBins = 6:64;

% Compute SNR prio in dB
mFullLogSNRPrio = 10.*log10(abs(snrPrio));

% Allocate an index vector
vIndices = 1:size(mFullLogSNRPrio,2);

% Percentile vector to store limit values
value = zeros(length(vIndices),1);

for ll = 1:length(vIndices)
    if est_snr_db(ll) >= 60
        per = 90;
    elseif est_snr_db(ll) >= 50
        per = 75;
    elseif est_snr_db(ll) >= 40
        per = 75;
    elseif est_snr_db(ll) >= 30
        per = 80;
    elseif est_snr_db(ll) >= 20
        per = 70;
    else
        per = 80;
    end
    value(ll) = prctile(mFullLogSNRPrio(mostImportantBins,ll),per);
end

% Everything smaller than percentile limit is set to minimum; could be done
% per frame maybe -> further work has to be done
bm = mFullLogSNRPrio(:,:) < value(:)'; % binary mask
mFullLogSNRPrio(bm) = min(mFullLogSNRPrio(:));
mFullLogSNRPrio(:,isOVS==1) = min(mFullLogSNRPrio(:));

% Set factors dependent on 'overall level'
fac = 0.5.*ones(length(vIndices),1);
fac(est_snr_db >= 20) = 0.2;
fac(est_snr_db >= 30) = 0.5;
fac(est_snr_db >= 40) = 0.5;
fac(est_snr_db >= 50) = 0.4;

winLen = floor(2048/10);
meanLogSNRPrioMax = movmax(mean(mFullLogSNRPrio(mostImportantBins, :),1)',winLen);
meanLogSNRPrioMean = movmean(mean(mFullLogSNRPrio(mostImportantBins, :),1)',winLen);

stDataReal.adapThresh = (fac.*meanLogSNRPrioMax + (1-fac).* meanLogSNRPrioMean);
isFVSThreshold = mean(mFullLogSNRPrio(mostImportantBins, :),1)' ...
    >= stDataReal.adapThresh;

% Everything thats smaller than threshold gets kicked out
vIndices(~isFVSThreshold) = [];

% Hold-like algorithm
nOrder = 4;
isFVS = zeros(size(mFullLogSNRPrio,2),1);
preOnes = nOrder;
postOnes = nOrder; 
vIndexHoldRange= -preOnes:postOnes;
vHoldIndicesFVS = zeros(length(vIndices),(preOnes+postOnes+1));

if ~isempty(vIndices)
    
    % Add range to
    for ii = 1:preOnes+postOnes+1
        vHoldIndicesFVS(:,ii) = vIndices'+vIndexHoldRange(ii);
    end
    
    vHoldIndicesFVS = unique(vHoldIndicesFVS(:));
    vHoldIndicesFVS(vHoldIndicesFVS <= 0) = [];
    vHoldIndicesFVS(vHoldIndicesFVS > size(mFullLogSNRPrio,2)) = [];
    isFVS(vHoldIndicesFVS) = 1;
end
stDataReal.vFVS = logical(isFVS(:) & ~isOVS(:))';
stDataReal.vFVS = filter([1 1 1 1 1 1 1 1]./8,1,stDataReal.vFVS);
stDataReal.vFVS(stDataReal.vFVS >= 0.4) = 1;
stDataReal.vFVS(stDataReal.vFVS < 0.4) = 0;
