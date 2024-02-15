%%
%% *SpHEAR Project
%%
%% capsule_polar_response_all: calculate polar response of capsule for frequency ranges
%%
%% usage:
%%   [] = capsule_polar_response_all(m, fmin, fmax, Noct, Fs, Nsamp, Npre, plt)
%%
%% m: vector of measurement numbers to take into account
%% fmin, fmax: lower and upper frequency limits
%% Noct: width of frequency ranges in fractions of an octave, this
%%       will be changed slightly so that the frequency range is
%%       covered by equally spaced frequency bands
%% Fs: sampling rate
%% Nsamp: time domain samples to use
%% Npre: samples to use before the main peak of impulse response
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

function [] = capsule_polar_response_all(m, fmin, fmax, Noct, Fs, Nsamp, Npre, plt)

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

  colors = 'brgkmc';
  f = figure;
  title(["EM182 capsule polar pattern"]);

  for i = (1:size(fc))
    R = capsule_polar_response(m, fe(i), fe(i + 1), Nsamp, Npre, 1.5);
    if plt
      capsule_plot(1, R, fe(i), fe(i + 1), 1.8, colors(mod(i - 1, size(colors)(2)) + 1));
    end
  end
  legend('location', 'west');
  print(f, '-depsc', 'figures/capsule_polar_response.eps');
end

