
%VALIDATEALLSUBJECTS.m
% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 21-Dec-2017 			 NS
% ---------------------------------------------------------
%addpath(fullfile('..','DataAvailibility'));
%szBaseDir = fullfile('..','HALLO_EMA2016_all');
szSubjects= getallsubjects(szBaseDir);

% configStruct.lowerBinMSC = 1100;
% configStruct.upperBinMSC = 3000;
% configStruct.upperThresholdMSC = 0.9;
% %configStruct.lowerThresholdMSC = 0.2;
% %configStruct.thresholdRMSforMSC = -40; % -40 dB
% configStruct.upperThresholdRMS = -6; % -6 dB
% configStruct.lowerThresholdRMS = -70; % -60 dB
% configStruct.errorTolerance = 0.05; % 2 percent

for ii = 1:numel(szSubjects)
    fprintf(1,'============= %s =============\n',szSubjects{ii}.SubjectID);
    tableSubject = validatesubject(fullfile(szBaseDir,...
                       szSubjects{ii}.FolderName),...
                       configStruct);
    %AnalyseSubjectsResponses(ii);
end

%rmpath(fullfile('..','DataAvailibility'));
% EOF validateallsubjects.m