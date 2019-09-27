%% redo all profiles
% Author: AGA (c) TGM @ Jade Hochschule applied licence see EOF
    
% get all subjects
subjectDirectories = dir(fullfile(pwd, 'IHAB_Rohdaten_EMA2018'));
allSubjects = subjectDirectories([subjectDirectories.isdir]);

% remove annoying '.'  and '..'
allSubjects = allSubjects(~ismember({allSubjects.name},{'.','..','.ipynb_checkpoints'}));

for index = 1 : length(allSubjects)
    
    generate_profile(allSubjects(index).name(1:8), true)
    
end

% concatenate all profile data into 'All_Questionnaires_dd-mm-yyyy.csv'
concatenate_csv()

%% check percentage of answered manual inputs
date_name = datestr(datetime(), 'dd-mm-yyyy');

load(['All_Questionnaires_' date_name]);
filt = All_Questionnaires.Manual_Input((All_Questionnaires.Situation == 5));
Answered = (sum(isnan(str2double(filt))) / length(filt)) * 100

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