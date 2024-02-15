%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_af_power: return array of power for all capsules in a range of frequencies
%%
%% usage:
%%   [R Fs] = sphear_af_power(fmin, fmax, Nfft)
%%
%% fmin, fmax: range of frequencies to consider
%% Nfft: fft size
%%
%% The names of reference microphone impulse response and capsule measurements are
%% currently hardwired into this file, this needs to be fixed and turned into
%% input parameters
%%
%% Copyright Fernando Lopez-Lezcano 2016
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

function [R Fs] = sphear_af_power(measurements, fmin, fmax, Nfft)
  pkg load signal;

  %% read in reference microphone
  [ref, Fs] = wavread('../data/current/ref/reference-001-1.wav');
  ref_fft = fft(ref, Nfft);
  
  %% indexes in array for frequency bins
  imin = round((Nfft/2) * fmin / (Fs/2));
  imax = round((Nfft/2) * fmax / (Fs/2));

  capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);

  %% all submitted measurements
  i = 1;
  for m = measurements
    %% all capsules
    for c = 1:4

      %% read in capsule measurement and equalize to reference microphone
      %% this is only valid for the frequency range covered by the test speaker,
      %% anything outside is undefined
      %%
      capsule = wavread(["../data/current/af/a-format-cal-" sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
      equalized = fft(capsule, Nfft);
      
      %% return total power of signal in frequency range
      R(i, c) = sqrt(sum(equalized(imin:imax).*conj(equalized(imin:imax)))/(imax - imin));

    end
    i = i + 1;
  end
  
end

