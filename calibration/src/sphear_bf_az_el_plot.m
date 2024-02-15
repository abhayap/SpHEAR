%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_plot: plot the polar response of a B format signal
%%
%% usage:
%%   [BF] = sphear_bf_plot(BF, AZ, EL, fmin, fmax)
%%
%% BF: B format signal array
%% M: projection matrix in measurement directions
%% AZ: azimuth angles
%% EL: elevation angles
%% fmin, fmax: range of frequencies to consider (to title plot)
%% cardioid: whether we have Z or a cardioid in its place
%% subplots: whether we want individual plots or subplots
%%
%% Copyright Fernando Lopez-Lezcano 2016-2018
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

function [BF] = sphear_bf_az_el_plot(BF, M, AZ, EL, fmin, fmax, rmax, cardioid = 0, subplots = 1)
  %% sort azimuth angles
  [AZS, I] = sort(AZ);
  ELS = EL(I);
  BFS(:,:) = BF(I,:);
  MS(:,:) = M(I,:);
  %% to close the polar plots we repeat the first point
  m = size(BF, 1);
  BFS(m + 1,:) = BFS(1,:);
  MS(m + 1,:) = MS(1,:);
  AZS(m + 1) = AZS(1);
  ELS(m + 1) = ELS(1);
  %% angles for plotting polar grid
  n = 32;
  theta = (0:m)*(2*pi/m);
  thetaf = (0:n)*(2*pi/n);
  %% plot it as a function of angle
  if (cardioid)
    bname = cellstr(['W'; 'X'; 'Y'; 'Cardioid'; 'U'; 'V']);
  else
    if (size(BF, 2) > 6)
      bname = cellstr(['W'; 'X'; 'Y'; 'Z'; 'S'; 'T'; 'U'; 'V']);
    else
      bname = cellstr(['W'; 'X'; 'Y'; 'Z'; 'U'; 'V']);
    end
  end
  %% go and plot
  f = figure;
  for b = 1:size(BF, 2)
    if (subplots == 0)
      f = figure;
      font_size = 28;
      line_w = 1.0;
      line_W = 3;
      dot_size = 15;
      title([char(bname(b))]);
    else
      if (size(BF,2) > 4)
	subplot(2, 4, b);
      else
	subplot(2, 2, b);
      end
      font_size = 18;
      line_w = 0.5;
      line_W = 1.5;
      dot_size = 10;
      title([char(bname(b)) sprintf(" (%.2f - %.2f Hz)", fmin, fmax)]);
    end
    hold on;
    grid off;
    axis("off", "equal", "nolabel");
    ca=get (gcf, "currentaxes");
    set(ca,"fontweight", "bold", "fontsize", font_size)
    grey = [0.1, 0.1, 0.1];
    %% radius circles
    for rad = 0.25:0.25:rmax
      [xr, yr] = pol2cart(thetaf', ones(n + 1,1) * rad);
      plot(xr, yr, '--', 'color', grey, 'linewidth', line_w);
    end
    %% radial lines
    for ang = theta
      plot([0 rmax*cos(ang)], [0 rmax*sin(ang)], '--', 'color', grey, 'linewidth', line_w);
    end
    [xr, yr] = pol2cart(thetaf', ones(n + 1,1));
    plot(xr, yr, "b-", "linewidth", line_w);
    %% plot real harmonic normalized to max measured harmonic
    if (b > 0)
      if (b == 1)
	%% M does not have W
	db_e = 1.0;
      else
	%% real harmonic scaled by maximum of measured harmonic
	for m = 1:size(MS,1)
	  if (max(abs(MS(:,b-1))) > 0)
	    scaled = 0;
	    if (scaled == 1)
	      db_e(m,:) = abs(MS(m,b-1)) * (max(abs(BFS(:,b))) / max(abs(MS(:,b-1))));
	    else
	      db_e(m,:) = abs(MS(m,b-1));
	    end
	  else
	    db_e(m,:) = 0.0;
	  end
	end
      end
      db_e_max = max(abs(db_e));
      [xm, ym] = pol2cart(AZS, abs(db_e));
      plot(-ym, xm, "k.--", 'linewidth', line_W, 'markersize', dot_size);
    end
    %% plot measured harmonic
    [x, y] = pol2cart(AZS, abs(BFS(:,b)));
    plot(-y, x, "r.-", 'linewidth', line_W, 'markersize', dot_size);
  end
end

