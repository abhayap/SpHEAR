%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_power_fons: return array of power for all capsules in a range of frequencies
%%
%% usage:
%%   [R] = sphear_a_power_fons(fmin, fmax, N, Fs, plotz)
%%
%% fmin, fmax: range of frequencies to consider
%% N: fft size
%% Fs: sampling rate
%% plotz: 0 -> calculate cardioid, 1 -> calculate Z
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

function [B] = sphear_bf_power_fons(fmin, fmax, N, Fs, plotz)
  pkg load signal;

  %% indexes in array for frequency bins
  imin = round((N/2) * fmin / (Fs/2));
  imax = round((N/2) * fmax / (Fs/2));

  r_start = 0;
  r_end = 0;
  
  %% all measurements
  for m = 1:16
    %% all b format components, 4 channel soundfile
    bsignal = wavread(["../data/2016.04.20/export/b-format-fons-rendered-" sprintf("%03.0f", m) "-16.wav"]);

    %% transform from FUMA to SN3D (the encoder is outputing FUMA)
    %% bsignal(:,1) = bsignal(:,1) * (sqrt(2)/2);

    %% find first peak, read samples around it
    Npre = 64;
    Nbuf = 256;

    [index, value] = findmaxpeak(bsignal(:,1));
    r_start = index - Npre;
    r_end = r_start + Nbuf -1;
    range = r_start:r_end;
    printf("%d: samples = %d -> %d (%d), imin:imax %d:%d\n", m, r_start, r_end, r_end-r_start, imin, imax);

    bfft = fft(bsignal(range,:), N);
    if (plotz == 0)
      %% calculate a forward facing cardiod
      cfft = fft(bsignal(range,1) + 1.0 * bsignal(range,2), N);
    end
    %% return total power of signal in frequency range
    scaler = 8;
    B(m, :) = sqrt(sum(bfft(imin:imax,:).*conj(bfft(imin:imax,:)))/(imax - imin)) / scaler;
    %% make a cardiod if we don't want Z
    if (plotz == 0)
      B(m, 4) = sqrt(sum(cfft(imin:imax).*conj(cfft(imin:imax)))/(imax - imin)) / (2 * scaler);
    end
  end
  
end

