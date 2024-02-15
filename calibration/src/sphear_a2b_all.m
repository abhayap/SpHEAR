%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_a2b_all: calculate A2B matrixes for frequency ranges
%%
%% usage:
%%   [F FE Fs A2BF PVF COND TF] = sphear_a2b_all(m, fmin, fmax, cond_mult, Noct, Nfft, plot_on)
%%
%% m: vector of measurement numbers to take into account
%% fmin, fmax: lower and upper frequency limits
%% cond_mult: multiplier for transition frequency calculation (default should be 1/2)
%% Noct: width of frequency ranges in fractions of an octave, this
%%       will be changed slightly so that the frequency range is
%%       covered by equally spaced frequency bands
%% Nfft: fft size for calculating power
%%
%% optional parameters:
%%
%% plot_on: plot polar response for each frequency band (default is 0)
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

function [F FE Fs A2BF PVF COND TF] = sphear_a2b_all(m, fmin, fmax, cond_mult, Noct, Nfft, plot_on)

  %% do not plot by default
  if (!exist("plot_on"))
    plot_on = 0;
  end

  A2BF = zeros(1, 4, 4);

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

  for i = (1:size(fc))
    [R srate] = sphear_af_power(m, fe(i), fe(i + 1), Nfft);
    [A2B pv max_err] = A2B_matrix(R);
    A2BF(i,:,:) = A2B;
    PVF(i,:,:) = pv;
    BF = R * A2B;
    COND(i) = cond(A2B);

    printf("%2d: %5d -> [%5d %5d] A2B cond=%f\n", i, fc(i), fe(i), fe(i + 1), COND(i));

    if plot_on
      sphear_bf_plot(BF, fe(i), fe(i + 1), 1.1);
    end
  end

  %% calculate the transition frequency of the array
  [value, index] = max(COND);
  TF = fc(index) * cond_mult;
  printf("max condition %fHz, cf %f, fe %f, transition %f\n", value, fc(index), fe(index), fc(index)/2);

  F = fc;
  FE = fe;
  Fs = srate;
end

