%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_common: library of shared functions
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

%% make sure octave treats this as a script file
1;

pkg load signal;

%% Render a calibrated capsule impulse response through the FIR filter A2B matrix
%%
%% m: number of measurement to render
%% FIR: matrix of A2B FIR filters
%% Nfft: size of FFT to use

function [bf] = sphear_a_to_b(m, FIR, Nfft);
  capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);
  %% read in calibrated capsule signals and apply FIR filter
  for c = 1:4
    cs(c,:) = wavread(["../data/current/af/a-format-cal-" sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
    for b = 1:4
      %% we add trailing zeros to let the filter ring
      bs(c,b,:) = fftfilt(reshape(FIR(b,c,:), 1, [])', cat(1, cs(c,:)', zeros(2*size(FIR(1,1,:))(3),1))', Nfft);
    end
  end
  %% add filtered capsule output to b format components
  for b = 1:4
    bf(b,:) = bs(1,b,:) + bs(2,b,:) + bs(3,b,:) + bs(4,b,:);
  end
end

%% Find maximum and location of maximum in a signal
%%
%% signal: vector with time domain signal

function [i, v] = findmaxpeak(signal);
  [peaks, locs] = findpeaks(signal, "DoubleSided", "MinPeakDistance", 8);
  [~, index] = max(peaks);
  i = locs(index);
  v = peaks(index);
end

function [i, v] = findfirstpeak(signal);
  [peaks, locs] = findpeaks(signal, "DoubleSided", "MinPeakHeight", 0.01, "MinPeakDistance", 8);
  [~, index] = max(peaks);
  i = locs(1);
  v = peaks(1);
end
