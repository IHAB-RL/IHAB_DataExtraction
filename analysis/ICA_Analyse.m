
clear
close all

addpath('..');

computeNew = 1;
%szPersonDir = 'F:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018\EK06DI26_180905_aw';
%szPersonDir = 'F:\IHAB_2_EMA2018\IHAB_Rohdaten_EMA2018\ES04CH28_190423_aw';
%szPersonDir =

%'F:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018\HM06LM23_181112_aw'; %
%funktioniert nicht, wegen Problem mit chunkID Nr 11 in der Liste (vorletzte TE funktioniert auch nicht)



szPersonDir = 'F:\HALLO_EMA2016\EMA_Rohdaten\CH04RT10_161122_fs';
szBaseDir ='F:\IHAB_1_EMA2018\IHAB_Rohdaten_EMA2018';
szOut = 'F:\Results';
szDir = dir(szBaseDir);
szDir(1:3) = [];
for dd = length(szDir):length(szDir)
    szPersonDir = [szBaseDir filesep szDir(dd).name]
    if (computeNew)
        obj = IHABdata(szPersonDir);
        save OnePerson obj
    else
        load OnePerson
    end
    obj.stAnalysis
    
    AllData = [];
    AllTime = [];
    for kk = 1: obj.stAnalysis.NumberOfDays
        %for kk = 1: 2
        AllData = [];
        AllTime = [];
        analDate =obj.stAnalysis.Dates(kk)
        NrOfParts = obj.stAnalysis.NumberOfParts(kk)
        if NrOfParts == 0
            NrOfParts = 1;
        end
        
        for pp = 1:NrOfParts
            
            [Data, TimeVec, NrOfParts] =...
                getObjectiveDataOneDay(obj, analDate, 'RMS', pp);
            AllTime = [AllTime; TimeVec];
            AllData = [AllData; Data];
            %figure; plot(TimeVec,10*log10(Data));drawnow;
        end
        %figure; plot(AllTime,10*log10(AllData));drawnow;
        %figure; histogram(10*log10(AllData),100); title (string(analDate))
        save([szOut filesep obj.stSubject.Name '_' num2str(kk)],'obj', 'AllTime', 'AllData','kk','analDate');
    end
end
stop(timerfind)
