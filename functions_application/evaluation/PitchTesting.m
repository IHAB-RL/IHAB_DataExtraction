% script for testing purpose
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF  
% Version History:
% Ver. 0.01 initial create 16-Oct-2019  Initials JP

% path to main data folder (needs to be customized)
szBaseDir = 'I:\Forschungsdaten_mit_AUDIO\Bachelorarbeit_Sascha_Bilert2018\OVD_Data\IHAB\PROBAND';

% get all subject directories
subjectDirectories = dir(szBaseDir);

% choose one subject directoy
szCurrentFolder = subjectDirectories(18).name;

% number of noise configuration
szNoiseConfig = '1';

% build the full directory
szDir = [szBaseDir filesep szCurrentFolder filesep 'config' szNoiseConfig];

audiofile = fullfile(szDir, [szCurrentFolder '_config' szNoiseConfig '.wav']);
audiofile = 'olsa_male_full_3_0.wav';
[audioIn,fs] = audioread(audiofile);
audioIn = audioIn(round(5.5*fs):round(8.5*fs));

[f0,idx] = pitch(audioIn,fs, ...
    'Method','PEF', ...
    'Range',[50 800], ...
    'WindowLength',round(fs*0.08), ...
    'OverlapLength',round(fs*0.05));

figure;
subplot(2,1,1);
plot(audioIn);
ylabel('Amplitude');

subplot(2,1,2);
plot(idx,f0);
ylabel('Pitch (Hz)');
xlabel('Sample Number');

%--------------------Licence ---------------------------------------------
% Copyright (c) <2019> J. Pohlhausen
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