
ccc;

sFolder = 'E:\IHAB-rl_Auswertung\IHAB_Rohdaten_EMA2018\EN04RM20_180618_ks\graphics';

sLatex = 'E:\IHAB-rl_Data_Pull\functions\latex';

sFileProfile = 'Profile.tex';
sFileGraphics = ['tex', filesep, 'graphic.tex'];
sFileOutput_tex = [sFolder, filesep, 'profile.tex'];
sFileOutput_pdf = [sFolder, filesep, 'profile.tex'];

sName = 'EN04RM20';

% copy latex file to folder


sProfile = fileread(fullfile(sLatex, sFileProfile));
sGraphics = fileread(fullfile(sLatex, sFileGraphics));


sProfile = strrep(sProfile, '$subject$', sName);
sProfile = strrep(sProfile, '$latexfolder$', strrep(sLatex, '\', '/'));


% Exchange Diagrams
sDiagrams = '';

sFileName = '';
nDiagrams = 10;
for iDiagram = 1:nDiagrams
    
    sCurrentChart = strrep(sGraphics, '$filename$', sFileName);
    sCurrentChart = strrep(sCurrentChart, '$Caption', '');
    sDiagrams = [sDiagrams, sCurrentChart];
    
end



% Exchange Overview
sOverview = strrep(sGraphics, '$filename$', sFileName);
sOverview = strrep(sOverview, '$Caption', '');




% Exchange Fingerprints
sFingerprints = '';

sFileName = '';
nFingerprints = 10;
for iFingerprint = 1:nFingerprints
    
    sCurrentFingerprint = strrep(sGraphics, '$filename$', sFileName);
    sCurrentFingerprint = strrep(sCurrentFingerprint, '$Caption', '');
    sFingerprints = [sFingerprints, sCurrentFingerprint];
    
end



sProfile = strrep(sProfile, 'contents_diagrams', sDiagrams);
sProfile = strrep(sProfile, 'contents_overview', sOverview);
sProfile = strrep(sProfile, 'contents_fingerprints', sFingerprints);

hFid_Profile = fopen(sFileOutput_tex, 'w');
fwrite(hFid_Profile, sProfile);
fclose(hFid_Profile);
   
   

% Compile PDF file
system(['pdflatex -shell-escape --src -interaction=nonstopmode ', sFileOutput_tex]);







