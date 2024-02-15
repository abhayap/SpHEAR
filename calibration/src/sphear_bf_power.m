%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_a_power: return array of power for all capsules in a range of frequencies
%%
%% usage:
%%   [R] = sphear_a_power(fmin, fmax, N, Npre)
%%
%% fmin, fmax: range of frequencies to consider
%% Npre: number of samples before the main impulse
%% N: total number of samples to analyze
%%
%% The names of reference microphone impulse response and capsule measurements are
%% currently hardwired into this file, this needs to be fixed and turned into
%% input parameters
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

function [B] = sphear_bf_power(fmin, fmax, N, Fs, plotz)

  %% indexes in array for frequency bins
  imin = round((N/2) * fmin / (Fs/2));
  imax = round((N/2) * fmax / (Fs/2));

  %% all measurements
  for m = 1:16
    %% all b format components, 4 channel soundfile
    bsignal = wavread(["../data/current/bf/b-format-" sprintf("%02.0f", m) ".wav"]);
    bfft = fft(bsignal, N);
    if (plotz == 0)
      %% calculate a forward facing cardiod
      cfft = fft(bsignal(:,1) + 1.0 * bsignal(:,2), N);
    end
    %% return total power of signal in frequency range
    B(m, :) = sqrt(sum(bfft(imin:imax,:).*conj(bfft(imin:imax,:)))/(imax - imin));
    %% make a cardiod if we don't want Z
    if (plotz == 0)
      B(m, 4) = sqrt(sum(cfft(imin:imax).*conj(cfft(imin:imax)))/(imax - imin)) / 2.0;
    end
  end
  
end

