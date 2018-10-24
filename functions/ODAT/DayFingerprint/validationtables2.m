clearvars;
close all;

% Import paths of necessary functions
addpath('../Tools');
addpath('../DroidFeatureTools');

szDir = fullfile('..','HALLO_EMA2016_all');
allSubjects = getallsubjects(szDir);
numSubjects = numel(allSubjects);

for subjectIdx = 1:numSubjects
    
    %     fid = fopen(fullfile(szDir,allSubjects{subjectIdx}.FolderName,...
    %                          [allSubjects{subjectIdx}.SubjectID '.txt']),'a+');
    
    partsList = listFiles(...
        fullfile(szDir,allSubjects{subjectIdx}.FolderName),'*p*.mat',1);
    
    if isempty(partsList)
        continue;
    end
    
    partsList = {partsList.name};
    
    for idx = 1:numel(partsList)
        [szPath,dateString,~] = fileparts(partsList{idx});
        dateAndPart = regexp(dateString,'[0-9]+_[0-9]+_[0-9]+_p\d*','match');
        splitDate = split(dateAndPart,'_');
        day = str2double(splitDate(1));
        month = str2double(splitDate(2));
        year = str2double(splitDate(3));
        allDates(idx).Date = datetime(year,month,day);
        allDates(idx).Part = str2double(regexp(splitDate(4),'\d*','match'));
    end
    
    [numParts,dateDay]= hist(datenum([allDates.Date]),datenum(unique([allDates.Date])));
    numUniqueDays = length(numParts);
    
    for kk = 1:numUniqueDays
        dates(kk).dateDay = datetime(dateDay(kk),'ConvertFrom','datenum');
        dates(kk).numParts = numParts(kk);
    end
    
    
    
    for ii = 1:numUniqueDays
        for jj = 1:dates(ii).numParts
            load(fullfile(szPath,...
                [allSubjects{subjectIdx}.SubjectID '_FinalDat_' ...
                num2str(dates(ii).dateDay.Day) '_'...
                num2str(dates(ii).dateDay.Month) '_' ...
                num2str(dates(ii).dateDay.Year) '_p' num2str(jj) '.mat']));
        end
    end
    
    if exist('stSubject', 'var')
        clear stSubject;
    end
end

% Import paths of necessary functions
rmpath('../Tools');
rmpath('../DroidFeatureTools');