function computeDayFingerprintData(obj, dateDay, desiredDayPart, isDebug, varargin)
% INPUT:
%   szDir,szSubject,dateDay,desiredDayPart,isDebug,varargin
isDebugMode = isDebug;


if ~exist([obj.stSubject.Folder, filesep, 'cache'], 'dir')
    mkdir([obj.stSubject.Folder, filesep, 'cache']);
end


% script to display a fingerprint of one day of one test subject

p = inputParser;
p.KeepUnmatched = true;
isNonEmptyChar = @(x) ischar(x) && ~isempty(x(~isspace(x)));
p.addParameter('szDir',fullfile(pwd,'IHAB_Rohdaten_EMA2018'),...
    @(x) ischar(x) && isempty(x(~isspace(x))) && exist(x,'dir'));
p.addParameter('hasSubjectiveData',true, @(x) islogical(x) || x == 0 || x == 1)
p.addParameter('runValidation',true, @(x) islogical(x) || x == 0 || x == 1)
p.addParameter('additive', 0.0, @(x) (x < 1) && (x >= 0));
p.addRequired('dateDay', @(x) isdatetime(x));
p.addRequired('desiredDayPart', @(x) isnumeric(x) && isscalar(x) && (x > 0));
p.parse(dateDay,desiredDayPart,varargin{:});


%Define your parameters and adjust your function call
% szBaseDir = szDir;
% szTestSubject =  szSubject;

% caAllSubjects = getallsubjects(szBaseDir);
%
% correctIdx = 0;
% for allSubsIdx = 1:numel(caAllSubjects)
%     if strcmpi(caAllSubjects{allSubsIdx}.SubjectID, szTestSubject)
%         correctIdx = allSubsIdx;
%         break;
%     end
% end
%
% obj.stSubject.Folder = caAllSubjects{correctIdx}.FolderName;


desiredDay = p.Results.dateDay;
desiredPart = p.Results.desiredDayPart;

% lets start with reading objective data

if isDebugMode
    load DataMat
else
    szFeature = 'RMS';
    [DataRMS, timeVecRMS, ~] = getObjectiveDataOneDay(obj, desiredDay, szFeature, desiredPart);
    
    if ~isempty(timeVecRMS)
        % No Inclusion of Parts shorter than e.g. 10 Minutes % UK
        temp_time = timeVecRMS(end) - timeVecRMS(1);
        temp_duration = duration(temp_time);
        if (minutes(temp_duration) < obj.stPreferences.MinPartLength) && (obj.stPreferences.MinPartLength > 0)
            return;
        end
    end
    
    szFeature = 'PSD';
    [DataPSD, timeVecPSD, ~] = getObjectiveDataOneDay(obj, desiredDay, szFeature, desiredPart);
    %    save DataMat DataRMS timeVecRMS DataPSD timeVecPSD NrOfParts
end



% Data conversion
[Cxy,Pxx,Pyy] = get_psd(DataPSD);
clear DataPSD;
Cohe = Cxy./(sqrt(Pxx.*Pyy) + eps);
if isempty(Cohe)
    return;
end
% OVD
stInfoOVDAlgo.fs = 16000;
[OVD_result_fixed, MeanCohere,~] = computeOVD_Coh(Cohe, timeVecPSD, stInfoOVDAlgo);

% OVD adaptive
stInfoOVDAlgo.fs = 16000;
stInfoOVDAlgo.adapThresh = 0.5;
stInfoOVDAlgo.additive = p.Results.additive;
OVD_result_adaptive = computeOVD_Coh(Cohe, timeVecPSD, stInfoOVDAlgo);

% prepare display by getting the right datetime vector for the data

% StartTime = TimeVec(1);
% EndTime = TimeVec(end)+minutes(1);
%
% timeVecRMS = linspace(StartTime,EndTime,size(DataRMS,1))';
% timeVecPSD = linspace(StartTime,EndTime,size(DataPSD,1))';


% Fuer Zeit
stControl.DataPointRepresentation_s = 5;
stControl.DataPointOverlap_percent = 0;
stControl.szTimeCompressionMode = 'mean';

[FinalDataRMS,FinaltimeVecRMS] = DataCompactor(DataRMS, timeVecRMS, stControl);
clear DataRMS;
[FinalDataPxx, ~] = DataCompactor(Pxx, timeVecPSD, stControl);
[FinalDataPyy, ~] = DataCompactor(Pyy, timeVecPSD, stControl);
clear Pyy;
[FinalDataCohe, ~] = DataCompactor(real(Cohe), timeVecPSD, stControl);
clear Cohe;
[FinalDataCxy, ~] = DataCompactor(abs(Cxy), timeVecPSD, stControl);
clear Cxy;

stControlOVD.DataPointRepresentation_s = stControl.DataPointRepresentation_s;
stControlOVD.DataPointOverlap_percent = 0;
stControlOVD.szTimeCompressionMode = 'max';
[FinalDataOVD_fixed, ~] = DataCompactor(OVD_result_fixed, timeVecPSD, stControlOVD);
[FinalDataOVD_adaptive, ~] = DataCompactor(OVD_result_adaptive, timeVecPSD, stControlOVD);
clear OVD_result;
[FinalDataMeanCohe, FinaltimeVecPSD] = DataCompactor(MeanCohere, timeVecPSD, stControlOVD);

% Data reduction and condensing
% FFTSize x Band Matrix aufbauen
% fuer bark, mel, one-third. octave filterbank
% am BEsten als Funktion die die Multiplikations-Matrix zuruek gibt
FftSize = size(Pxx, 2);
clear Pxx;
stBandDef.StartFreq = 125;
stBandDef.EndFreq = 8000;
stBandDef.Mode = 'onethird';
stBandDef.fs = 16000;
[stBandDef] = fftbin2freqband(FftSize, stBandDef);
stBandDef.skipFrequencyNormalization = 1;
[stBandDefCohe] = fftbin2freqband(FftSize, stBandDef);

FinalDataCxy2 = FinalDataCxy * stBandDef.ReGroupMatrix;
FinalDataPxx2 = FinalDataPxx * stBandDef.ReGroupMatrix;
FinalDataPyy2 = FinalDataPyy * stBandDef.ReGroupMatrix;
FinalDataCohe2 = FinalDataCohe * stBandDefCohe.ReGroupMatrix;
save ([obj.stSubject.Folder, filesep, 'cache', filesep obj.stSubject.Name,...
    '_FinalDat_', num2str(day(desiredDay)), '_', num2str(month(desiredDay)),...
    '_', num2str(year(desiredDay)), ...
    '_p', num2str(desiredPart)], 'FinalDataRMS', 'FinaltimeVecRMS',...
    'FinalDataPxx', 'FinalDataPyy', 'FinalDataCohe', 'FinalDataCxy', ...
    'FinalDataPxx2', 'FinalDataPyy2', 'FinalDataCohe2', 'FinalDataCxy2', ...
    'FinalDataOVD_fixed', 'FinalDataOVD_adaptive', 'FinalDataMeanCohe',...
    'FinaltimeVecPSD', 'stBandDef', 'stInfoOVDAlgo');


end