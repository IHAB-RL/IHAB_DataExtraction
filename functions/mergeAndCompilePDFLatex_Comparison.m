function [] = mergeAndCompilePDFLatex_Comparison(obj)

sFile_Profile = 'Profile_Comparison.tex';
sFile_Graphic = 'graphic_Comparison.tex';
sFile_Part_Diagrams = 'diagrams_Comparison.tex';
sFile_Part_Overview = 'overview_Comparison.tex';
sFile_Details_Overview = 'detailsoverview.tex';
sFileOutput_tex = 'Profile.tex';

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
sDetails_Overview = fileread(fullfile(obj.sFolder_Latex, sFile_Details_Overview));

%% Exchange Diagrams


vRotation = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 0, 0, 0, 0, 0];
vWidth = [1.1, 1.2, 1.1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

sDiagrams = '';

nDiagrams = 16;
for iDiagram = 1:nDiagrams

    sCurrentChart = strrep(sGraphics, '$filename1$', ...
        strrep([obj.stComparison(1).Folder, filesep, 'graphics', filesep, cFileNames{iDiagram}], '\', '/'));
    sCurrentChart = strrep(sCurrentChart, '$filename2$', ...
        strrep([obj.stComparison(2).Folder, filesep, 'graphics', filesep, cFileNames{iDiagram}], '\', '/'));
    
    
    
%     sCurrentChart = strrep(sCurrentChart, '$vspace$', '0');
    sCurrentChart = strrep(sCurrentChart, '$caption$', cCaptions{iDiagram});
    
    sCurrentChart = strrep(sCurrentChart, '$rotation$', num2str(vRotation(iDiagram)));
    sCurrentChart = strrep(sCurrentChart, '$width$', num2str(vWidth(iDiagram)));
    
    sDiagrams = [sDiagrams, sCurrentChart];
    
%     sCurrentChart = strrep(sGraphics, '$filename$', ...
%         strrep([obj.stComparison(2).Folder, filesep, 'graphics', filesep, cFileNames{iDiagram}], '\', '/'));
%     sCurrentChart = strrep(sCurrentChart, '$vspace$', '5');
%     sCurrentChart = strrep(sCurrentChart, '$caption$', [cCaptions{iDiagram}, ', 2. Durchlauf']);
%     sCurrentChart = strrep(sCurrentChart, '$rotation$', num2str(vRotation(iDiagram)));
%     sCurrentChart = strrep(sCurrentChart, '$width$', num2str(vWidth(iDiagram)));
    
%     sDiagrams = [sDiagrams, sCurrentChart];
    
end


%% Exchange Overview #1


sDetails_Overview_Complete = '';

for iDay = 1:obj.stComparison(1).Analysis.NumberOfDays
   
    sDetails_Overview_Day = strrep(sDetails_Overview, ...
        '$daynumber$', num2str(iDay));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$date$', char(obj.stComparison(1).Analysis.Dates(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$dauer$', secondsToTime(obj.stComparison(1).Analysis.TimePerDay(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$numberofparts$', ...
        num2str(obj.stComparison(1).Analysis.NumberOfParts(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$numberofquestionnaires$', ...
        num2str(obj.stComparison(1).Analysis.NumberOfQuestionnaires(iDay)));
    
    sDetails_Overview_Complete = [sDetails_Overview_Complete, ...
        sDetails_Overview_Day];
    
end

sOverview = strrep(sGraphics, '$filename$', ...
        strrep([obj.stComparison(1).Folder, filesep, 'graphics', filesep, cFileNames{17}], '\', '/'));
sOverview = strrep(sOverview, '$caption$', cCaptions{17});

% Overview is displayed in portrait mode
nRotation = 0;
sOverview = strrep(sOverview, '$rotation$', num2str(nRotation));
sOverview = strrep(sOverview, '$durchlauf$', '1/2');
sWidth = '1.15';
sOverview_1 = strrep(sOverview, '$width$', sWidth);


%% Exchange Overview #2


sDetails_Overview_Complete = '';

for iDay = 1:obj.stComparison(2).Analysis.NumberOfDays
   
    sDetails_Overview_Day = strrep(sDetails_Overview, ...
        '$daynumber$', num2str(iDay));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$date$', char(obj.stComparison(2).Analysis.Dates(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$dauer$', secondsToTime(obj.stComparison(2).Analysis.TimePerDay(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$numberofparts$', ...
        num2str(obj.stComparison(2).Analysis.NumberOfParts(iDay)));
    sDetails_Overview_Day = strrep(sDetails_Overview_Day, ...
        '$numberofquestionnaires$', ...
        num2str(obj.stComparison(2).Analysis.NumberOfQuestionnaires(iDay)));
    
    sDetails_Overview_Complete = [sDetails_Overview_Complete, ...
        sDetails_Overview_Day];
    
end

sOverview = strrep(sGraphics, '$filename$', ...
        strrep([obj.stComparison(2).Folder, filesep, 'graphics', filesep, cFileNames{17}], '\', '/'));
sOverview = strrep(sOverview, '$caption$', cCaptions{17});

% Overview is displayed in portrait mode
nRotation = 0;
sOverview = strrep(sOverview, '$rotation$', num2str(nRotation));
sOverview = strrep(sOverview, '$durchlauf$', '2/2');
sWidth = '1.15';
sOverview_2 = strrep(sOverview, '$width$', sWidth);


sOverview = [sOverview_1, sOverview_2];


%% Adjust general information


% Replace Subject's name
sProfile = strrep(sProfile, '$subject$', obj.stSubject.Name);
sProfile = strrep(sProfile, '$latexfolder$', strrep(obj.sFolder_Latex, '\', '/'));
sProfile = strrep(sProfile, '$appendix$', strrep(obj.stSubject.Appendix, '_', ' '));

% Replace Part Page variables
sPart_Diagrams = strrep(sPart_Diagrams, '$numberofquestionnaires$', ...
    num2str(sum(obj.stComparison(1).Analysis.NumberOfQuestionnaires) +...
    sum(obj.stComparison(2).Analysis.NumberOfQuestionnaires)));
sPart_Overview = strrep(sPart_Overview, '$numberofdays$', ...
    num2str(obj.stAnalysis.NumberOfDays));
sPart_Overview = strrep(sPart_Overview, '$numberofparts$', ...
    num2str(sum(obj.stAnalysis.NumberOfParts)));
sPart_Overview = strrep(sPart_Overview, '$numberofquestionnaires$', ...
    num2str(sum(obj.stAnalysis.NumberOfQuestionnaires)));
sPart_Overview = strrep(sPart_Overview, '$detailsoverview$', ...
    sDetails_Overview_Complete);
% sPart_Fingerprints = strrep(sPart_Fingerprints, 'minpartlength', ...
%     num2str(obj.stPreferences.MinPartLength));
% sPart_Fingerprints = strrep(sPart_Fingerprints, 'numberofparts', ...
%     num2str(nFingerprints));


%% Merge all LaTeX data together

sProfile = strrep(sProfile, '$part_diagrams$', sPart_Diagrams);
sProfile = strrep(sProfile, '$part_overview$', sPart_Overview);
% sProfile = strrep(sProfile, '$part_fingerprints$', sPart_Fingerprints);

sProfile = strrep(sProfile, '$contents_diagrams$', sDiagrams);
sProfile = strrep(sProfile, '$contents_overview$', sOverview);
% sProfile = strrep(sProfile, '$contents_fingerprints$', sFingerprints);

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
