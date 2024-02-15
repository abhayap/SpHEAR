%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_plot_polar_response: plot polar response of B format components
%%
%% usage:
%%   sphear_bf_plot_polar_response(B, frefmin, frefmax, fmin, fmax, Noct, Nfft, Fs, band, cardioid = 0, azim = 45)
%%
%% B: B format signal
%% frefmin, frefmax: reference frequencies for power reference
%% fmin, fmax: lower and upper frequency limits for frequency bands
%% Noct: width of frequency ranges in fractions of an octave, this
%%       will be changed slightly so that the frequency range is
%%       covered by equally spaced frequency bands
%% Nfft: FFT size
%% Fs: sampling rate
%% band: single or array of frequencies, they will be matched to the bands
%%
%% optional:
%%
%% cardioid: replace Z with a synthetic cardioid
%% azimuth: azimuth angle for the synthetic cardioid
%%
%% Copyright 2016-2018, Fernando Lopez-Lezcano, All Rights Reserved
%% nando@ccrma.stanford.edu
%%
%%  This program is free software: you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation, either version 3 of the License, or
%%  (at your option) any later version.
%%
%%  This program is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

function sphear_bf_plot_polar_response(B, frefmin, frefmax, fmin, fmax, Noct, Nfft, Fs, band, cardioid = 0, azim = 45)
  %% calculate number of frequency bands spaced Noct
  n = floor(log(fmax/fmin)/log(2^(1/Noct)));
  %% adjust width of band so they fit exactly in frequency range
  N = log(2)/(log(fmax/fmin)/n);
  printf("%d frequency bands, %f bands per octave\n", n, N);

  %% first center frequency
  fcmin = fmin * 2^(1/(N * 2));
  %% all center and edge frequencies
  fc = fcmin * 2.^((0:n - 1)/N)';
  fe = fmin * 2.^((0:n)/N)';

  %% normalize amplitude with respect to W between reference limits
  ref = sphear_signal_power(B, Fs, frefmin, frefmax, Nfft);
  norm = mean(ref(:,1));

  %% plot all bands if we receive an empty array
  if (numel(band) == 0)
    band = fc;
  end

  idx = 1;
  for ib = 1:numel(band)
    printf("processing band around %d\n", band(ib));
    for i = (1:size(fc))
      if ((fe(i) <= band(ib)) && ((fe(i+1) >= band(ib))))
	printf("fc = %d (between %d and %d)\n", fc(i), fe(i), fe(i+1));
	BP = sphear_signal_power(B, Fs, fe(i), fe(i + 1), Nfft, cardioid, azim) / norm;
	sphear_bf_plot(BP, fe(i), fe(i + 1), 1.25, cardioid);
      end
      idx = idx + 1;
    end
  end
end

