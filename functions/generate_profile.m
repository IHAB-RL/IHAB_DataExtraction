function generate_profile(szSubjectID, isObjective, obj)

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
    set(groot, 'defaultFigureVisible', 'Off')

    if ~isempty(obj.stSubject.Folder)
        
        %% Personal Profile:
        PersonalProfile(obj);
        
        if isObjective        
           
            szFeature = 'RMS';
            tableDates = getdatesonesubject(obj);
            numDates = length(tableDates.(obj.stSubject.Name));
            
            
            hProgress = BlindProgress(obj);
            
%             offset = numDates * 1.1;
            for nDate = 1:numDates
%                 clc; progress_bar(nDate, numDates + offset, 5, 5)
                dateDay = tableDates.(obj.stSubject.Name)(nDate);
                
                % Get all available parts for each day and each subject
                % To do this, set desiredPart variable to zero (last variable)
                [~, ~, iNrOfParts] = getObjectiveDataOneDay(obj, dateDay, szFeature,0);
                
                % Loop over all parts of one day for one subject
                for jj = 1:iNrOfParts
                    
%                     fprintf('Computing Fingerprint %d of %d.\n', jj, iNrOfParts);
                    
                   
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
                            filesep, szSubjectID, ...
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
        end % if qOnly
        
        
        
        
        
        obj.hProgress.stopTimer();  
        obj.cListQuestionnaire{end} = sprintf('\t.merging graphic objects -');
        obj.hListBox.Value = obj.cListQuestionnaire;
        obj.hProgress.startTimer();

        
        %% Merge PDFs:
   
%         mergeAndCompilePDFLatex(obj);
        
%         % get pdfs
%         pdf_files = dir([obj.stSubject.Folder filesep 'graphics', filesep, '*.pdf']);
% 
%         % filter out previous Profiles
%         prev_pp = strfind({pdf_files.name}, 'Personal')';
%         prev_pp(cellfun(@isempty, prev_pp)) = {0};
%         prev_pp = cell2mat(prev_pp);
%         prev_pp = ~logical(prev_pp);
%         pdf_files = pdf_files([prev_pp]);
% 
%         % sort pdfs
%         % date with seconds is too crude, use datenum or numbered filename!
%         [~,index] = sortrows({pdf_files.name}.'); 
%         pdf_files = pdf_files(index); 
%         clear index
% 
%         for filesIdx = 1:length(pdf_files)
%             
%             % append to final list
%             input_list{filesIdx, :} = fullfile(pdf_files(filesIdx).folder, ... 
%                     pdf_files(filesIdx).name);
%            
%         end
% 
%         date_name = datestr(datetime(), 'dd.mm.yy');
%         
%         if isObjective == 0
%             file_name = ([obj.stSubject.Folder, filesep 'graphics', filesep, 'Personal_Profile_',...
%                 szSubjectID '_Quest_' date_name '.pdf']);
%             append_pdfs(file_name, input_list{:})
%         else
%             file_name = ([obj.stSubject.Folder, filesep, 'graphics', filesep, 'Personal_Profile_',...
%                 szSubjectID '_Aku_' date_name '.pdf']);
%             append_pdfs(file_name, input_list{:})
%         end
%         
%         % sk180522: delete temporary PDFs
%         for iFile = 1:length(input_list)
%             delete(input_list{iFile});
%         end 
%           
%         
%         

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
