function [ResultOVD,MeanCohTimeSmoothed,TimeVec]=computeOVD_Coh(CohMat,TimeVec,stAlgoInfo)
% function to compute the decision if the own voice was present in a
% complex valued coherence matrix
% Usage [ResultOVD,MeanCoherence,TimeVec]=computeOVD_Coh(CohMat,TimeVec,stAlgoInfo)
%
% Parameters
% ----------
% CohMat :  matrix (NrOfCoherenceEntries x FFTSize)
%	 the matrix should contain the data with 8Hz sampling frequency and 257
%	 frequncy values (0 ... fs/2) with fs = 16000 or specified in
%	 stAlgoInfo.fs
% TimeVec :  a datetime vector containing the sampling times
%	 explanation
% stAlgoInfo :  struct
%	 a struct with all necessary information for the algo
%           .fs  = the sampling frequency of the original data
% Returns
% -------
% ResultOVD :  vector
%	 a 0 and 1 vector if Own voice is present or not
% MeanCoherence :  a vector of the decision vector
%	 explanation
% TimeVec :  the time vector (maybe shifted to compensate for the latency of the algorithm)
%	 explanation
%
%------------------------------------------------------------------------ 
% Example: Provide example here if applicable (one or two lines) 

% Author: J. Bitzer (c) TGM @ Jade Hochschule applied licence see EOF 
% Source: If the function is based on a scientific paper or a web site, 
%         provide the citation detail here (with equation no. if applicable)  
% Version History:
% Ver. 0.01 initial create (empty) 23-May-2017  Initials (eg. JB)

%------------Your function implementation here--------------------------- 
AnalysisBand_Hz = [400 1000];
Thresh = 0.6;
FFTSize = size(CohMat,2);

if ~isfield(stAlgoInfo,'additive')
    stAlgoInfo.additive = 0.0;
end

freqidx = round(FFTSize*AnalysisBand_Hz/(stAlgoInfo.fs/2));
MeanCoh = mean(real(CohMat(:,freqidx(1):freqidx(2))),2);

CohTimeSmoothing_s = 1;
fs_cohdata = 1/0.125;

alpha = exp(-1./(CohTimeSmoothing_s*fs_cohdata));

MeanCohTimeSmoothed = filter([1-alpha],[1 -alpha],MeanCoh);

ResultOVD = zeros(size(MeanCoh));

if isfield(stAlgoInfo,'adapThresh') && stAlgoInfo.adapThresh
    adapThreshMax    = movmax(MeanCohTimeSmoothed,floor(stAlgoInfo.adapThresh*stAlgoInfo.fs));
    adapThreshMin    = movmin(MeanCohTimeSmoothed,floor(stAlgoInfo.adapThresh*stAlgoInfo.fs));
    adapThresh       = ((adapThreshMax + adapThreshMin)./2).*(1.0+stAlgoInfo.additive);
    % mark the own voice segments using the adaptive treshold
    ResultOVD        = MeanCohTimeSmoothed >= adapThresh;
else
    ResultOVD(MeanCohTimeSmoothed > Thresh) = 1;
end



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