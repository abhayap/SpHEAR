%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_signal_arrival_times: measure rotation axis wobble in the measurements
%%
%% usage:
%%   [] = sphear_signal_arrival_times(SIG);
%%
%% SIG: array of signals (measurements, capsules, samples)
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
%%  along with this program.  If not, see <htp://www.gnu.org/licenses/>.

function [SIGC] = sphear_af_fix_wobble(SIG, delta)
  for m = 1:size(SIG, 1);
    for c = 1:size(SIG, 2);
      SIGC(m, c, :) = fracshift(reshape(SIG(m, c, :), 1, []), delta(m));
    end
  end
end

