
clear;
close all;
clc;

sFileName_Mat = 'Answers_EMA2018.mat';
sFileName_Xls = 'EMA2016_NewStructure_181005_end.xlsx';

load(sFileName_Mat);
nEntries = length(PossibleAnswers.text);

[NUM,TXT,RAW] = xlsread(sFileName_Xls);

RAW(1:2,:) = [];
RAW(48,:) = [];

for iEntry = 1:nEntries
   
    fprintf('-----------------------------------\n');
    fprintf('Text: %s\n', PossibleAnswers.text{iEntry});
    fprintf('ID: %s\n', PossibleAnswers.id{iEntry});
    fprintf('Code: %s\n', num2str(PossibleAnswers.code{iEntry}));
    
 
    if num2str(RAW{iEntry, 6}) ~= num2str(PossibleAnswers.code{iEntry})
        cprintf('Red', 'XLS Text: %s\n', num2str(RAW{iEntry, 3}));
        cprintf('Red', 'XLS ID: %s\n', num2str(RAW{iEntry, 4}));
        cprintf('Red', 'XLS Code: %s\n', num2str(RAW{iEntry, 6}));
    end

 
end
