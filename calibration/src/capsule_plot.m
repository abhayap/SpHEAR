%%
%% *SpHEAR Project
%%
%% capsule_plot: plot the polar response of a capsule
%%
%% usage:
%%   capsule_plot(R, fmin, fmax, col)
%%
%% R: capsule response in frequency range
%% fmin, fmax: frequency range (plot title)
%% col: plot line color
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

function capsule_plot(i, R, fmin, fmax, rmax, col)

  m = size(R, 1);
  n = 32;
  theta = (0:m-1)*(pi/(m-1));
  thetaf = (0:n)*(pi/n);
  
  hold on;
  axis([-rmax, rmax, 0, rmax], "equal", "tickx");
  
  title(["EM182 polar pattern"]);

  if (i == 1)
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
  end
  
  [x, y] = pol2cart(theta', abs(R(:)));
  p = plot(x, y, [".-;" sprintf("%d to %d Hz", fmin, fmax) ";"], 'LineWidth', 0.5);
  set(p, 'color', col); 

end

