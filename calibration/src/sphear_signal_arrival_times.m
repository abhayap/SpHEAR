%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_signal_arrival_times: measure rotation axis wobble in the measurements
%%
%% usage:
%%   [DELAYS] = sphear_signal_arrival_times(SIG);
%%
%% SIG: array of signals (measurements, capsules, samples)
%% DELAYS: array of delays
%%
%% use this function for finding peaks:
%% https://ccrma.stanford.edu/~jos/sasp/Matlab_listing_findpeaks_m.html
%%
%%
%% Copyright 2016-2018, Fernando Lopez-Lezcano, All Rights Reserved
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
%%  along with this program.  If not, see <htp://www.gnu.org/licenses/>.

function [AVG_DELAY DELTA ALL] = sphear_signal_arrival_times(SIG)
  %% make all delays relative to first capsule of first measurement
  [peakamps, peaklocs] = sphear_findpeaks(abs(reshape(SIG(1, 1, :), 1, [])), 10);
  ref = peaklocs(1);
  %% now find all average delays
  for m = 1:size(SIG, 1);
    avg_delay = 0;
    for c = 1:size(SIG, 2);
      %% find at most 10 peaks so that we avoid warnings
      [peakamps, peaklocs] = sphear_findpeaks(abs(reshape(SIG(m, c, :), 1, [])), 10);
      delay = peaklocs(1) - ref;
      %% printf("m=%d, c=%d: idx=%d <delay=%d value=%f>\n", m, c, 1, delay, peakamps(1));
      ALL(m,c,:) = delay;
      avg_delay = avg_delay + delay;
    end
    if (m == 1)
      first = avg_delay/size(SIG, 2);
    end
    AVG_DELAY(m) = avg_delay/size(SIG, 2);
    DELTA(m) = AVG_DELAY(m) - first;
    printf("m=%d: time=%f, delta=%f\n", m, AVG_DELAY(m), DELTA(m));
  end
  %% find proper deltas with respect to minimum delay
  min_delay = min(AVG_DELAY);
  max_delay = max(AVG_DELAY);
  DELTA = (AVG_DELAY - min_delay)';
  AVG_DELAY = (max_delay - AVG_DELAY)';
end

