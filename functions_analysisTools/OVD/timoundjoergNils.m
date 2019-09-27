function [shat, snrPrio, noisePow, gainMat,PH1] = timoundjoergNils(noisy,fs,flagTimoJoerg)
% Usage shat = timoundjoergNR(noisy,fs,flagTimoJoerg)
% noisy: the noisy signal that should contain noise only at the beginning
% fs, samping rate
% flagTimoJoerg: switch to change Algo 0 = Timo Gerkmans original, 1 =
% Joerg Bitzers alternative
% this file performs single channel noise reduction based on
% [1] Timo Gerkmann, Richard C. Hendriks, "Unbiased MMSE-based Noise
%   Power Estimation with Low Complexity and Low Tracking Delay",
%   IEEE Trans. Audio, Speech and Language Processing, 2012

% [2] Colin Breithaupt, Timo Gerkmann, Rainer Martin, "A Novel A Priori
%   SNR Estimation Approach Based on Selective Cepstro-Temporal Smoothing",
%   IEEE Int. Conf. Acoustics, Speech, Signal Processing, Las Vegas, NV, USA, Apr. 2008.
%
% Author Timo Gerkmann, Universitaet Oldenburg, Germany 2012
% All rights reserved.
% slightly enhanced by J Bitzer, Jade HS , March 2015
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the Universitaet Oldenburg nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
% if (fs ~= 16e3)&&(fs ~= 8e3)
%     warning('optimized for 16kHz and 8 kHz sampling rate! Parameters are generalized though, so the code should also work reasonably for other sampling rates.')
% end
% disp(' ')
% if flagTimoJoerg == 0
%     disp('(c) Timo Gerkmann, Universitaet Oldenburg, 2012');
% else
%     disp('(c) Timo Gerkmann, Universitaet Oldenburg, 2012, J. Bitzer, Jade HS Oldenburg, 2015');
% end
disp(' ')
noisy = noisy.';
noisy(isnan(noisy)) = eps*10^-1;
noisy(noisy == 0) = eps*10^-1;
%% some constants
SNR_LOW_LIM = 10^(-20/10);
MIN_GAIN = 10^(-20/20);

frLen = size(noisy,2);
fShift  = frLen;   % frame shift
nFrames = size(noisy,1); % number of frames

%% alocate some memory
shat = zeros(size(noisy,1), floor(size(noisy,2)));
gainMat = zeros(fliplr(size(noisy)));


%% initialize
% % first 50 frames!
% noisePow = init_noise_tracker_ideal_vad(noisy,frLen,frLen,fShift, anWin); % This function computes the initial noise PSD estimate. It is assumed that the first 5 time-frames are noise-only.
% if nargin == 4
%     noisePow = zeros(size(noisy,2),size(noisy,1)+1);
%     noisePow(:,1) = np;
% else
    noisePow = zeros(size(noisy,2),size(noisy,1)+1);
    noisePow(:,1)= mean(noisy(1,:)); % This function computes the initial noise PSD estimate. It is assumed that the first 5 time-frames are noise-only.
% end


%constants for a posteriori SPP
q		     = 0.5; % a priori probability of speech presence:
priorFact	 = q./(1-q);
xiOptDb		 = 15; % optimal fixed a priori SNR for SPP estimation
xiOpt 		 = 10.^(xiOptDb./10);
logGLRFact 	 = log(1./(1+xiOpt));
GLRexp		 = xiOpt./(1+xiOpt);
PH1mean		 = 0.5;
alphaPH1mean = 0.9;
alphaPSD 	 = 0.8;


MaxFreq = round(1400/fs*frLen);

FreqSmoothStates = zeros(MaxFreq,1);

AlphaVek = linspace(0.15,0.02,MaxFreq);

FreqSmoothAlpha = exp(-fShift./(AlphaVek.*fs))';

LowFreqStrength = 0.6; % = 1 lowest pitch is enhanced but NR is lower 0.6 is close to the original
snrprio_new = zeros(frLen, nFrames);
snrPrio = zeros(frLen, nFrames);
PH1 = zeros(frLen, nFrames);
% figure; 
for indFr = 1:nFrames
    noisyPer = noisy(indFr,:).';
    
    snrPost1 =  noisyPer./(noisePow(:,indFr));% a posteriori SNR based on old noise power estimate
        
    %% noise power estimation
    GLR     = priorFact .* exp(min(logGLRFact + GLRexp.*snrPost1,200));
    PH1(:,indFr)     = GLR./(1+GLR); % a posteriori speech presence probability
    
    PH1mean  = alphaPH1mean * PH1mean + (1-alphaPH1mean) * PH1(:,indFr);
    stuckInd = PH1mean > 0.99;
    PH1(stuckInd,indFr) = min(PH1(stuckInd,indFr),0.99);
    estimate =  PH1(:,indFr) .* noisePow(:,indFr) + (1-PH1(:,indFr)) .* noisyPer ;
    noisePow(:,indFr+1) = alphaPSD*noisePow(:,indFr)+(1-alphaPSD)*estimate;
%     plot(noisePow(:,indFr+1))
    
    
    
    %% SNR estimation
    snrPost =  noisyPer./(noisePow(:,indFr+1));%a posteriori SNR
    
    % Timos Algo
    if indFr == 1
        [snrPrio(:,indFr), cepSNRstate] = cepSNR( noisyPer, noisePow(:,indFr+1), fs, true);
    else
        [snrPrio(:,indFr), cepSNRstate] = cepSNR( noisyPer, noisePow(:,indFr+1), fs, false, cepSNRstate);
    end
    
    % Joergs Alternative
    snrPrioML = snrPost-1; %[2] ( eq 1)
    
    % [2] eq 2
    snrfloor = 0.001;
    snrPrioML(snrPrioML<snrfloor) = snrfloor;
    
    lambda_ml = snrPrioML.*noisePow(:,indFr+1);
    
    % [2] eq 4
    lambda_ml_log = log(lambda_ml);
    lambda_ceps = ifft([lambda_ml_log; lambda_ml_log(end-1:-1:2)]);
    
    % lambda_ceps modified
    lambda_ceps_m = lambda_ceps(1:round(frLen));
    kernal = hann(81);
    kernal = kernal./sum(kernal.*kernal);
    
    lambda_ceps_m2 = conv(lambda_ceps_m,kernal);
    lambda_ceps_m2(1:(length(kernal)-1)/2) = [];
    lambda_ceps_m2(length(lambda_ceps_m)+1:end) = [];
    
    
    lambda_ceps_m(20:end) = lambda_ceps_m2(20:end)*LowFreqStrength;
    lambda_ceps_help = lambda_ceps;
    lambda_ceps_help(lambda_ceps_help< 0.2) = 0;
    
    f_low = 100;
    f_high = 300;
    
    idx_fh = round(fs/f_high);
    idx_fl = round(fs/f_low);
    [maxval,maxidx] = max(lambda_ceps_help(idx_fh:idx_fl));
    pitchmargin = 2;
    if maxval > 0
        lambda_ceps_m(round(fs/f_high)+maxidx-2-pitchmargin:round(fs/f_high)+maxidx+pitchmargin) =1*lambda_ceps(round(fs/f_high)+maxidx-2-pitchmargin:round(fs/f_high)+maxidx+pitchmargin);
    end
    
    
    lambda_ceps_final = [lambda_ceps_m; lambda_ceps_m(end-1:-1:2)];
    
    
    lambda_ml_sm = exp(real(fft(lambda_ceps_final)));
    snrprio_new(:,indFr) = lambda_ml_sm(1:floor(frLen))./noisePow(:,indFr+1);
    FreqSmoothStates = FreqSmoothAlpha.*FreqSmoothStates + (1-FreqSmoothAlpha).*snrprio_new(1:MaxFreq,indFr);
    snrprio_new(1:MaxFreq,indFr) = FreqSmoothStates;
    %     plot(snrprio_new)
    
    %     if maxval > 0.8
    %         snrprio_new(5:30) = snrPrioML(5:30);
    %     end
    
    
    gain2 = snrprio_new(:,indFr)./(1+snrprio_new(:,indFr));
    gain2=max(gain2,MIN_GAIN);
    
    %% Wiener filter
    gain = snrPrio(:,indFr)./(1+snrPrio(:,indFr));
    
    
    %% apply spectral floor
    gain=max(gain,MIN_GAIN);
    
    if flagTimoJoerg == 1
        gain = gain2;
%         snrPrio(:,indFr) = snrprio_new(:,indFr);
    end
    %% store matrices
    gainMat(:,indFr) = gain;
    shatDftFrame=gain.*noisyPer;
    
    %     shat_ = real(ifft( [shatDftFrame; conj(shatDftFrame(end-2:-1:2))], 'symmetric' ));
    shat(indFr,:) = ( shatDftFrame.');
end
noisePow(:,1:floor(size(noisePow,2)/2)) = [];

noisePow(:,end) = [];
shat(1:end/2,:) = [];
shat = shat.';
snrPrio(:,1:end/2) = [];
snrprio_new(:,1:end/2) = [];
gainMat(:,1:end/2) = [];
if flagTimoJoerg
    snrPrio = snrprio_new;
end
PH1(:,1:floor(size(PH1,2)/2)) = [];
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function   noise_psd_init =init_noise_tracker_ideal_vad(noisy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%This m-file computes an initial noise PSD estimate by means of a
%%%%Bartlett estimate.
%%%%Input parameters:   noisy:          noisy signal
%%%%                    fr_size:        frame size
%%%%                    fft_size:       fft size
%%%%                    hop:            hop size of frame
%%%%                    sq_hann_window: analysis window
%%%%Output parameters:  noise_psd_init: initial noise PSD estimate
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%Author: Richard C. Hendriks, 15/4/2010
%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%
% nFrames = 5;
% noisy_dft_frame_matrix = zeros(fft_size,nFrames);
% for I=1:nFrames
% %     noisy_frame=sq_hann_window.*noisy((I-1)*hop+1:(I-1)*hop+fr_size);
% %     noisy_dft_frame_matrix(:,I)=fft(noisy_frame,fft_size);
%     noisy_dft_frame_matrix(:,I) = noisy(I,:).';
% end
noise_psd_init=mean((noisy(1,:)).^2,2);%%%compute the initialisation of the noise tracking algorithms.

% EOF