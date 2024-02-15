%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_capsule_plot_frequency_response: plot frequency response of capsule signals
%%
%% usage:
%%   [] = sphear_capsule_plot_frequency_response(SIG, fmin, fmax, ymin, ymax, FS, fft_size, plot_on, smooth)
%%
%% SIG: signals for each measurement
%% fmin, fmax: range of frequencies to use
%% ymin, ymax: y range to plot
%% FS: sampling rate
%% fft_size: size of fft used to calculate frequency response
%%
%% optional parameters:
%%
%% plot_on: plot frequency response of components, default is "epsc"
%%          can be one of 0, "eps", "epsc" (color), "png", "pngc" (color)
%% smooth: number of samples to average, default is 0
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

function [] = sphear_capsule_plot_frequency_response(SIG, measurements, fmin, fmax, ymin, ymax, FS, fft_size, smooth)

  %% no smoothing by default
  if (!exist("smooth"))
    smooth = 0;
  end
  for c = 1:size(SIG,2)
    %% calculate frequency responses
    for m = measurements
      if (smooth > 0)
	sfft(m,c,:) = fastsmooth(20*log10(abs(fft(SIG(m,c,:), fft_size))), smooth, 2, 1);
      else
	sfft(m,c,:) = 20*log10(abs(fft(SIG(m,c,:), fft_size)));

	%% print peaks...
%%	[amps, locs] = sphear_findpeaks(reshape(sfft(m,c,:), [], 1), 12);
%%	for l = 1:numel(locs)
%%	  if ((locs(l) > 3000) && (locs(l) < 6000) && (amps(l) > -25))
%%	    printf("c:%d m:%d  a=%f, l=%f\n", c, m, amps(l), locs(l));
%%	  end
%%	end

      end
    end
    %% color plot
    copts = ['k', 'r', 'b', 'g', ':g', ':b', ':r', ':k'];
    cext = "_color";
    f = figure;
    hold on;
    title(sprintf("capsule %d", c), "fontweight", "bold", "fontsize", 16);
    fr = (1:fft_size/2) * FS/fft_size;
    grid on;
    axis([fmin, fmax, ymin, ymax]);
    tics('y', [6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30, -40, -50]);
    tics('x', [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
    ca=get (gcf, "currentaxes");
    set(ca,"fontweight","bold","linewidth",1.25)
    pbaspect([16, 9, 1])
    mi = 1;
    for m = measurements
      angle = 360 / 16 * (mi - 1);
      if (mi == 1)
	col = "k";
      else
	if (mi < 8)
	  col = "r";
	else
	  if (mi == 9)
	    col = "g";
	  else
	    col = "b";
	  end
	end
      end
      fidx=500 * (1.075^m);
      idx=round(fft_size/fmax*fidx/2);
      semilogx(fr, sfft(m,c,1:end/2), col, "linewidth", 1.25);
      text(fidx, sfft(mi,c,idx) / 1.02, sprintf("%d:%d", m, angle),
	   "fontweight", "bold", "fontsize", 12, "verticalalignment", "baseline", "color", col);
%%      text(fidx, sfft(mi,c,idx), sprintf("%d:%d @ %.2f", mi, angle, sfft(mi,c,idx)),
%%	   "fontweight", "bold", "fontsize", 12, "verticalalignment", "baseline", "color", col);
      mi = mi + 1;
    end
    hold off;
  end
end

