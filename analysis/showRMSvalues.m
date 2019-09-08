clear
close all
stop(timerfind)
addpath('..');

szBaseDir = 'F:\Results';

szDir = dir(szBaseDir);
szDir(1:2) = [];

idnotworking = {'42650bd3946fe61' ; 'ba8f73649f053a54'};
idworking = {'2b3a1a35e79d875'; '1134421551e533bf'};

System1old =  {'1 gelb', '1a86ba860e4d78cd', [115 118]};
System1 =  {'System1','d8146f21555bd95f', [104 104]};
System2 =  {'System2','',[]};
%System3 =  {'System3','46891209dc640abe', [105 108]};
System3 =  {'System3','1134421551e533bf', [105 108]};
System4 =  {'System4' '2b3a1a35e79d875' , [103 104]};

for dd = 1:length(szDir)
    szMatFile = [szBaseDir filesep szDir(dd).name]
    load (szMatFile);
    
    if (any(strcmp(idworking,obj.stAnalysis.DeviceID)))
        if (strcmp(System1old{2},obj.stAnalysis.DeviceID))
            Correctionvalues = System1old{3};
        elseif (strcmp(System1{2},obj.stAnalysis.DeviceID))
            Correctionvalues = System1{3};
        elseif (strcmp(System2{2},obj.stAnalysis.DeviceID))
            Correctionvalues = System2{3};
        elseif (strcmp(System3{2},obj.stAnalysis.DeviceID))
            Correctionvalues = System3{3};
        elseif (strcmp(System4{2},obj.stAnalysis.DeviceID))
            Correctionvalues = System4{3};
        end
        idx = (20*log10(AllData(:,1))<-82);
        AllData(idx,:) = [];
        AllTime(idx) = [];
        AllData = 20*log10(AllData) + Correctionvalues;
        figure; plot(AllTime,AllData); title(obj.stSubject.Name)
%        figure; histogram(AllData,100); title ([obj.stSubject.Name ' ' obj.stAnalysis.DeviceID ' ' string(analDate)]);
        f = figure; histogram(AllData,100); title ([obj.stSubject.Name ' ' string(analDate)]);
        xlim([20 105]);
        xlabel('Level in dB SPL (25ms blocks, unweighted)')
        ylabel('Occurances')
        set(f,'Position',[360 198 round(2/3*560) round(2/3*420)]);
        drawnow;
    end
    
    
end

