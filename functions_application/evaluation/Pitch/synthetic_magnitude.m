function [magnitudes] = synthetic_magnitude(samplerate, specsize, basefrequencies, useFilter)
    % Synthetic magnitude spectra of a range of tone complexes.
    %
    % samplerate: The sampling rate of the tone complexes.
    % specsize: The length of each spectrum.
    % basefrequencies: An ordered vector of tone complex base
    %     frequencies in Hz.
    % useFilter: logical whether to filter the hannwin_comb
    %
    % Returns a len(basefrequencies) x specsize matrix of tone complex spectra.
    
    if nargin == 3
        useFilter = 1;
    end

    magnitudes = zeros(length(basefrequencies), specsize);
    for freqidx = 1:length(basefrequencies)
        magnitudes(freqidx, :) = hannwin_comb(samplerate, basefrequencies(freqidx), specsize, useFilter);
    end
end

function [comb_spectrum] = hannwin_comb(samplerate, basefrequency, specsize, useFilter)
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
    if useFilter
        f_cut = 1500; % cut off frequency
    else
        f_cut = 1000; % cut off frequency
    end
    comb_spectrum(freqs>f_cut) = comb_spectrum(freqs>f_cut) ./ 10.^(log2(freqs(freqs>f_cut)/f_cut)*24/20);
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