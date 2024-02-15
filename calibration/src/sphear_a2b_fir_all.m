%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_a2b_all: calculate A2B matrixes for frequency ranges
%%
%% usage:
%%   [F FE A2BF] = sphear_a2b_all(m, fmin, fmax, Noct, Nfft, Fs, plt)
%%
%% m: vector of measurement numbers to take into account
%% fmin, fmax: lower and upper frequency limits
%% Noct: width of frequency ranges in fractions of an octave, this
%%       will be changed slightly so that the frequency range is
%%       covered by equally spaced frequency bands
%% Nfft: fft size
%% Fs: sampling rate
%% plt: plot
%%
%% Copyright 2016, Fernando Lopez-Lezcano, All Rights Reserved
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

function [B] = sphear_a2b_fir_all(fmin, fmax, Noct, Nfft, Fs, plt)

  plotz = 1;
  
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

  %% normalize amplitude with respect to W between 600 and 1200 Hz
  ref = sphear_bf_power(600, 1200, Nfft, Fs, 1);
  norm = mean(ref(:,1));

  for i = (1:size(fc))
    B(:,:,i) = sphear_bf_power(fe(i), fe(i + 1), Nfft, Fs, plotz) / norm;
    if (plt == 1)
      sphear_bf_plot(B(:,:,i), fe(i), fe(i + 1), 1.25);
    end
  end

end

