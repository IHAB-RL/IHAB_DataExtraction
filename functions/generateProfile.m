function generateProfile(obj)

    % Combine all fingerprints within szDir into one pdf file.
    %
    % GUI IMPLEMENTATION UK
    %
    % Parameters
    % ----------
    % szSubjectID : string
    %	subject ID
    % isObjective : boolean
    %   false: ignore objective data
    %
    % Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF 
    % 
    % sk180522: delete temporary PDFs
    % sk180529: parameter to ignore objective data, minor fixes
    %           sort file according to running number
    
    
    % prevent figures from appearing
    %set(groot, 'defaultFigureVisible', 'Off')

    if ~isempty(obj.stSubject.Folder)
        
        %% Personal Profile:
        generateDiagrams(obj);
        
        if obj.bIncludeObjectiveData        
           
            szFeature = 'RMS';
            tableDates = getdatesonesubject(obj);
            numDates = length(tableDates.(obj.stSubject.Name));
            
            
            hProgress = BlindProgress(obj);
            
            for nDate = 1:numDates
                dateDay = tableDates.(obj.stSubject.Name)(nDate);
                
                % Get all available parts for each day and each subject
                % To do this, set desiredPart variable to zero (last variable)
                [~, ~, iNrOfParts] = getObjectiveDataOneDay(obj, dateDay, szFeature,0);
                
                % Loop over all parts of one day for one subject
                for jj = 1:iNrOfParts
                   
                    hProgress.stopTimer();
                    obj.cListQuestionnaire{end} = sprintf('\t.generating fingerprint of day %d, part %d of %d -', nDate, jj, iNrOfParts);
                    obj.hListBox.Value = obj.cListQuestionnaire;
                    hProgress = BlindProgress(obj);
                    
                    computeDayFingerprintData(obj, dateDay, jj, 0);
                    
                    if ~exist([obj.stSubject.Folder filesep 'graphics', filesep, ...
                            'Fingerprint_', obj.stSubject.Name, ...
                            '_' num2str(day(dateDay)), '_', ...
                            num2str(month(dateDay)), '_', ...
                            num2str(year(dateDay)), ...
                            '_p', num2str(jj), '.pdf'],'file') &&... % Check also whether a mat file was produced % UK
                            exist([obj.stSubject.Folder filesep 'cache', ...
                            filesep, obj.stSubject.Name, ...
                            '_FinalDat_', num2str(day(dateDay)), '_', ...
                            num2str(month(dateDay)), '_', ...
                            num2str(year(dateDay)), ...
                            '_p', num2str(jj), '.mat'],'file') 
                        
                        % Fingerprint   plotAllDayFingerprints(obj, szQuestionnaireName, ~, dateDay, iPart, bPrint, hasSubjectiveData)
                        plotAllDayFingerprints(obj, dateDay, jj, 1)
                        
                        % After plotting, delete .mat file
                        delete([obj.stSubject.Folder, filesep, 'cache', ...
                            filesep, obj.stSubject.Name, ...
                            '_FinalDat_', num2str(day(dateDay)), '_', ...
                            num2str(month(dateDay)), '_', ...
                            num2str(year(dateDay)), ...
                            '_p', num2str(jj), '.mat']);
                    end
                end
            end
        end 
        
        obj.hProgress.stopTimer();  
        obj.cListQuestionnaire{end} = sprintf('\t.merging graphic objects -');
        obj.hListBox.Value = obj.cListQuestionnaire;
        obj.hProgress.startTimer();

    else
       
        obj.hProgress.stopTimer();
        obj.cListQuestionnaire{end} = sprintf('    Essential files missing.');
        obj.hListBox.Value = obj.cListQuestionnaire;
        
    end
    
    set(groot, 'defaultFigureVisible', 'On')
    
    obj.hProgress.stopTimer();  
    
end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2018> AGA
% Jade University of Applied Sciences 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files 
% (the "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject
% to the following conditions:
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
