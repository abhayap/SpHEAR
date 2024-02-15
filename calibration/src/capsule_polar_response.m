%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% capsule_polar_response: plot polar response of capsule in a frequency band
%%
%% usage:
%%   [] = capsule_polar_respones(measurements, fmin, fmax, N, Npre)
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

function [CAP] = capsule_polar_response(measurements, fmin, fmax, N, Npre)
  pkg load signal;

  %% read in reference microphone, select samples to process
  [ref, Fs] = wavread('../data/2016.08.03/export/reference-001-1.wav');
  [peaks, locs] = findpeaks(abs(ref));
  [~, index] = max(peaks);
  start = locs(index) - Npre;
  range = start:(start + N - 1);
  ref_fft = fft(ref(range), N);
  
  %% indexes in array for frequency bins
  imin = round((N/2) * fmin / (Fs/2));
  imax = round((N/2) * fmax / (Fs/2));

  capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);

  %% all submitted measurements
  i = 1;
  for m = measurements
    %% read in capsule measurement and equalize to reference microphone
    %% this is only valid for the frequency range covered by the test speaker,
    %% anything outside is undefined
    %%
    capsule = wavread(["../data/2016.08.03/export/capsule-0" sprintf("%02.0f", m) "-2.wav"]);
    equalized = fft(capsule(range), N) ./ ref_fft;
    
    %% return total power of signal in frequency range
    CAP(i,:) = sqrt(sum(equalized(imin:imax).*conj(equalized(imin:imax)))/(imax - imin));
    i = i + 1;
  end

end

