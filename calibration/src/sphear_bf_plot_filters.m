%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_plot_filters: plot the shape of WXYZ FIR filters
%%
%% usage:
%%   sphear_bf_plot_filters(FC, W, X, Y, Z)
%%
%% FC: array of center frequencies
%% W, Z, Y: vectors with gains
%% Z: vector with Z gains (optional)
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

function sphear_bf_plot_filters(FC, W, X, Y, Z, S, T, U, V)
  fig = figure;
  %% color plot
  grid on;
  axis([300, 20000]);
  xticks = [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 20000];
  set(gca, 'XTick', xticks);
  set(gca, 'XTickLabel', sprintf('%d|', xticks));
  ca=get (gcf, "currentaxes");
  set(ca,"fontweight","bold","linewidth",1.0)
  pbaspect([16, 9, 1])
  hold on;
  %% default: WXY, first order horizontal
  %% W
  wh = semilogx(FC, 20*log10(abs(W)), 'k-', "linewidth", 1.25);
  %% XY
  xh = semilogx(FC, 20*log10(abs(X)), 'r-', "linewidth", 1.25);
  yh = semilogx(FC, 20*log10(abs(Y)), 'b-', "linewidth", 1.25);
  l = legend([wh, xh, yh], {'W', 'X', 'Y'});
  %% second case: WXYUV (second order horizontal)
  if (numel(U) > 0)
    uh = semilogx(FC, 20*log10(abs(U)), 'r--', "linewidth", 1.25);
    vh = semilogx(FC, 20*log10(abs(V)), 'b--', "linewidth", 1.25);
    l = legend([wh, xh, yh, uh, vh], {'W', 'X', 'Y', 'U', 'V'});
  end
  if (numel(Z) > 0)
    %% third case: WXYZSTUV (second order full sphere)
    %% Z
    zh = semilogx(FC, 20*log10(abs(Z)), 'g-', "linewidth", 1.25);
    sh = semilogx(FC, 20*log10(abs(S)), 'r:', "linewidth", 1.25);
    th = semilogx(FC, 20*log10(abs(T)), 'b:', "linewidth", 1.25);
    l = legend([wh, xh, yh, zh, sh, th, uh, vh], {'W', 'X', 'Y', 'Z', 'S', 'T', 'U', 'V'});
  end
  legend(l, 'location', 'west');
end
