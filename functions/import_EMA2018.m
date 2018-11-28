function [] = import_EMA2018(obj, folder_idx)

% Import subjects' XML questionnaires data.
%
% Parameters
% ----------
% szSubjectID : string
%	subject to be analyzed
%
% folder_idx :
%   optional, not required when running individually
%
% Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF

%     if nargin < 2
%
%         folder_idx = 1;
%
%     end


% load answers and codes
load('Answers_EMA2018.mat', 'PossibleAnswers')

% pre-allocate
Questionnaires = struct(...
    'FileName', [],...
    'SubjectID', [],...
    'Day', [],...
    'Date', [],...
    'Start', [],...
    'End', [],...
    'Duration', [],...
    'Situation', [],...
    'Manual_Input', {},...
    'AssessDelay', [],...
    'Mood', [],...
    'Activity', []);

% .csv and .mat file name
csv_mat_file_name = ['Questionnaires_' obj.stSubject.Name];

%     folder_path = dir([obj.stSubject.Folder, '*']);

%
%     % for subjects with multiple days
%     if length(folder_path) > 1 && nargin < 2
%
%         input_string = {folder_path.name};
%         [folder_idx, cancel_button] = listdlg('PromptString','Select a directory:',...
%             'SelectionMode','single',...
%             'ListString', input_string);
%
%         if cancel_button ~= 0
%             folder_path = folder_path(folder_idx);
%         else
%             return
%         end
%     else
%         folder_path = folder_path(folder_idx);
%     end

% ... another path
%     fullpath = [main_path filesep folder_path.name filesep obj.stSubject.Name '_Quest'];

fullpath = [obj.stSubject.Folder, filesep, obj.stSubject.Name '_Quest'];
% list of all questionnaires
quests_list = dir([fullpath, '/*.xml']);

Questionnaires_idx = 1;
source_number = 1;
source_idx = 0;

% loop over each questionnaire
for quests_idx = 1 : length(quests_list)
    
    % subject's ID
    Questionnaires(Questionnaires_idx).SubjectID = obj.stSubject.Name;
    
    % questionnaire's name
    quest_name = sprintf(quests_list(quests_idx).name);
    Questionnaires(Questionnaires_idx).FileName = quest_name;
    
    % parse questionnaire
    xml = xmlread([fullpath filesep quests_list(quests_idx).name]);
    document = parse_xml(xml);
    record = document.children{1}.children{2};
    
    % starting date and time
    quest_date_1 = record.children{2}.attributes.start_date(1:10);
    Questionnaires(Questionnaires_idx).Date = quest_date_1;
    quest_time_1 = record.children{2}.attributes.start_date(end-7:end);
    Questionnaires(Questionnaires_idx).Start = quest_time_1;
    
    % ending date and time
    quest_time_2 = record.children{31}.attributes.end_date(end-7:end);
    Questionnaires(Questionnaires_idx).End = quest_time_2;
    quest_date_2 = record.children{31}.attributes.end_date(1:10);
    start_time = strcat(quest_time_1(1:2), quest_time_1(4:5), quest_time_1(7:8));
    end_time = strcat(quest_time_2(1:2), quest_time_2(4:5), quest_time_2(7:8));
    start_end_time(1, 1) = datetime(start_time, 'InputFormat', 'HHmmss');
    start_end_time(1, 2) = datetime(end_time, 'InputFormat', 'HHmmss');
    time_interval = diff(start_end_time);
    
    % if recording took place over night...
    if time_interval < 0
        
        time_interval = time_interval * -1;
        time_shift = duration(12,0,0);
        time_interval = time_interval + time_shift;
        
    elseif quest_date_2 - quest_date_1 >= duration(24, 0, 0)
        
        time_interval = (quest_date_2 - quest_date_1) + time_interval;
        
    end
    
    % duration of questionnaire
    Questionnaires(Questionnaires_idx).Duration = char(time_interval);
    
    % start questions
    for question_idx = 5 : 30
        
        % safety check
        if isfield(record.children{question_idx}.attributes, 'option_ids') == 1
            
            % get answer
            answer = record.children{question_idx}.attributes.option_ids;
            
            % check for single answer
            if length(answer) < 8
                
                answer = cell2mat(PossibleAnswers.code(1, strcmp(PossibleAnswers.id, answer)));
                
                
            end
            
            % go to specific question
            switch question_idx
                
                case 5 % Wie viele Minuten liegt das Ereignis zurueck ?
                    Questionnaires(Questionnaires_idx).AssessDelay = answer;
                    
                case 6 % Wie ist Ihre momentane Stimmung ?
                    Questionnaires(Questionnaires_idx).Mood = answer;
                    
                case 7 % Welche Situation trifft zu ?
                    Questionnaires(Questionnaires_idx).Situation = answer;
                    
                case 8 % Zu Hause - und zwar:
                    Questionnaires(Questionnaires_idx).Activity = answer;
                    
                case 9 % Unterwegs - und zwar:
                    Questionnaires(Questionnaires_idx).Activity = answer;
                    
                case 10 % Gesellschaft und Erledigungen - und zwar:
                    Questionnaires(Questionnaires_idx).Activity = answer;
                    
                case 11 % Beruf - und zwar:
                    Questionnaires(Questionnaires_idx).Activity = answer;
                    
                case 12 % Bitte beschreiben Sie die Situation.
                    Questionnaires(Questionnaires_idx).Manual_Input = answer;
                    
                case 13 % Von wem oder was kommt Schall?
                    
                    % check for multiple answers
                    if ~ischar(answer)
                        
                        Questionnaires(Questionnaires_idx).Source_1 = answer;
                        
                    else
                        
                        % split multiple answers
                        splitmirror = regexp(answer, ';', 'split');
                        
                        % add each answer
                        for source_idx = 1 : length(splitmirror)
                            
                            Questionnaires(Questionnaires_idx).(sprintf('Source_%d', source_number)) =...
                                cell2mat(PossibleAnswers.code(1,(find(strcmp(PossibleAnswers.id,splitmirror(source_idx))))));
                            
                            source_number = source_number + 1;
                            
                        end
                        
                        source_number = 1;
                        
                    end
                    
                case 14 % Wem oder was hoeren Sie hauptsaechlich zu?
                    Questionnaires(Questionnaires_idx).Target_Source = answer;
                    
                case 15 % Von wem oder was kommt Schall?
                    
                    % check for multiple answers
                    if ~ischar(answer)
                        
                        Questionnaires(Questionnaires_idx).Source_1 = answer;
                        
                    else
                        
                        % split multiple answers
                        splitmirror = regexp(answer, ';', 'split');
                        
                        % add each answer
                        for source_idx = 1 : length(splitmirror)
                            
                            Questionnaires(Questionnaires_idx).(sprintf('Source_%d', source_number)) =...
                                cell2mat(PossibleAnswers.code(1,(find(strcmp(PossibleAnswers.id,splitmirror(source_idx))))));
                            
                            source_number = source_number + 1;
                            
                        end
                        
                        source_number = 1;
                        
                    end
                    
                case 16 % Wem oder was hoeren Sie hauptsaechlich zu?
                    Questionnaires(Questionnaires_idx).Target_Source = answer;
                    
                case 17 % Von wem oder was kommt Schall?
                    
                    % check for multiple answers
                    if ~ischar(answer)
                        
                        Questionnaires(Questionnaires_idx).Source_1 = answer;
                        
                    else
                        
                        % split multiple answers
                        splitmirror = regexp(answer, ';', 'split');
                        
                        % add each answer
                        for source_idx = 1 : length(splitmirror)
                            
                            Questionnaires(Questionnaires_idx).(sprintf('Source_%d', source_number)) =...
                                cell2mat(PossibleAnswers.code(1,(find(strcmp(PossibleAnswers.id,splitmirror(source_idx))))));
                            
                            source_number = source_number + 1;
                            
                        end
                        
                        source_number = 1;
                        
                    end
                    
                case 18 % Wem oder was hoeren Sie hauptsaechlich zu?
                    Questionnaires(Questionnaires_idx).Target_Source = answer;
                    
                case 19 % Von wem oder was kommt Schall?
                    
                    % check for multiple answers
                    if ~ischar(answer)
                        
                        Questionnaires(Questionnaires_idx).Source_1 = answer;
                        
                    else
                        
                        % split multiple answers
                        splitmirror = regexp(answer, ';', 'split');
                        
                        % add each answer
                        for source_idx = 1 : length(splitmirror)
                            
                            Questionnaires(Questionnaires_idx).(sprintf('Source_%d', source_number)) =...
                                cell2mat(PossibleAnswers.code(1,(find(strcmp(PossibleAnswers.id,splitmirror(source_idx))))));
                            
                            source_number = source_number + 1;
                            
                        end
                        
                        source_number = 1;
                        
                    end
                    
                case 20 % Wem oder was hoeren Sie hauptsaechlich zu?
                    Questionnaires(Questionnaires_idx).Target_Source = answer;
                    
                case 21 % Wie gut h?ren Sie, woher einzelne Geraeusche kommen?
                    Questionnaires(Questionnaires_idx).Direction = answer;
                    
                case 22 % Wie wichtig ist es, in der Situation gut zu hoeren?
                    Questionnaires(Questionnaires_idx).Importance = answer;
                    
                case 23 % Wie anstrengend ist es zuzuhoeren?
                    Questionnaires(Questionnaires_idx).ListeningEffort = answer;
                    
                case 24 % Wie laut ist es?
                    Questionnaires(Questionnaires_idx).LoudnessRating = answer;
                    
                case 25 % Wie angenehm sind die Geraeusche/Klaenge?
                    Questionnaires(Questionnaires_idx).Pleasantness = answer;
                    
                case 26 % Wie gut oder schlecht verstehen Sie?
                    Questionnaires(Questionnaires_idx).SpeechUnderstanding = answer;
                    
                case 27 % Sind Ihnen die Stimmen vertraut?
                    Questionnaires(Questionnaires_idx).SpeechFamiliarity = answer;
                    
                case 28 % Fuehlen Sie sich mitten in der Gespraechssituation?
                    Questionnaires(Questionnaires_idx).Participate = answer;
                    
                case 29 % Wie sehr sind andere Menschen durch Ihr Hoerproblem belaestigt?
                    Questionnaires(Questionnaires_idx).Bother = answer;
                    
                case 30 % Wie sehr fuehlen Sie sich beeintraechtigt?
                    Questionnaires(Questionnaires_idx).Impaired = answer;
                    
            end
            
        end
        
    end
    
    Questionnaires_idx = Questionnaires_idx + 1;
    
end

% sort by date ...
[~, idx] = sortrows({Questionnaires.Date}.');
Questionnaires = Questionnaires(idx);
clear idx

% then group subjects
[~, idx] = sortrows({Questionnaires.SubjectID}.');
Questionnaires = Questionnaires(idx);
clear idx

idx_1 = 1;

% add numbered day(s)
for idx_2 = 2 : length(Questionnaires)
    
    Questionnaires(idx_2-1).Day = idx_1;
    
    if ~strcmp(Questionnaires(idx_2-1).Date, Questionnaires(idx_2).Date)
        idx_1 = idx_1 + 1;
    end
    
    if ~strcmp(Questionnaires(idx_2-1).SubjectID, Questionnaires(idx_2).SubjectID)
        idx_1 = 1;
    end
    
    if strcmp(Questionnaires(idx_2-1).Date, Questionnaires(idx_2).Date) || idx_2 == length(Questionnaires)
        Questionnaires(length(Questionnaires)).Day = idx_1;
    end
    
end

% replace missing answers with code '222'
for Questionnaires_idx = 1 : length(Questionnaires)
    
    % get columns names
    headers = fieldnames(Questionnaires);
    
    for idx = 1 : length(headers)
        
        if isempty(Questionnaires(Questionnaires_idx).(headers{idx}))
            
            if strcmp(headers{idx}, 'Manual_Input')
                
                Questionnaires(Questionnaires_idx).(headers{idx}) = '222';
                
            else
                
                Questionnaires(Questionnaires_idx).(headers{idx}) = 222;
                
            end
            
        end
        
    end
    
end

% create table type variable
QuestionnairesTable = struct2table(Questionnaires);

% sort when multiple sources were selected
for idx = 1 : source_idx
    QuestionnairesTable = sort_columns(QuestionnairesTable);
end

% export .mat and .csv files
save([obj.stSubject.Folder filesep csv_mat_file_name '.mat'], 'QuestionnairesTable');
writetable(QuestionnairesTable, ...
    [obj.stSubject.Folder filesep csv_mat_file_name '.csv'], 'Delimiter',';');

end

%--------------------Licence ---------------------------------------------
% Copyright (c) <2017> AGA
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