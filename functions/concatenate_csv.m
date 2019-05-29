function concatenate_csv()

    % Combine .csv tables from all subjects into one .csv file in 'IHAB_Rohdaten_EMA2018' folder.
    %
    % Output
    % ----------
    % .csv file
    %	default name 'All_Questionnaires_dd-mm-yyyy.csv'
    %
    % Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF 
    
    % get all csv files and read the first one
    csv_files = dir([cd filesep 'IHAB_Rohdaten_EMA2018' filesep '**' filesep 'Questionnaires_*.mat']);
    load([csv_files(1).folder filesep csv_files(1).name], 'QuestionnairesTable')
    
    table_a = QuestionnairesTable;

    % concatenate all csv files into temporary 'table_a'
    for index = 2 : length(csv_files)
        
        load([csv_files(index).folder filesep csv_files(index).name], 'QuestionnairesTable');
        table_b = QuestionnairesTable;
        table_a = outerjoin(table_a, table_b, 'MergeKeys', true);
    
    end

    % replace missing answers with code '222'
    table_a{:, 10:end}(isnan(table_a{:, 10:end})) = 222;
    
    % rearrange columns when multiple Sources were selected
    table_a = sort_columns(table_a);
    
    % copy table and write csv file
    All_Questionnaires = table_a;
    
    % sort by subjects
    All_Questionnaires = sortrows(All_Questionnaires, 'SubjectID');
    
    csv_date = datestr(datetime(), 'dd-mm-yyyy');
    save([cd filesep 'IHAB_Rohdaten_EMA2018' filesep 'All_Questionnaires_' csv_date '.mat'], 'All_Questionnaires');
    writetable(All_Questionnaires, [cd filesep 'IHAB_Rohdaten_EMA2018' filesep 'All_Questionnaires_' csv_date '.csv'],'Delimiter',';');
    fprintf('\nDone !\n\n')
    
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