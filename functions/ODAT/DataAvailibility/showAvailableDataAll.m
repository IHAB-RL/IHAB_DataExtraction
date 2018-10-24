clear
close all
addpath('../Tools');

% get data for one test subject
szBaseDir = '../HALLO_EMA2016_all';
%szProbandName = 'AS05EB18';
szProbandName = 'CK09LM19';
szFeatData = 'RMS';

[dateVecAll,UniqueDays] = showAvailableFeatureDataOneTestSubject(szBaseDir,szProbandName,szFeatData);
dateVecDayOnly= dateVecAll-timeofday(dateVecAll);
figure; 
for kk = 1:length(UniqueDays)
    
    idx = find(dateVecDayOnly == UniqueDays(kk));
    %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
    hold on;
    dtMinutes = minutes(diff(dateVecAll(idx)));
    idx2 = find (dtMinutes> 2);
    if (isempty(idx2))
        plot([dateVecAll(idx(1))-UniqueDays(kk) dateVecAll(idx(end))-UniqueDays(kk)],[kk kk],'r-X');
    else
        disp('At least two parts during this day')
        UniqueDays(kk)
    end
end
set(gca,'YTick',1:length(UniqueDays));
set(gca,'YTickLabel',datestr(UniqueDays));
rmpath('../Tools')    
    

