function [correlation, spectrum] = magnitude_correlation(signal, samplerate, blocksize, hopsize, basefrequencies, nfft)
    % Correlate synthetic tone complex spectra with a true spectrum.
    %
    % Generate spectra at a number of given base frequencies, then
    % correlate each of these spectra with the magnitude signal
    % STFT-spectra.
    %
    % Before correlation, each frequency bin is log-weighted to make the
    % correlation perceptually accurate.
    %
    % signal: A vector of doubles
    % samplerate: A scalar in Hz
    % blocksize: A scalar in samples
    % hopsize: A scalar in samples
    % basefrequencies: An ordered list of base frequencies in Hz.
    %
    % Returns a len(blocks) x len(basefrequencies) matrix of correlation values.

    if nargin == 5
        specsize = floor(blocksize / 2) + 1;
    else
        specsize = floor(nfft / 2) + 1;
    end

    % weigh differences according to perception:
    f = linspace(0, samplerate/2, specsize);
    log_f_weight =  1 ./ (samplerate/2).^(f / (samplerate/2));

    correlation = zeros(numblocks(signal, blocksize, hopsize), length(basefrequencies));
    spectrum = zeros(numblocks(signal, blocksize, hopsize), specsize);
    synthetic_magnitudes = synthetic_magnitude(samplerate, specsize, basefrequencies);
    
    %% Jule
%     freqs = linspace(0, samplerate/2, specsize);
%     FundFreq = [130 200];
%     idxFundFreq(1) = find(basefrequencies >= FundFreq(1), 1);
%     idxFundFreq(2) = find(basefrequencies >= FundFreq(2), 1);
%     figure;
%     subplot(2,1,1);
%     plot(freqs, synthetic_magnitudes(idxFundFreq(1), :));
%     ylabel('T^M(f, 130)');
%     xticks(FundFreq(1):FundFreq(1):15*FundFreq(1));
%     xlim([freqs(1) 10*FundFreq(2)]);
%     legend('f_0 = 130 Hz');
%     ax = gca;
%     ax.XAxisLocation = 'origin';
%     
%     subplot(2,1,2);
%     plot(freqs, synthetic_magnitudes(idxFundFreq(2), :));
%     xlabel('Frequency in Hz');
%     ylabel('T^M(f, 200)');
%     xticks(FundFreq(2):FundFreq(2):10*FundFreq(2));
%     xlim([freqs(1) 10*FundFreq(2)]);
%     legend('f_0 = 200 Hz');
%     ax = gca;
%     ax.XAxisLocation = 'origin';
    %%
    
    for blockidx = 1:numblocks(signal, blocksize, hopsize)
        spectrum(blockidx, :) = stft(signal, blocksize, hopsize, blockidx)';
        correlation(blockidx, :) = sum(abs(spectrum(blockidx, :)) .* synthetic_magnitudes .* log_f_weight, 2)';
        
        %% Jule
%         if blockidx == 143 % plot template and spectrum for speech
%             figure; 
%             plot(freqs, abs(spectrum(blockidx,:))');
%             hold on;
%             plot(freqs, synthetic_magnitudes(FundFreq(1),:), 'r');
%             legend('Pxx', 'T^M(f, 130)');
%             xlim([0 4000]);
%             xlabel('Frequency in Hz');
%             ylabel('STFT Magnitude');
%         end
        %%
    end
end

function [num] = numblocks(signal, blocksize, hopsize)
    % The number of blocks in a signal

    num = ceil( (size(signal, 1)-blocksize) / hopsize);
end

function [spectrum] = stft(signal, blocksize, hopsize, blockidx, nfft, windowfunc)
    % Short-time Fourier Transform of a signal.
    %
    % The signal is cut into short overlapping blocks, and each block is
    % transformed into the frequency domain using the FFT. Before
    % transformation, each block is windowed by windowfunc.
    %
    % signal: A vector of doubles
    % blocksize: A scalar in samples
    % hopsize: A scalar in samples
    % blockindex: A scalar
    % nfft: [] for blocksize, or a number.
    % windowfunc: A function that returns a window.
    %
    % Returns a complex spectrum.

    if ~exist('nfft', 'var') || isempty(nfft)
        nfft = blocksize;
    end
    if ~exist('windowfunc', 'var') || isempty(windowfunc)
        windowfunc = @hann;
    end

    window = windowfunc(blocksize);
    specsize = floor(nfft/2) + 1;

    block = signal(((blockidx-1)*hopsize+1):((blockidx-1)*hopsize + blocksize));
    spectrum = fft(block.*window, nfft);
    spectrum = spectrum(1:specsize);
end

function [magnitudes] = synthetic_magnitude(samplerate, specsize, basefrequencies)
    % Synthetic magnitude spectra of a range of tone complexes.
    %
    % samplerate: The sampling rate of the tone complexes.
    % specsize: The length of each spectrum.
    % basefrequencies: An ordered vector of tone complex base
    %     frequencies in Hz.
    %
    % Returns a len(basefrequencies) x specsize matrix of tone complex spectra.

    magnitudes = zeros(length(basefrequencies), specsize);
    for freqidx = 1:length(basefrequencies)
        magnitudes(freqidx, :) = hannwin_comb(samplerate, basefrequencies(freqidx), specsize);
    end
end

function [comb_spectrum] = hannwin_comb(samplerate, basefrequency, specsize)
    % Approximate a speech-like correlation spectrum of a tone complex.
    %
    % This is an approximation of time_domain_comb that runs much
    % faster.
    %
    % Instead of calculating the FFT of a series of hann-windowed
    % sinuses, this models the spectrum of a tone-complex as a series of
    % hann-window-spectrums.
    %
    % For a perfect reconstruction, this would need to calculate the sum
    % of many hann-window-spectra. Since hann window spectra are very
    % narrow, this assumes that each window spectrum extends from
    % n*basefreq-basefreq/2 to n*basefreq+basefreq/2 and that
    % neighboring spectra do not influence each other.
    %
    % This assumtion holds as long as basefreq >> 1/specsize.
    %
    % Amplitudes are normalized by specsize.
    %
    % To make the spectrum more speech-like, frequencies above 1000 Hz
    % are attenuated by 24 dB/oct.
    %
    % To make the correlation of this spectrum and some other spectrum
    % have a normalized gain, the spectrum is shifted to be zero-mean.
    %
    % samplerate: The sampling rate in Hz of the signal.
    % basefreq: The base frequency in Hz of the tone complex.
    % specsize: The length of the resulting spectrum in bins
    %           (typically 2**N+1 for type(N) == int).
    %
    % Returns a real magnitude spectrum.

    freqs = linspace(0, samplerate/2, specsize);
    % create a local frequency vector around each harmonic, going from
    % -basefreq/2 to basefreq/2 within the area around the nth
    % harmonic n*basefreq-basefreq/2 to n*basefreq+basefreq/2:
    closest_harmonic = floor((freqs + basefrequency/2) / basefrequency);
    % ignore first half-wave:
    closest_harmonic(closest_harmonic==0) = 1;
    local_frequency = closest_harmonic*basefrequency - freqs;
    % convert from absolute frequency to angular frequency:
    local_angular_freq = local_frequency / (samplerate/2) * 2*pi;
    % evaluate hannwin_spectrum at the local frequency vector:
    comb_spectrum = abs(hannwin_spectrum(local_angular_freq, specsize));
    % normalize to zero mean:
    comb_spectrum = comb_spectrum - mean(comb_spectrum);
    % attenuate high frequencies:
    comb_spectrum(freqs>1000) = comb_spectrum(freqs>1000) ./ 10.^(log2(freqs(freqs>1000)/1000)*24/20);
end

function [spectrum] = hannwin_spectrum(angular_freq, specsize)
    % Spectrum of a hann window
    %
    % The hann window is a linear combination of modulated rectangular
    % windows r(n) = 1 for n=[0, N-1]:
    %
    % w(n) = 1/2*(1 - cos((2*pi*n)/(N-1)))
    %      = 1/2*r(n) - 1/4*exp(i*2*pi * n/(N-1))*r(n) - 1/4*exp(-i*2*pi * n/(N-1))*r(n)
    %
    % It's spectrum is then
    %
    % W(omega) = 1/2*R(omega) - 1/4*R(omega + (2*pi)/(N-1)) - 1/4*R(omega - (2*pi/(N-1)))
    %
    % with the spectrum of the rectangular window
    %
    % R(omega) = exp(-i*omega * (N-1)/2) * sin(N*omega/2) / sin(omega/2)
    %
    % (Source: https://en.wikipedia.org/wiki/Hann_function)
    %
    % angular_freq: Angular Frequency omega (0...2*pi), may be a vector.
    % specsize: Length N of the resulting spectrum
    %
    % Returns the spectral magnitude for angular_freq.

    function [spectrum] = rectwin_spectrum(angular_freq)
        % In case of angular_freq == 0, this will calculate NaN. This
        % will be corrected later.
        spectrum = ( exp(-1j*angular_freq*(specsize-1)/2) .* ...
                     sin(specsize*angular_freq/2) ./ ...
                     sin(angular_freq/2) );
        spectrum(angular_freq == 0) = specsize;
    end

    delta_f = 2*pi / (specsize-1);
    spectrum = ( 1/2 * rectwin_spectrum(angular_freq) - ...
                 1/4 * rectwin_spectrum(angular_freq + delta_f) - ...
                 1/4 * rectwin_spectrum(angular_freq - delta_f) ) / specsize;
end
