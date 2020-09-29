function [mDataSet,TimePSD,Cxy,Pxx,Pyy] = FeatureExtraction(obj, stDate, szVarNames)
% function to return and save extracted features as mat files
%   - mean real coherence
%   - RMS
%   - power spectral densities (auto | cross)
%   - correlation mean real coherence scaled to RMS with hann window combs
%           - peak height maximum
%           - prominence maximum
%           - "RMS" over all basefrequencies
%   - MFCCs
%   - ZCR
%   - Speech presence probability according to Gerkmann 2010
%
% Usage [mDataSet] = FeatureExtraction(obj, stDate, szVarNames)
%
% Parameters
% ----------
% obj - class IHABdata, contains all informations
%
% stDate - struct which contains valid date informations about the time
%          informations: start and end day and time; this struct results
%          from calling checkInputFormat.m
%
% szVarNames - cell array, contains the variable names; possible variables
%              are: RMS, ZCR, mean real coherence, speech presence
%              probability, EQD, CorrRMS, Pxx, Cxy, ground truth labels
%
% Returns
% -------
% mDataSet - matrix, contains the data set for specified variables
%
% Author: J. Pohlhausen (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 27-Nov-2019  JP

% logical whether to calc and return the PSDs or not
isCalcPSD = false;
if nargout > 2
    isCalcPSD = true;
end


% build the full path to the feature extraction directory 
szDir = [obj.stSubject.Folder filesep 'FeatureExtraction'];

% construct filename of the feature file
szFile = ['Features_' obj.stSubject.Name '_' datestr(stDate.StartDay, 'yymmdd') '_' datestr(stDate.StartTime, 'HH') '_' datestr(stDate.EndTime, 'HH')];

% check whether the features had been already calculated; if true, load the
% feature file and get the respective time vector; if false, start
% calculating features
isCalculated = false;
if ~exist(szDir, 'dir')
    mkdir(szDir);
else
    if exist([szDir filesep szFile '.mat'], 'file')
        load([szDir filesep szFile '.mat']);
        isCalculated = true;
        
        [~,TimePSD] = getObjectiveData(obj, 'PSD', 'stInfo', stDate, 'useCompression', false);
    end
end

if ~isCalculated
    % preallocate output data set matrix
    mDataSet = zeros(1, length(szVarNames));
    
    % use no compression
    useCompression = false;
    
    % reading objective data, desired feature PSD
    szFeature = 'PSD';
    
    % get all available feature file data for PSD
	[DataPSD,TimePSD,stInfo] = getObjectiveData(obj, szFeature, 'stInfo', stDate, ...
        'useCompression', useCompression);
    
    % if for the given time frame no objective data exist, return
    if isempty(DataPSD)
        return;
    end
    
    % extract PSD data
    version = 1; % JP modified get_psd
    [Cxy, Pxx, Pyy] = get_psd(DataPSD, version);
    
    % sampling frequency in Hz
    SampleRate = stInfo.fs;
    
    % number of fast Fourier transform points
    nFFT = (stInfo.nDimensions - 2 - 4)/2;
    
    % desired feature RMS
    szFeature = 'RMS';
    
    % get all available feature file data for RMS
    mRMS = getObjectiveData(obj, szFeature, 'stInfo', stDate, ...
        'useCompression', useCompression);
    
    % desired feature
    szFeature = 'ZCR';
    
    % get all available feature file data for ZCR
    mZCR = getObjectiveData(obj, szFeature, 'stInfo', stDate,...
        'useCompression', useCompression);
    
    % number of time frames
    nBlocks = size(Pxx, 1);
    
    
    % "Empirischer Quartilsdispersionskoeffizient" calculated for
    % 10 adjacent RMS frames
    mEQD = EQD(mRMS, nBlocks);
    
    
    % subsample RMS and ZCR by factor 10 (according to privacy option of PSDs)
    nRemain = rem(size(mRMS, 1), 10*nBlocks);
    if nRemain ~= 0 && nRemain ~= size(mRMS, 1)
        mRMS(end-nRemain+1:end, :) = [];
        mZCR(end-nRemain+1:end, :) = [];
    end
    mRMS = mRMS(1:10:end, :);
    mZCR = mZCR(1:10:end, :);
    
    
    % calculate Mel Frequency Cepstral Coefficients
    isPowerSpec = true;
    [mfcc] = calcMFCC(Pxx', SampleRate, nFFT, isPowerSpec);
    mfcc = mfcc';
    
    
    % call OVD by Schreiber 2019
    stDataOVD = OVD3(Cxy, Pxx, Pyy, SampleRate, mRMS);
    
    % mean real coherence (averaged between 400 - 1000 Hz)
    mMeanRealCoherence = stDataOVD.meanCoheTimesCxy;
    
    % a posteriori speech presence probability according to Gerkmann 2010
    vFreqRange = [400 1000];
    vFreqBins = round(vFreqRange./SampleRate*nFFT);
    mMeanSPP = mean(stDataOVD.PH1(vFreqBins(1):vFreqBins(2),:),1)';
    
    
    % calculate correlation of real(Cxy) scaled to RMS with hannwin combs
    Cxy_scaled = real(Cxy)./mean(mRMS, 2);
    correlation = CalcCorrelation(Cxy_scaled, SampleRate, nFFT/2+1);
    
    % calculate the "RMS" of the correlation
    mCorrRMS = sqrt(sum(correlation.^2, 2));
    
    
    
    % sum up fft bins to bands given in halftones
    resolution_halftones = 8;
    MinMaxFreqs_Hz = [62.5 12000];
    
    [FreqTMatrix] = fft2Bands(nFFT, SampleRate, resolution_halftones, MinMaxFreqs_Hz);
    
    Pxx = Pxx*FreqTMatrix(1:nFFT/2+1, :);
    Cxy = Cxy*FreqTMatrix(1:nFFT/2+1, :);
    
    % check for low sampling frequencies thus unreached octaves
    Pxx(:, ~any(Pxx ~= 0)) = NaN;
    Cxy(:, ~any(Cxy ~= 0)) = NaN;
    
end


% save extracted features as mat file
if ~isCalculated
    save([szDir filesep szFile], 'mRMS', 'mZCR', 'mfcc', 'mMeanRealCoherence',...
        'mMeanSPP', 'mEQD', 'mCorrRMS', 'Pxx', 'Cxy');
    
    if ~nargout
        return;
    end
end


% set column index for data set matrix
idxColumn = 1;

% add variables to data set
for iVar = 1:length(szVarNames)
    
    if ~strcmp(szVarNames{iVar}, 'vGroundTruthVS')
        
        % save temporary current variable
        mTemp = real(eval(szVarNames{iVar}));
        
        % current dimension
        nDim = size(mTemp, 2);
        
        % current number of blocks
        nBlocks = size(mTemp, 1);
        
        % append
        mDataSet(1:nBlocks, idxColumn:idxColumn+nDim-1) = mTemp;
        
        % adjust column index
        idxColumn = idxColumn + nDim;
    end
end


if isCalcPSD
    % use no compression
    useCompression = false;
    
    % reading objective data, desired feature PSD
    szFeature = 'PSD';
    
    % get all available feature file data for PSD
    [DataPSD,TimePSD] = getObjectiveData(obj, szFeature, 'stInfo', stDate, ...
        'useCompression', useCompression);
    
    if isempty(DataPSD)
        return;
    end
    
    % extract PSD data
    version = 1; % JP modified get_psd
    [Cxy, Pxx, Pyy] = get_psd(DataPSD, version);
end

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