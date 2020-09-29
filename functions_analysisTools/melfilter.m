function [Filter,MelFrequencyVector] = melfilter(N,FrequencyVector,hWindow,useFreq)
% melfilter         Create a mel frequency filterbank
%
%   [Filter,MelFrequencyVector] = melfilter(N,FrequencyVector,hWindow)
%
%   Generates a filter bank matrix with N lineary spaced filter banks, 
%   in the Mel frequency domain, that are overlapped by 50%.
%
%   `N` the number of filter banks to construct.
%
%   `FrequencyVector` a vector indicating the frequencies at which to
%   evaluate the filter bank coeffiecents.
%
%   `hWindow` a handle to the windowing function that determines the shape
%   of the filterbank. The default is hWindow = @triang
%
%   `Filter` is sparse matrix of size [N numel(FrequencyVector)].
%
%   `MelFrequencyVector` is a vector containing the Mel frequency values
%
%   Example
%       N = 50;
%       Fs = 10000;
%       x = sin(2*pi*110*(0:(1/Fs):5));
%       [Pxx,F] = periodogram(x,[],512,Fs);
%
%       Filter = melfilter(N,F);
%       Filter = melfilter(N,F,@rectwin);
%       [Filter,MF] = melfilter(N,F,@blackmanharris);
%
%       FPxx = Filter*Pxx;
%
%   See also
%       melfilter melbankm mfcceps hz2mel
%

%% Author Information
%   Pierce Brady
%   Smart Systems Integration Group - SSIG
%	Cork Institute of Technology, Ireland.
% 

%% Reference
%   F. Zheng, G. Zhang, Z. Song, "Comparision of Different Implementations
%   of MFCC", Journal of Computer Science & Technology, vol. 16, no. 6, 
%   September 2001, pp. 582-589
%
%   melbankm by Mike Brookes 1997
%
% edited by JP (Aug-2020): added boolean 'useFreq' to use specific frequencies

%% Assign defaults
if nargin<3 || isempty(hWindow), hWindow = @triang; end
if nargin<4, useFreq = true; end

%%
% Convert to mel scale
MelFrequencyVector = 2595*log10(1+FrequencyVector/700);   
if useFreq % use specific frequencies
    MaxF = 2595*log10(1+12000/700);                  
    MinF = 0; 
else
    MaxF = max(MelFrequencyVector);                  
    MinF = min(MelFrequencyVector);  
end  

MelBinWidth = (MaxF-MinF)/(N+1); 

% Predefine loop matrix
Filter = zeros([N numel(MelFrequencyVector)]);  

%% Construct filter bank
for i = 1:N
    iFilter = find(MelFrequencyVector>=((i-1)*MelBinWidth+MinF) & ...
                    MelFrequencyVector<=((i+1)*MelBinWidth+MinF));
    
    % number of frequency bins
    nBins = numel(iFilter);
                
    % check for low sampling frequencies thus unreached frequencies
    if max(MelFrequencyVector) < (i+1)*MelBinWidth+MinF 
        
        if isempty(iFilter)
            Filter = Filter(1:i-1, :);
            break;
        end
        
        % resolution of frequency bins (Hz)
        nRes = FrequencyVector(2) - FrequencyVector(1);
        
        % determine number of missing bins
        editBins = ceil((mel2hz((i+1)*MelBinWidth+MinF) - max(FrequencyVector))/nRes);
        nBins = nBins + editBins;
    end
    
    TriangleWindow =  hWindow(nBins);
                
    Filter(i,iFilter) = TriangleWindow(1:numel(iFilter)); 
end
Filter = sparse(Filter);    % Reduce memory size

end
