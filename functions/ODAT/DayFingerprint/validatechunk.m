function [errorCodes, percentErrors] = validatechunk(szChunkName,configStruct,isDebug)
%VALIDATECHUNK returns whether a chunk/feature-file is valid
%
% INPUT:
%       szChunkName: string, full path of one chunk
%
%       configStruct: struct, defines validation parameters
%               has to define:
%                       .lowerBinCohe: center frequency of the lower bin
%                                     of coherence which is used for averaging
%                                     over a number of bins
%                       .upperBinCohe: center frequency of the upper bin
%                                     of coherence which is used for averaging
%                                     over a number of bins
%                       .upperThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of
%                                           coherence                                           that should not be exceeded
%                       .lowerThresholdCohe: threshold for the mean between
%                                           the upper and lower bins of
%                                           coherence that should not be
%                                           undercut
%                       .thresholdRMSforCohe: threshold of RMS that should
%                                            not be undercut for the
%                                            validation of the coherence
%                       .upperThresholdRMS: threshold of RMS that should
%                                           not be exceeded
%                       .lowerThresholdRMS: threshold of RMS that should
%                                           not be undercut
%                       .errorTolerance: percentage of allowed invalidity
%
% OUTPUT:
%       errorCodes: cell, contains int/vector, assessment of validation;
%                    error codes can be:
%                            0: ok
%                           -1: at least one RMS value was too HIGH
%                           -2: at least one RMS value was too LOW
%                           -3: data is mono
%                           -4: Coherence (real part) is invalid
%                           -5: RMS feature file was not found

% Author: N.Schreiber (c)
% Version History:
% Ver. 0.01 initial create (empty) 11-Dec-2017                           NS
% Ver. 0.02 added MSC validation 31-Jan-2018                             NS
% Ver. 0.03 added config struct 02-Feb-2018                              NS
% Ver. 0.04 changed MSC to real part of coherence March 2018 			 NS
% ---------------------------------------------------------

% Import paths of necessary functions
%addpath('../Tools');
%addpath('../DroidFeatureTools');

% Simulate data for testing
if nargin < 3
    isDebug = 0;
end

if isDebug
    SimAudioData = randn(2000,2);
    SimAudioData = SimAudioData./max(SimAudioData(:));
    buf1 = buffer(SimAudioData(:,1),50);
    buf2 = buffer(SimAudioData(:,2),50);
    RMSFeatData = zeros(size(buf1,2),2);
    for ii = 1:size(buf1,2)
        RMSFeatData(ii,1) = rms(buf1(:,ii));
        RMSFeatData(ii,2) = rms(buf2(:,ii));
    end
    
    % Build in little invalid data piece to test the function
    RMSFeatData(:,1) = RMSFeatData(:,2);
    
    figure;
    plot(20*log10(RMSFeatData))
    errorCodes = 0;
else
    % Store original chunk name
    szOriginalChunkName = szChunkName;
    
    %% Load feature file
    
    % Get RMS independent from actual feature file content
    % So the first three letters of the file will be replaced
    % with 'RMS'
    [szFilepath,szName,szExt] = fileparts(szChunkName);
    szName = [szName szExt];
    
    % Get parts of file name
    splitName = regexpi(szName,'_','split');
    numFilenameParts = numel(splitName);
    
    if numFilenameParts < 4
        isOldFormat = true;
    else
        isOldFormat = false;
    end
    
    % 27/34 is standard length for a valid file name (incl. '.feat')
    if isOldFormat
        validNameLength = 27;
    else
        validNameLength = 34;
    end
    if length(szName) < validNameLength
        error('The length of the file name does not match the convention. You typed: %s', szName);
    end
    
    
    
    %% Validate for different criteria
    
    % Check validity for levels and whether the data are mono
    
    % Load feature file with corresponding RMS feature
    if isOldFormat
        szChunkName = fullfile(szFilepath, ['RMS' '_' splitName{2} '_' splitName{3}]);
    else
        szChunkName = fullfile(szFilepath, ['RMS' '_' splitName{2} '_' splitName{3} '_' splitName{4}]);
        
    end
    if exist(szChunkName,'file')
        [RMSFeatData, frameTimeRMS]= LoadFeatureFileDroidAlloc(szChunkName);
    else
        % Probably a corrupt file and it could not be found in the valid file name list: error code = -5
        errorCodes = {-5};
        percentErrors = {NaN};
        return;
    end
    
    % Load feature file with corresponding PSD feature
    if isOldFormat
        szChunkName = fullfile(szFilepath, ['PSD' '_' splitName{2} '_' splitName{3}]);
    else
        szChunkName = fullfile(szFilepath, ['PSD' '_' splitName{2} '_' splitName{3} '_' splitName{4}]);
        
    end
    if exist(szChunkName,'file')
        [PSDFeatData, frameTimePSD] = LoadFeatureFileDroidAlloc(szChunkName);
        [Cxy,Pxx,Pyy] = get_psd(PSDFeatData);
        
        % Compute the magnitude squared coherence
        Cohe = real(Cxy./(sqrt(Pxx.*Pyy) + eps));
        
        % Define parameters for plotting
        FftSize = size(Pxx,2);
        stBandDef.StartFreq = 125;
        stBandDef.EndFreq = 8000;
        stBandDef.Mode = 'onethird';
        stBandDef.fs = 16000;
        [stBandDef]=fftbin2freqband(FftSize,stBandDef);
        stBandDef.skipFrequencyNormalization = 1;
        
        % Calculate the indices of the bins over which the mean is taken
        lowBounds = ...
            floor([configStruct.lowerBinCohe configStruct.upperBinCohe]...
            .*FftSize/(stBandDef.fs/2));
        
        % Take the mean from the lower to the upper defined bin
        meanLowFreqBinsCohe = mean(Cohe(lowBounds(1):lowBounds(2),:),1);
        
        % Definition of invalidity
        invalidCoherence = ...
            (meanLowFreqBinsCohe > configStruct.upperThresholdCohe);
    else
        % Probably a corrupt file and it could not be found in the valid file name list: error code = -5
        errorCodes = {-5};
        percentErrors = {NaN};
        return;
    end
    
end

RMSFeatData = 20*log10(RMSFeatData);

%
fThresholdLoud = configStruct.upperThresholdRMS;
fThresholdQuiet = configStruct.lowerThresholdRMS;

% Error codes
isValid = 0;
isTooLoud = -1;
isTooQuiet = -2;
isMono = -3;
isInvalidCoherence = -4;

tooLoudPercent = sum(RMSFeatData(:) > fThresholdLoud) ...
    / length(RMSFeatData(:));
tooQuietPercent = sum(RMSFeatData(:) < fThresholdQuiet) ...
    / length(RMSFeatData(:));
monoPercent = sum((RMSFeatData(:,1) -min(RMSFeatData(:,1)))...
    ./max((RMSFeatData(:,1) -min(RMSFeatData(:,1)))) ...
    == (RMSFeatData(:,2) -min(RMSFeatData(:,2)))...
    ./max((RMSFeatData(:,2) -min(RMSFeatData(:,2)))))...
    / length(RMSFeatData(:,1));
invalidCoherencePercent = sum(invalidCoherence) ...
    / length(invalidCoherence);
errorCodes = [];
percentErrors = [];
if tooLoudPercent > configStruct.errorTolerance
    errorCodes(end+1) = isTooLoud;
    percentErrors(end+1) = tooLoudPercent;
end
if tooQuietPercent > configStruct.errorTolerance
    errorCodes(end+1) = isTooQuiet;
    percentErrors(end+1) = tooQuietPercent;
end
if monoPercent > configStruct.errorTolerance
    errorCodes(end+1) = isMono;
    percentErrors(end+1) = monoPercent;
end
if invalidCoherencePercent > configStruct.errorTolerance
    errorCodes(end+1) = isInvalidCoherence;
    percentErrors(end+1) = invalidCoherencePercent;
end
if isempty(errorCodes)
    errorCodes = isValid;
    percentErrors = 0;
end

errorCodes = {errorCodes};
percentErrors = {percentErrors};


% EOF validatechunk.m