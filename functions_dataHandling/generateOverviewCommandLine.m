function [] = generateOverviewCommandLine(obj)

% Version 1.0 Data Availibility is displayed
% Version 1.1 GUI integration

% ToDo:
% 1) to get more from the data
%    a) color-code the speech understanding
%    b) marker-size for the importace (or other parts)

%szBaseDir = fullfile(pwd,'ObjectiveDataAnalysisToolbox','HALLO_EMA2016_all');


fprintf('\t.analysing subject data -');
obj.hProgressCommandLine.startTimer();


subjectMatFile = fullfile(obj.stSubject.Folder,...
    [obj.stSubject.Name '.mat']);
if exist(subjectMatFile, 'file')
    load(subjectMatFile);
else
    warning('Subject mat file %s.mat not found', obj.stSubject.Name)
    return;
end

% Feature Data PSD
[dateVecAllFeatPSD,UniqueDaysFeatPSD] = showAvailableFeatureDataOneTestSubject(obj, 'PSD');

if isempty(dateVecAllFeatPSD)
    return;
end

dateVecDayOnlyFeatPSD = dateVecAllFeatPSD-timeofday(dateVecAllFeatPSD);
AllDates = getdatesonesubject(obj);


    % Feature Data RMS
    [dateVecAllFeatRMS,UniqueDaysFeatRMS] = showAvailableFeatureDataOneTestSubject(obj, 'RMS');
    dateVecDayOnlyFeatRMS= dateVecAllFeatRMS-timeofday(dateVecAllFeatRMS);
    
    % Feature Data ZCR
    [dateVecAllFeatZCR,UniqueDaysFeatZCR] = showAvailableFeatureDataOneTestSubject(obj, 'ZCR');
    dateVecDayOnlyFeatZCR= dateVecAllFeatZCR-timeofday(dateVecAllFeatZCR);


numAvailableDataAllDays = zeros(length(AllDates),1);
numInvalidDay = zeros(length(AllDates),1);
percentInvalidDay = zeros(length(AllDates),1);
txtFile = fullfile(obj.stSubject.Folder,[obj.stSubject.Name '.txt']);

%if exist(txtFile, 'file')
%    delete(txtFile);
%end

%fid = fopen(txtFile,'wt');

% Gather statistical data for report
obj.stAnalysis.NumberOfDays = length(AllDates);
obj.stAnalysis.Dates = AllDates;

for kk = 1:length(AllDates)
    PartCounter = 0;
    %         % first plot feature data
    idx = find(dateVecDayOnlyFeatPSD == AllDates(kk));
    if ~isempty(idx) && length(idx) > 1
        %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
        
        dtMinutes = minutes(diff(dateVecAllFeatPSD(idx)));
        idx2 = find (dtMinutes> 1.1);
        if (isempty(idx2))
           
        else
            
            PartCounter = 1;
            % Andinbetween
            for pp = 1:length(idx2)-1
               
                PartCounter = PartCounter+1;
            end
            
        end
        
        
    end
    
    % Gather statistical data for report
    obj.stAnalysis.NumberOfParts(kk) = PartCounter+1;
    
    %if ~printMode
        
        %% now rms
        idx = find(dateVecDayOnlyFeatRMS == AllDates(kk));
        if ~isempty(idx) && length(idx) > 1
            %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
            
            idx2 = find (dtMinutes> 1.1);
            if (isempty(idx2))
                
            else
                
                PartCounter = 1;
                % Andinbetween
                for pp = 1:length(idx2)-1
                    
                    PartCounter = PartCounter+1;
                end
                %last part
                
            end
        end
        
        % now ZCR
        idx = find(dateVecDayOnlyFeatZCR == AllDates(kk));
        if ~isempty(idx) && length(idx) > 1
            %plot(dateVecAll(idx)-UniqueDays(kk),kk,'x');
            
            if (isempty(idx2))
                
            else
               
                PartCounter = 1;
                % Andinbetween
                for pp = 1:length(idx2)-1
                    
                    PartCounter = PartCounter+1;
                end
               
            end
        end
    %end
    
    
    
    % plot error codes
    
    % Filter for PSD feat files since no second arguments is given to
    % Filename2date; also get back the indices of PSD files only
    [dateFilenames,isFeatFile] = Filename2date(stSubject.chunkID.FileName);
    
    % Now since you have the indices, you have to filter the error
    % codes to get the respective ones
    filteredErrorCodes = stSubject.chunkID.ErrorCode(isFeatFile);
    filteredECColors = stSubject.chunkID.PercentageError(isFeatFile);
    
    % Get only the dates of the current day ...
    currentDayIndexes = ...
        find(dateFilenames-timeofday(dateFilenames) == AllDates(kk));
    
    if isempty(currentDayIndexes)
        continue;
    end
    
    currentDays = dateFilenames(currentDayIndexes);
    onlyTimeOfDay = timeofday(currentDays);
    
    % ... and again filter also the error codes
    currentErrorCodes = filteredErrorCodes(currentDayIndexes);
    currentECColors = filteredECColors(currentDayIndexes);
    
    if ~iscell(currentErrorCodes)
        currentErrorCodes = num2cell(currentErrorCodes);
    end
    
    % CURRENTLY unused (especially in black/white mode)
    if ~iscell(currentECColors)
        currentECColors = num2cell(currentECColors);
    end
    
    numAvailableDataAllDays(kk) = length(currentErrorCodes);
    strHoursAvailableDataCurrentDay = ...
        num2str(round(10*numAvailableDataAllDays(kk)/60)/10);
    validChunkIndices = cell2mat(cellfun(@(x) ~isempty(find(x == 0, 1)),...
        currentErrorCodes, 'UniformOutput', false));
    invalidChunkIndices = ~validChunkIndices;
    currentErrorCodesValid = currentErrorCodes;
    currentErrorCodesInvalid = currentErrorCodes;
    currentErrorCodesValid(invalidChunkIndices) = {NaN};
    currentErrorCodesInvalid(validChunkIndices) = {NaN};
    
    % Get number of invalid data per day
    validCounter = 0;
    for ii = 1:length(currentErrorCodes)
        if currentErrorCodesValid{ii} == 0
            validCounter = validCounter + 1;
        end
    end
    numInvalidDay(kk) = numAvailableDataAllDays(kk) - validCounter;
    percentInvalidDay(kk) = numInvalidDay(kk)/numAvailableDataAllDays(kk);

    
    % Gather statistical data for report
    obj.stAnalysis.TimePerDay(kk) = round(numAvailableDataAllDays(kk)*60);
    
    nMargin = 2.25-0.25*obj.stAnalysis.NumberOfDays;
    



% Write information on validity per day to file
totalHours = num2str(round(10*sum(numAvailableDataAllDays)/60)/10);
percentInvalidTotal = sum(numInvalidDay)/sum(numAvailableDataAllDays);
strValidDataTotal = num2str(round(100*(1-percentInvalidTotal))/100);


obj.hProgressCommandLine.stopTimer();

end
% EOF