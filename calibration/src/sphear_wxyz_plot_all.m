%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_wxyz_plot_all: plot the polar response of a B format signal
%%
%% usage:
%%   [B] = sphear_wxyz_plot_all(fmin, fmax, Noct, Nbuf, Npre, Nfft, plt)
%%
%% fmin, fmax: lower and upper frequency limits
%% Noct: width of frequency ranges in fractions of an octave, this
%%       will be changed slightly so that the frequency range is
%%       covered by equally spaced frequency bands
%% Nbuf: total number of samples to analyze
%% Npre: number of samples before the main impulse
%% Nfft: size of fft
%% plt: 0 -> just return the measurements, 1 -> do plots
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

function [B] = sphear_wxyz_plot_all(fmin, fmax, Noct, Nbuf, Npre, Nfft, plt)

  plotz = 0;
  measurements = (1:16);
  
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
  ref = sphear_wxyz_power(measurements, 600, 1200, Nbuf, Npre, Nfft, 1);
  norm = mean(ref(:,1));

  for i = (1:size(fc))
    B(:,:,i) = sphear_wxyz_power(measurements, fe(i), fe(i + 1), Nbuf, Npre, Nfft, plotz) / norm;
    if (plt == 1)
      sphear_wxyz_plot(B(:,:,i), fe(i), fe(i + 1), 3.0);
    end
  end

end

