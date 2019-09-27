function [stBandDef]=fftbin2freqband(FftSize,stBandDef)
% function to regroup fft sized spectra into bands
% Usually the resulting Matrix for computing the output power in one band
% by using out = ReGroupMatrix*FFTSpectrum
% Usage [ReGroupMatrix,ReGroupIndexMatrix]=fftbin2freqband(FftSize,BandDef)
%
% Parameters
% ----------
% FftSize :  integer, usually power of 2 +1 (positive spectrum only)
%	 explanation
% stBandDef :  struct with definition of the frequency bands
%          .StartFreq
%          .EndFreq
%          .Mode (String , 'Oct','OneThird','Semi','Bark','Mel')
%          .Semitones (if 'Semi' the number of semitones in one band
%          .fs (The sampling rate )
%          .NrOfBands (Can be set or is computed)
%          .skipFrequencyNormalization
%
% Returns
% -------
% stBandDef.ReGroupMatrix :  matrix FftSize x NrOffBands
% stBandDef.ReGroupIndexMatrix :  matrix FftSize x NrOffBands only 0,1
% stBandDef.MidFreq : vector with the computed mid frequencies (accuracy 5 Hz)
%------------------------------------------------------------------------
% Example: Provide example here if applicable (one or two lines)

% Author: J. Bitzer (c) TGM @ Jade Hochschule applied licence see EOF
% Version History:
% Ver. 0.01 initial create (empty) 17-May-2017  Initials (eg. JB)
% Ver 1.0 first implmentation with one-third filterbank

% Todo
% 1) implement mel and bark scaling
% 2) implement exact weights at the band edges (fraction of bin)

%------------Your function implementation here---------------------------

% since semi, oct und onethird octave are all related, use ons solution
if ~isfield(stBandDef,'skipFrequencyNormalization')
    stBandDef.skipFrequencyNormalization = 0;
end

if strcmpi(stBandDef.Mode,'semi') || strcmpi(stBandDef.Mode,'oct') ||...
        strcmpi(stBandDef.Mode,'onethird')
    
    if strcmpi(stBandDef.Mode,'semi')
        semitones = stBandDef.Semitones;
    elseif strcmpi(stBandDef.Mode,'oct')
        semitones = 12;
    elseif strcmpi(stBandDef.Mode,'onethird')
        semitones = 4;
    end
    fref = 1000; % typical acoustic reference, not musical
    
    % compute lower and higher index of the seimtone according to fref
    semiindex = (log2(stBandDef.StartFreq/fref)* (12/semitones));
    semistart = floor(semiindex);
    semistart_frac = semiindex-semistart;
    semiindex = (log2(stBandDef.EndFreq/fref)* (12/semitones));
    semiend = ceil(semiindex);
    semiend_frac = semiindex-semiend;
    
    % map to mid frequncies and band edges
    freq_vek_mid = fref.*2.^([semistart:semiend]./(12/semitones));
    stBandDef.MidFreq = round(freq_vek_mid/5)*5;
    freq_vek_lower = freq_vek_mid.* 2.^(-1/(24/semitones));
    freq_vek_higher = freq_vek_mid.* 2.^(1/(24/semitones));
    
    % remap to fftbin
    freq_vek_fftbin_low = freq_vek_lower.*(FftSize-1)/(stBandDef.fs/2);
    freq_vek_fftbin_high = freq_vek_higher.*(FftSize-1)/(stBandDef.fs/2);
    
    freq_idx_low = round (freq_vek_fftbin_low)+1;
%     if (length(freq_idx_low) ~= length(unique(freq_idx_low)))
%         warning('FFTSize is too small to have meaningfull separation at lower frequencies');
%     end
    freq_idx_high = round (freq_vek_fftbin_high)+1;
    idx_toohigh = find(freq_idx_high > FftSize);
    if ~isempty (idx_toohigh)
        freq_idx_high(idx_toohigh) = FftSize;
    end
    
    % build regrouping matrices as the output values
    stBandDef.ReGroupMatrix= zeros(FftSize,length(freq_idx_high));
    stBandDef.ReGroupIndexMatrix = zeros(FftSize,length(freq_idx_high));
    
    for kk = 1:length(freq_idx_low)
        stBandDef.ReGroupIndexMatrix(freq_idx_low(kk):freq_idx_high(kk),kk) = 1;
        BandWeight = freq_vek_higher(kk)-freq_vek_lower(kk);
        if (stBandDef.skipFrequencyNormalization== 0)
            stBandDef.ReGroupMatrix(freq_idx_low(kk):freq_idx_high(kk),kk) = 1/BandWeight;
        else
            stBandDef.ReGroupMatrix(freq_idx_low(kk):freq_idx_high(kk),kk) = 1/(freq_idx_high(kk) - freq_idx_low(kk)+1 );
        end
    end
end
if strcmpi(stBandDef.Mode,'mel')
    warning('not implemented yet');
    % shoul dbe straighforward by using the solution in MFCC feature file
    % (see below)
end
if strcmpi(stBandDef.Mode,'bark')
    warning('not implemented yet');
    % should be straight forward by using barkband filter (see below)
end

%% Old code for barkfilter
% function [Filter,BarkFrequencyVector] = barkfilter(N,FrequencyVector,hWindow)
% % barkfilter         Create a bark frequency filterbank
% % 
% %   [Filter,MelFrequencyVector] = barkfilter(N,FrequencyVector,hWindow)
% %
% %   Generates a filter bank matrix with N lineary spaced filter banks, 
% %   in the Bark frequency domain, that are overlapped by 50%.
% %
% %   `N` the number of filter banks to construct.
% %
% %   `FrequencyVector` a vector indicating the frequencies at which to
% %   evaluate the filter bank coeffiecents.
% %
% %   `hWindow` a handle to the windowing function that determines the shape
% %   of the filterbank. The default is hWindow = @triang
% %
% %   `Filter` is sparse matrix of size [N numel(FrequencyVector)].
% %
% %   `MelFrequencyVector` is a vector containing the Bark frequency values
% %
% %   Example
% %       N = 50;
% %       Fs = 10000;
% %       x = sin(2*pi*110*(0:(1/Fs):5));
% %       [Pxx,F] = periodogram(x,[],512,Fs);
% %
% %       Filter = barkfilter(N,F);
% %       Filter = barkfilter(N,F,@rectwin);
% %       [Filter,MF] = barkfilter(N,F,@blackmanharris);
% %
% %       FPxx = Filter*Pxx;
% %
% %
% 
% %% Author Information
% % Jens-Alrik Adrian.
% % This code is adapted by the function 'melfilter.m' created by Pierce
% % Brady:
% % 
% %   Pierce Brady
% %   Smart Systems Integration Group - SSIG
% %	Cork Institute of Technology, Ireland.
% % 
% 
% %% Assign defaults
% if nargin<3 || isempty(hWindow), hWindow = @triang; end
% 
% %%
% % Source:
% % https://en.wikipedia.org/wiki/Bark_scale
% BarkFrequencyVector = ...
%     ((26.81 * FrequencyVector) ./ (1960 + FrequencyVector)) - 0.53; % Convert to bark scale
% 
% BarkFrequencyVector(BarkFrequencyVector < 2) = ...
%     BarkFrequencyVector(BarkFrequencyVector < 2) + ...
%     0.15*(2 - BarkFrequencyVector(BarkFrequencyVector < 2));
% BarkFrequencyVector(BarkFrequencyVector > 20.1) = ...
%     BarkFrequencyVector(BarkFrequencyVector > 20.1) + ...
%     0.22*(BarkFrequencyVector(BarkFrequencyVector > 20.1) - 20.1);
% 
% MaxF = max(BarkFrequencyVector);                 % 
% MinF = min(BarkFrequencyVector);                 %
% BarkBinWidth = (MaxF-MinF) / (N+1);                %
% Filter = zeros([N numel(BarkFrequencyVector)]);  % Predefine loop matrix
% 
% %% Construct filter bank
% for i = 1:N
%     iFilter = find(BarkFrequencyVector>=((i-1)*BarkBinWidth+MinF) & ...
%                     BarkFrequencyVector<=((i+1)*BarkBinWidth+MinF));
%     Filter(i,iFilter) = hWindow(numel(iFilter)); % Triangle window
% end
% Filter = sparse(Filter);    % Reduce memory size
% 
% end

%% und f�r Mel
% %--------------------------------------------------------------------------
% % Usage: Script calculates spectral energy within a triangular-filter. Init file. 
% %
% % Author: Joerg Bitzer 
% %
% % Date: -
% %
% % Updated: -
% %
% % Copyright: Joerg Bitzer
% %--------------------------------------------------------------------------
% 
% % Mfcc - feature initialization and configuration.
% function [ stFeatureConfig, bInitSuccess ] = ...
%     mfcc_Init( blockSize, fs )
% 
% 
% %-------------------------------------------------------------------------%
% % This struct contains all feature specific parameters and data, i.e.     %
% % everything you might need during a call of the "*_Process" routine.     %
% % (E.g. cut-off frequencies, filter-banks, state-buffers etc.)            %
% %-------------------------------------------------------------------------%
% % Create an empty struct. All members may be added separately, as follows.
% % Note: It's complely up to you, which elements this struct contains. ALL
% %       of them will be avaliable inside the "*_Process" function.
% stFeatureData = struct;
% 
% % The number of coefficients defines the number of triangular filters.
% stFeatureData.NumCoeffs     =    12;
% % This is the b1 coefficient of the preemphasis filter.
% stFeatureData.PreEmphFactor = -0.97;
% 
% % Get the nearest Pow2 block size, larger or equal to the block size,
% % specified by the block processing.
% stFeatureData.FftSize = pow2( ceil( log2( blockSize ) ) );
% 
% % Generate the window, used before computation of FFT. Though this is the
% % FFT window, its size must be equal to the block size, which may be
% % smaller than the FFT size.
% stFeatureData.Window = hann( blockSize, 'symmetric' );
% 
% % Lowest frequency that is processed.
% stFeatureData.FregMin    =  400; % in Hz
% % Highest frequency that is processed.
% stFeatureData.FregMax    = 8000; % in Hz
%     
% % Call another function, to generate the mel frequency based filter bank.
% stFeatureData.MelFilterBank = fbankT( stFeatureData.NumCoeffs , ...
%                                       stFeatureData.FftSize   , ...
%                                       fs                      , ...
%                                       stFeatureData.FregMin   , ...
%                                       stFeatureData.FregMax    );
% %-------------------------------------------------------------------------%
% 
% 
% 
% %-------------------------------------------------------------------------%
% % Check for errors, related to the feature configration in combination    %
% % with the current block size/samplerate, e.g. filter frequencies above   %
% % half the sample rate, non-Pow2 block sizes on Pow2 algorithms, etc.     %
% %-------------------------------------------------------------------------%
% % Checking this completely depends on the feature and its parameters!     %
% %-------------------------------------------------------------------------%
% % Anyway if everything is fine, the variable "bInitSuccess" should become %
% % "true" otherwise "false".                                               %
% %-------------------------------------------------------------------------%
% % Create a variable, taht'll return the "error-state". (Initialized to
% % the value "true", because we don't know about any errors, yet.
% bInitSuccess = true;
% 
% % In case of this MFCC feature, we have to check the filter bank. Too low
% % frequency resolutions might cause some filters to contain no non-zero
% % factors.
% if(~all( any( stFeatureData.MelFilterBank, 2 ) ) )
%     % So, if not all filters contained at least one non-zero factor,
%     % the initialization was unsuccessful.
%     bInitSuccess = false;
%     % Display a warning, so the user knows something went wrong.
%     warning( ['At least one filter contains no non-zero factors. ', ...
%               'Reducing "NumCoeffs" and/or increasing "FregMin" ' , ...
%               'might resolve this problem or you should consider ', ...
%               'using larger block sizes and/or sample rates'      ] );
% end
% 
% % And we also have to check, if the frequency settings might exceed half
% % the sampling rate.
% if( (stFeatureData.FregMin > fs / 2) || ...
%     (stFeatureData.FregMax > fs / 2) )
%     % If they do, the initialization was unsuccessful.
%     bInitSuccess = false;
%     % Display a warning, so the user knows something went wrong.
%     warning('Feature configuration and sample rate don''t mix.');
% end
% %-------------------------------------------------------------------------%
% 
% 
% 
% %-------------------------------------------------------------------------%
% % This struct contains all data, relevant for handling input and output   %
% % arguments of the "*_Process" function. (And writing the extracted       %
% % features to disk.)                                                      %
% %-------------------------------------------------------------------------%
% % Note, that all of these Parameters are mandatory!                       %
% %-------------------------------------------------------------------------%
% % Create an empty struct. All members may be added separately, as follows.
% stFeatureInfo = struct;
% 
% % The full name of this feature.
% stFeatureInfo.Name          = 'Mel-Frequency based Cepstral Coefficients';
% % File extension that is used for naming and writing the feature files.
% stFeatureInfo.FileExtension = 'mfcc';
% % The number of feature values the feature extraction algorithm extracts.
% % This might be a single value (e.g. total power) or a complete set of
% % values (e.g. LPC coefficients). This parameter might even depend on the
% % actual configuration of the feature extraction.
% stFeatureInfo.NumDimensions = stFeatureData.NumCoeffs;
% %-------------------------------------------------------------------------%
% 
% 
% 
% %-------------------------------------------------------------------------%
% % Combine both feature structs to another struct which'll be returned by  %
% % this function.                                                          %
% %-------------------------------------------------------------------------%
% stFeatureConfig = struct( ...
%     'stFeatureInfo', stFeatureInfo , ...
%     'stFeatureData', stFeatureData  ...
%     );
% %-------------------------------------------------------------------------%
% 
% %eof
% 
% 
% 
% 
% 
% 
% %-------------------------------------------------------------------------%
% % Here are the defintionions of some local functions. Each of them might  %
% % as well be placed in a seperate file. In fact each of them was placed   %
% % in a seperate file, but then I decided to put them all here, reducing   %
% % the number of files.                                                    %
% %-------------------------------------------------------------------------%
% % Don't get confused with the names of some variables. Scopes of all      %
% % variables and names are limited to a local function, i.e. all variables %
% % exist only inside a single function. The end of each function is marked %
% % by a '%eof'.                                                            %
% %-------------------------------------------------------------------------%
% 
% 
% 
% 
% 
% 
% %MEL(f)  Converts from Hz scale to Mel scale.
% %
% %   See also IMEL.
% function m = mel(f), m = 2595.*log10(1+f.*(1/700));
% %eof
% 
% 
% 
% 
% 
% 
% %IMEL(m)  Converts from Mel scale to Hz scale.
% %
% %   See also MEL.
% function f = imel(m), f = (10.^(m./2595)-1).*700;
% %eof
% 
% 
% 
% 
% 
% 
% function [filterWeights,fftFreqs] = fbankT(nbFilters,fftSize,samplingRate,minFreq,maxFreq)
% % [fbTrMx,Freqs] =
% %       fbankT(nbFilters,<fftSize,samplingRate,minFrequency,maxFrequency>)
% % 
% % Filter bank Transformation matrix  ( nbFilters x fftSize/2 )
% % 
% % defaults for optional parameters < >:
% %   
% %   fftSize      = 512
% %   samplingRate = 8000
% %   minFrequency = 0
% %   maxFrequency = samplingRate/2
% % 
% %                                        -mijail. 20/march/2001
%   
% % FBANK Parameters: ********************
%   
%  if (nargin < 2) fftSize = 512; end;
%  if (nargin < 3) samplingRate = 8000; end;
%  if (nargin < 4) minFreq = 0; end;
%  if (nargin < 5) maxFreq = samplingRate/2; end;
% 
% 
% % PROCESSING : ********************************
% 
%  % Figure out the band edges.
%  % Interesting frequencies are lineary spaced in Mel scale. 
%  freqs=imel(linspace(mel(minFreq),mel(maxFreq),nbFilters+2));
% 
%  % Lower, center, and upper band edges are consecutive interesting freqs. 
%  lower = freqs(1:nbFilters);
%  center = freqs(2:nbFilters+1);
%  upper = freqs(3:nbFilters+2);
% 
%  % Reserving memory for the transformation matrix
%  filterWeights = zeros(nbFilters,fftSize/2);
% 
%  % Assuming a triangular weighting function.
%  triangleHeight =ones(1,nbFilters);    % height is constant = 1
%  % triangleHeight = 2./(upper-lower);  % weight is constant = 1
% 
%  % frequency bins
%  fftFreqs = (0:fftSize/2-1)/fftSize*samplingRate;
% 
%  % Figure out each frequencies contribution
%  for chan=1:nbFilters
% 	filterWeights(chan,:) =... 
%   (fftFreqs > lower(chan) & fftFreqs <= center(chan)).* ...
%    triangleHeight(chan).*(fftFreqs-lower(chan))/(center(chan)-lower(chan)) + ...
%   (fftFreqs > center(chan) & fftFreqs < upper(chan)).* ...
%    triangleHeight(chan).*(upper(chan)-fftFreqs)/(upper(chan)-center(chan));
% end
% 
% % plot(fftFreqs,filterWeights');
% % axis([lower(1) upper(nbFilters) 0 max(max(filterWeights))])
% 


%--------------------Licence ---------------------------------------------
% Copyright (c) <2017> J. Bitzer
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