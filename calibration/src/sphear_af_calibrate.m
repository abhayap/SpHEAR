%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_af_calibrate: read reference microphone signal, filter with convolution
%%                      kernel created by DRC and filter all recorded signals,
%%                      calibrated A format files are written to disk
%%
%% usage:
%%   [] = sphear_af_calibrate(measurements, keep, fade)
%%
%% keep: time to keep after main impulse in seconds
%% fade: fade out time after keep in seconds
%%
%% Copyright 2016-2017, Fernando Lopez-Lezcano, All Rights Reserved
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

function [] = sphear_af_calibrate(measurements, keep, fade, suffix);
  if (! exist("suffix"))
    suffix = "";
  end
  %% the measurement from the reference microphone is processed through
  %% DRC (Digital Room Correction) to create a convolution kernel that is
  %% used to equalize the measurements
  %%
  %% read the convolution kernel
  [ref, Fs] = wavread('../data/current/cal/drc-filter.wav');

  capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);
  loc_min = intmax;
  loc_max = 0;
  %% all requested measurements
  for m = measurements
    printf("processing measurement %d\n", m);
    %% read in capsule signal and normalize it
    for c = 1:4
      sig = wavread(["../data/current/af/a-format-" sprintf("%s%03d", suffix, m) "-" char(capnames(c)) ".wav"]);
      cal_sig(m,c,:) = conv(ref, sig);
      %% find first non-zero sample of convolved signal
      head = find(cal_sig(m,c,:)!=0, 1, 'first');
      if (head < loc_min)
	loc_min = head;
      end
      if (head > loc_max)
	loc_max = head;
      end
    end
  end
  %% now write all the calibrated impulse responses
  %% choose a arbitrary multiple of input size... sigh
  out_size = 4 * size(sig, 1);
  range = loc_min - 1:loc_min - 1 + out_size;
  %% 5% end window
  wend = tukeywin(2 * out_size, 0.9)(end/2:end)';
  printf("start sample: min = %f, max = %f, output size = %f\n", loc_min, loc_max, out_size);
  for m = measurements
    for c = 1:4
      wavwrite((cal_sig(m,c,:)(range)) .* wend, Fs, ["../data/current/af/a-format-cal-" sprintf("%s%03d", suffix, m) "-" char(capnames(c)) ".wav"]);
    end
  end
end
