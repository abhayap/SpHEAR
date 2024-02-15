%%
%% *SpHEAR Project
%%
%% sphear_wxyz_plot: plot the polar response of a B format signal in a frequency range
%%
%% usage:
%%   sphear_bf_plot(BF, fmin, fmax)
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

function sphear_wxyz_plot(BF, fmin, fmax, rmax)

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
  
  %% plot it as a function of angle
  bname = cellstr(['W'; 'X'; 'Y'; 'Z']);

  f = figure;
  for b = 1:4
    subplot(2, 2, b);
    hold on;
    grid off;
    axis square;
    axis([-rmax, rmax, -rmax, rmax]);
    ca=get (gcf, "currentaxes");
    set(ca,"fontweight","bold","linewidth",1.5)
    title([char(bname(b)) ": " sprintf("%05.0d", fmin) " to " sprintf("%05.0d", fmax) " Hz"]);

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
    [x, y] = pol2cart(theta', abs(BF(:,b)));
    plot(x, y, dopts, 'linewidth', 1.5, 'markersize', 6);
    
  end
  print(f, '-deps','-tight',copt,["figures/sphear_polar_multi_" sprintf("%05d", fmin) "_" sprintf("%05d", fmax) cext ".eps"]);
end

