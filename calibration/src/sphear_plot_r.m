%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_plot_r: plot A format measurement power in a range of frequencies
%%
%% usage:
%%   [] = sphear_plot_r(R, shift)
%%
%% R: array of measurements for all four capsules
%% shift: overall angle offset adjustment for plotting
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
%%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [] = sphear_plot_r(R, shift);
  figure();
  hold on;
  grid on;
  RS = circshift(R, shift);
  %% number of measurements
  m = size(RS)(1);
  x = (0:size(RS)(1)-1) / size(RS)(1) * 360;
  xlim([0, 360]);
  tics('x', [0, 45, 90, 135, 180, 225, 270, 315, 360]);
  ca = get (gcf, "currentaxes");
  set(ca,"fontweight","bold","linewidth",1.5);
  color = ['r', 'b', 'g', 'm', 'r', 'b', 'g', 'm'];
  style = ['-', '-', '-', '-', '-', '-', '-', '-'];
  marker = ['s', 's', 's', 's', 'o', 'o', 'o', 'o'];
  for c = (1:size(R,2))
    p(c) = plot(x, RS(:,c), 'color', color(c), 'marker', marker(c), 'linewidth', 1.5, 'linestyle', style(c));
  end
  l = legend(p, {"capsule 1", "capsule 2", "capsule 3", "capsule 4", ...
		"capsule 5", "capsule 6", "capsule 7", "capsule 8"});
  legend(l, 'location', 'bestoutside');
  hold off;
end
