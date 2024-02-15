%%
%% *SpHEAR Project
%%
%% sphear_cardioid_plot: plot a virtual cardioid polar response
%%
%% usage:
%%   [BF] = sphear_cardioid_plot(BF, fmin, fmax)
%%
%% BF: B format signal array
%% fmin, fmax: range of frequencies to consider (to title plot)
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

function [BF] = sphear_cardioid_plot(b, BF, fmin, fmax, rmax)

  if (!exist("plot_on"))
    plot_on = "epsc";
  else
    if (plot_on == 1)
      plot_on = "epsc"
    end
  end

  %% to close the polar plots we repeat the first point
  m = size(BF, 1);
  n = 32;
  BF(m + 1,:) = BF(1,:);
  theta = (0:m)*(2*pi/m);
  thetaf = (0:n)*(2*pi/n);
  
  subplot(2, 3, b);
  hold on;
  grid off;
  axis square;
  axis([-rmax, rmax, -rmax, rmax]);

  % sub_pos = get(gca,'position'); % get subplot axis position
  % set(gca,'position',sub_pos.*[1 1 1.2 1.2]) % stretch its width and height

  ca=get (gcf, "currentaxes");
  set(ca,"fontweight","bold","linewidth",1.5)
  title([sprintf("%05.0d", fmin) " to " sprintf("%05.0d", fmax) " Hz"]);

  if (strcmp(plot_on, "epsc") || strcmp(plot_on, "pngc"))
    %% color plot
    dopts = '.-r';
    ropts = '-b';
    copt = '-color';
    cext = "_color";
  else
    %% mono plot
    dopts = '.-';
    ropts = '-';
    copt = '-mono';
    cext = "_mono";
  end

  grey = [0.1, 0.1, 0.1];
  %% radius circles
  for rad = 0.25:0.25:rmax
    [xr, yr] = pol2cart(thetaf', ones(n + 1,1) * rad);
    plot(xr, yr, ':', 'Color', grey);
  end
  %% radial lines
  for ang = theta
    plot([0 rmax*cos(ang)], [0 rmax*sin(ang)], ':', 'Color', grey);
  end

  [xr, yr] = pol2cart(thetaf', ones(n + 1,1));
  plot(xr, yr, ropts);
  [x, y] = pol2cart(theta', abs(BF(:,4)));
  plot(x, y, dopts, 'linewidth', 1.5, 'markersize', 6);
    
end

