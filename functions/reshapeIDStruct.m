
sFileName_in = 'E:\IHAB_DataExtraction\functions\IdentificationProbandSystem.mat';
sFileName_old = 'E:\IHAB_DataExtraction\functions\IdentificationProbandSystem_old.mat';
load('E:\IHAB_DataExtraction\functions\IdentificationProbandSystem.mat')

stSubject = struct('ID', [], ...
        'System', []);
nSubject = length(stProband.ID);

for iSubject = 1:nSubject
  
    stSubject(iSubject).ID = stProband.ID(iSubject);
    stSubject(iSubject).System = stProband.SMS(iSubject);
     
end

stTemp = stSystem;
stSystem = struct('Name', [], 'Calib', []);
nSystem = length(stTemp.name);

for iSystem = 1:nSystem
   
    stSystem(iSystem).Name = stTemp.name{iSystem};
    stSystem(iSystem).Calib = stTemp.calib{iSystem};
    
end

movefile(sFileName_in, sFileName_old);
save(sFileName_in, 'stSubject', 'stSystem');

