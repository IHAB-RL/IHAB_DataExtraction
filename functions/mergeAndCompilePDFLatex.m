function [] = mergeAndCompilePDFLatex(obj)

sFile_Profile = 'Profile.tex';
sFile_Graphic = 'graphic.tex';
sFile_Part_Diagrams = 'diagrams.tex';
sFile_Part_Overview = 'overview.tex';
sFile_Part_Fingerprints = 'fingerprints.tex';
sFile_Details_Overview = 'detailsoverview.tex';
sFileOutput_tex = 'profile.tex';

% Names of PDF files
cFileNames = {'01_Profile_Situations.pdf', ...
    '02_Profile_Situation_1.pdf', ...
    '03_Profile_Activity_Mean_1.pdf', ...
    '04_Profile_Activity_1.pdf', ...
    '05_Profile_Source_Mean_1.pdf', ...
    '06_Profile_Source_1.pdf', ...
    '07_Profile_Situation_2.pdf', ...
    '08_Profile_Activity_Mean_2.pdf', ...
    '09_Profile_Activity_2.pdf', ...
    '10_Profile_Source_Mean_2.pdf', ...
    '11_Profile_Source_2.pdf', ...
    '12_Profile_Situation_3.pdf', ...
    '13_Profile_Activity_Mean_3.pdf', ...
    '14_Profile_Activity_3.pdf', ...
    '15_Profile_Source_Mean_3.pdf', ...
    '16_Profile_Source_3.pdf', ...
    ['17_', obj.stSubject.Name, '.pdf']};

cCaptions = {['Personal Profile: ', obj.stSubject.Name], ...
    'Höranstrengung getrennt nach Situation', ...
    'Mittlere Höranstrengung getrennt nach Aktivität', ...
    'Höranstrengung getrennt nach Aktivität', ...
    'Mittlere Höranstrengung getrennt nach Signalquellen', ...
    'Höranstrengung getrennt nach Signalquellen', ...
    'Sprachverstehen getrennt nach Situation', ...
    'Mittleres Sprachverstehen getrennt nach Aktivität', ...
    'Sprachverstehen getennt nach Aktivität', ...
    'Mittleres Sprachverstehen getrennt nach Signalquellen', ...
    'Sprachverstehen getrennt nach Signalquellen', ...
    'Beeinträchtigung getrennt nach Situation', ...
    'Mittlere Beeinträchtigung getrennt nach Aktivität', ...
    'Beeinträchtigung getrennt nach Aktivität', ...
    'Mittlere Beeinträchtigung getrennt nach Signalquellen', ...
    'Beeinträchtigung getrennt nach Signalquellen', ...
    [obj.stSubject.Name, ' data availability']};

% Read LaTeX data
sProfile = fileread(fullfile(obj.sFolder_Latex, sFile_Profile));
sGraphics = fileread(fullfile(obj.sFolder_Latex, filesep, sFile_Graphic));
sPart_Diagrams = fileread(fullfile(obj.sFolder_Latex, sFile_Part_Diagrams));
sPart_Overview = fileread(fullfile(obj.sFolder_Latex, sFile_Part_Overview));
sPart_Fingerprints = fileread(fullfile(obj.sFolder_Latex, sFile_Part_Fingerprints));
sDetails_Overview = fileread(fullfile(obj.sFolder_Latex, sFile_Details_Overview));


%% Exchange Diagrams


sDiagrams = '';

nDiagrams = 16;
for iDiagram = 1:nDiagrams

    sCurrentChart = strrep(sGraphics, '$filename$', ...
        strrep([obj.stSubject.Folder, filesep, 'graphics', filesep, cFileNames{iDiagram}], '\', '/'));
    sCurrentChart = strrep(sCurrentChart, '$caption$', cCaptions{iDiagram});
    sDiagrams = [sDiagrams, sCurrentChart];
    
end

% Diagrams are displayed in portrait mode
nRotation = 0;
sDiagrams = strrep(sDiagrams, '$rotation$', num2str(nRotation));
sWidth = '1.00';
sDiagrams = strrep(sDiagrams, '$width$', sWidth);


%% Exchange Overview

sDetails_Overview_Complete = '';

for iDay = 1:obj.stAnalysis.NumberOfDays
   
    sDetails_Overview_Day = strrep(sDetails_Overview, ...
        '$daynumber$', num2str(iDay));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$date$', char(obj.stAnalysis.Dates(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$dauer$', secondsToTime(obj.stAnalysis.TimePerDay(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$numberofparts$', ...
        num2str(obj.stAnalysis.NumberOfParts(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$numberofquestionnaires$', ...
        num2str(obj.stAnalysis.NumberOfQuestionnaires(iDay)));
    
    sDetails_Overview_Complete = [sDetails_Overview_Complete, ...
        sDetails_Overview_Day];
    
end

sOverview = strrep(sGraphics, '$filename$', ...
        strrep([obj.stSubject.Folder, filesep, 'graphics', filesep, cFileNames{17}], '\', '/'));
sOverview = strrep(sOverview, '$caption$', cCaptions{17});

% Overview is displayed in portrait mode
nRotation = 0;
sOverview = strrep(sOverview, '$rotation$', num2str(nRotation));
sWidth = '1.15';
sOverview = strrep(sOverview, '$width$', sWidth);


%% Exchange Fingerprints


sFingerprints = '';

% Find all Fingerprint PDF's in folder
stDir_Fingerprints = dir([obj.stSubject.Folder, filesep, 'graphics', ...
    filesep, 'Fingerprint*.pdf']);

nFingerprints = length(stDir_Fingerprints);
for iFingerprint = 1:nFingerprints
    
    sCurrentFingerprint = strrep(sGraphics, '$filename$', ...
        strrep([obj.stSubject.Folder, filesep, 'graphics', filesep, ...
        stDir_Fingerprints(iFingerprint).name], '\', '/'));
    sCurrentFingerprint = strrep(sCurrentFingerprint, '$caption$', ...
        strrep(stDir_Fingerprints(iFingerprint).name, '_', '\_'));
    sFingerprints = [sFingerprints, sCurrentFingerprint];
    
end

% Fingerprints are displayed in landscape mode
nRotation = 90;
sFingerprints = strrep(sFingerprints, '$rotation$', num2str(nRotation));
sWidth = '1.50';
sFingerprints = strrep(sFingerprints, '$width$', sWidth);


%% Adjust general information


% Replace Subject's name
sProfile = strrep(sProfile, '$subject$', obj.stSubject.Name);
sProfile = strrep(sProfile, '$latexfolder$', strrep(obj.sFolder_Latex, '\', '/'));
sProfile = strrep(sProfile, '$appendix$', strrep(obj.stSubject.Appendix, '_', ' '));

% Replace Part Page variables
sPart_Diagrams = strrep(sPart_Diagrams, '$numberofquestionnaires$', ...
    num2str(sum(obj.stAnalysis.NumberOfQuestionnaires)));
sPart_Overview = strrep(sPart_Overview, '$numberofdays$', ...
    num2str(obj.stAnalysis.NumberOfDays));
sPart_Overview = strrep(sPart_Overview, '$numberofparts$', ...
    num2str(sum(obj.stAnalysis.NumberOfParts)));
sPart_Overview = strrep(sPart_Overview, '$numberofquestionnaires$', ...
    num2str(sum(obj.stAnalysis.NumberOfQuestionnaires)));
sPart_Overview = strrep(sPart_Overview, '$detailsoverview$', ...
    sDetails_Overview_Complete);
sPart_Fingerprints = strrep(sPart_Fingerprints, 'minpartlength', ...
    num2str(obj.stPreferences.MinPartLength));
sPart_Fingerprints = strrep(sPart_Fingerprints, 'numberofparts', ...
    num2str(nFingerprints));


%% Merge all LaTeX data together

sProfile = strrep(sProfile, '$part_diagrams$', sPart_Diagrams);
sProfile = strrep(sProfile, '$part_overview$', sPart_Overview);
sProfile = strrep(sProfile, '$part_fingerprints$', sPart_Fingerprints);

sProfile = strrep(sProfile, '$contents_diagrams$', sDiagrams);
sProfile = strrep(sProfile, '$contents_overview$', sOverview);
sProfile = strrep(sProfile, '$contents_fingerprints$', sFingerprints);

hFid_Profile = fopen([obj.stSubject.Folder, filesep, 'graphics', ...
    filesep, sFileOutput_tex], 'w');
fwrite(hFid_Profile, sProfile);
fclose(hFid_Profile);


%% Compile and tidy up

   
% Compile PDF file TWICE because LaTeX
system(['pdflatex -shell-escape --src -interaction=nonstopmode ', ...
    obj.stSubject.Folder, filesep, 'graphics', filesep, sFileOutput_tex]);

system(['pdflatex -shell-escape --src -interaction=nonstopmode ', ...
    obj.stSubject.Folder, filesep, 'graphics', filesep, sFileOutput_tex]);

% Delete additional output
delete([obj.sFolderMain, filesep, 'profile.lof']);
delete([obj.sFolderMain, filesep, 'profile.log']);
delete([obj.sFolderMain, filesep, 'profile.aux']);

end
