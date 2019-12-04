% Script to loop
% Author: J. Pohlhausen (c) IHA @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 13-Nov-2019 	JP

clear;


% path to data folder
obj.szPath = 'I:\SpontanStereoBeideSprecher';

% List all feat files
AllWavFiles = listFiles(obj.szPath, '*.wav');
AllWavFiles = {AllWavFiles.name}';

% sort for valid files
AllWavFiles = AllWavFiles(~contains(AllWavFiles, '\.'));

% number of audiofiles
NrOfFiles = numel(AllWavFiles);

% get names without path
[~, szFiles] = cellfun(@fileparts, AllWavFiles,'UniformOutput',false);

% pre allocation
vDur = zeros(1, NrOfFiles);
vSubjects = cell(1, 2*NrOfFiles);

% loop through all audiofiles
for idx = 1:NrOfFiles
    % set current filename
    obj.szAudioFile = AllWavFiles{idx};
    
    szParts = strsplit(szFiles{idx}, '_');
    
    % get subject IDs
    obj.szSubject1 = szParts{1};
    obj.szSubject2 = szParts{2};
    
%     % detect voice sequences based on RMS on-set/ off-set detection and
%     % save in text file
%     VoiceDetectionCleanSpeech(obj);
    
    % get duration of audiofile
    stInfo = audioinfo(obj.szAudioFile);
    vDur(idx) = stInfo.Duration;
    
    % save subject IDs
    vSubjects(2*idx-1) = szParts(1);
    vSubjects(2*idx) = szParts(2);
    
end

% adjust for both speaker
vDur = repelem(vDur,2);

% display durations as table
Tbl = sortrows(table(vDur', vSubjects', 'VariableNames', {'Duration'; 'Subject'}));

% get infos into on cell array and sort rows by duration
cInfo = sortrows([num2cell(vDur') vSubjects']);

% % % split data in sets with nearly equivalent durations
% % for ii = 1:4
% %     if ii == 4
% %         idx = [4*ii-3  4*ii-1  4*ii+1  2*NrOfFiles-(2*ii-1)];
% %     else
% %         idx = [4*ii-3  4*ii-1  2*NrOfFiles-(2*ii-1)];
% %     end
% %     
% %     vSetDur(ii) = sum([cInfo{idx ,1}]);
% % end

genGroupedSignals(AllWavFiles, szFiles, stInfo.SampleRate)

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