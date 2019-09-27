function fSNR=compute_snr(fvs, snrPrio)
tmpSNRPrio = snrPrio;
tmpSNRPrio(tmpSNRPrio >= 10^(35/10)) = 10^(35/10);
fSNR= movmean(movmax(10.*log10(mean(tmpSNRPrio(:,fvs==1))),50),100);