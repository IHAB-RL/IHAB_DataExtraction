% Script to check the format of the PSD feature files
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create 14-Oct-2019 	JP

clear;
close all;

% path to data folder (needs to be customized)
szBaseDir = 'I:\IHAB_2_EMA2018\IHAB_Rohdaten_EMA2018';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% sort for correct subjects
isValidLength = arrayfun(@(x)(length(x.name) == 18), subjectDirectories);
subjectDirectories = subjectDirectories(isValidLength);

% desired feature
szFeature = 'PSD';

% loop over each subject
for idxSubj = 1:numel(subjectDirectories)
    
    % get one subject directoy
    szCurrentFolder = subjectDirectories(idxSubj).name;
    
    % get object
    [obj] = IHABdata([szBaseDir filesep szCurrentFolder]);
    
    % build the full directory
    szDir = [obj.stSubject.Folder filesep obj.stSubject.Name '_AkuData'];
    
    % List all feat files
    AllFeatFiles = listFiles(szDir,'*.feat');
    AllFeatFiles = {AllFeatFiles.name}';
    
    % Get names wo. path
    [~,AllFeatFiles] = cellfun(@fileparts, AllFeatFiles,'UniformOutput',false);
    
    % Append '.feat' extension for comparison to corrupt file names
    AllFeatFiles = strcat(AllFeatFiles,'.feat');
    
    % Load txt file with corrupt file names
    corruptTxtFile = fullfile(obj.stSubject.Folder,'corrupt_files.txt');
    if ~exist(corruptTxtFile,'file')
        checkDataIntegrity(obj);
    end
    fid = fopen(corruptTxtFile,'r');
    corruptFiles = textscan(fid,'%s\n');
    fclose(fid);
    
    % Textscan stores all lines into one cell array, so you need to unpack it
    corruptFiles = corruptFiles{:};
    
    % Delete names of corrupt files from the list with all feat file names
    [featFilesWithoutCorrupt, ia] = setdiff(AllFeatFiles,corruptFiles,'stable');
    
    % isFeatFile filters for the wanted feature dates, such as all of 'RMS'
    [dateVecAll,isFeatFile] = Filename2date(featFilesWithoutCorrupt,szFeature);
    
    % Also filter the corresponding file list
    featFilesWithoutCorrupt = featFilesWithoutCorrupt(logical(isFeatFile));
    
    % get infos about feature file for pre-allocation
    [FeatData, ~,stInfoFile]= LoadFeatureFileDroidAlloc([szDir filesep featFilesWithoutCorrupt{1}]);
    
    % add infos to Table struct
    stTable = schade;
end
%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
% Institute for Hearing Technology and Audiology
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