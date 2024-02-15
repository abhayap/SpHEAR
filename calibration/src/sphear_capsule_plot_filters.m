%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_capsule_plot_filters: plot the shape of capsule equalization filters
%%
%% usage:
%%   sphear_capsule_plot_filters(FC, FSHAPES)
%%
%% FC: array of center frequencies
%% FSHAPES: shape of filters
%%
%% Copyright 2018, Fernando Lopez-Lezcano, All Rights Reserved
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

function sphear_capsule_plot_filters(FC, FSHAPE)
  fig = figure;
  grid on;
  axis([300, 20000]);
  xticks = [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 20000];
  set(gca, 'XTick', xticks);
  set(gca, 'XTickLabel', sprintf('%d|', xticks));
  ca=get (gcf, "currentaxes");
  set(ca, "fontweight", "bold", "linewidth", 1.25)
  pbaspect([16, 9, 1])
  hold on;
  fidx = 24;
  for c = 1:size(FSHAPE, 1)
    if (mod(c, 2) != 0)
      %% odd capsules (pointing up) are red
      color = "r";
    else
      %% even capsules (pointing down) are blue
      color = "b";
    end
    printf("capsule %d\n", c);
    semilogx(FC, 20*log10(abs(FSHAPE(c,:))), color, "linewidth", 1.25);
    text(FC(fidx), 20*log10(abs(FSHAPE(c,fidx))), sprintf("%d", c),
	 "fontweight", "bold", "fontsize", 12, "verticalalignment", "baseline", "color", color);
    fidx = fidx + 2;
  end
  hold off;
end
