%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_signal_plot_frequency_response: plot frequency response of a signal
%%
%% usage:
%%   [] = sphear_signal_plot_frequency_response(SIG, fmin, fmax, ymin, ymax, FS, fft_size, title, filename, smooth)
%%
%% SIG: signals for each measurement
%% fmin, fmax: range of frequencies to use
%% ymin, ymax: y range to plot
%% FS: sampling rate
%% fft_size: size of fft used to calculate frequency response
%%
%% optional parameters:
%%
%% title: title to add to figure
%% filename: prefix to filename of figure (figure is not written unless this is specified)
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

function [] = sphear_signal_plot_frequency_response(SIG, measurements, fmin, fmax, ymin, ymax, FS, fft_size, figure_title, filename, smooth)

  %% no smoothing by default
  if (!exist("smooth"))
    smooth = 0;
  end
  for s = 1:size(SIG,2)
    %% calculate frequency responses
    for m = measurements
      if (smooth > 0)
	sfft(m,s,:) = fastsmooth(20*log10(abs(fft(SIG(m,s,:), fft_size))), smooth, 2, 1);
      else
	sfft(m,s,:) = 20*log10(abs(fft(SIG(m,s,:), fft_size)));
      end
    end
    fig = figure;
    hold on;
    fr = (1:fft_size/2) * FS/fft_size;
    grid on;
    if (exist("figure_title"))
      title(figure_title);
    end
    axis([fmin, fmax, ymin, ymax]);
    tics('y', [9, 6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30, -40, -50]);
    tics('x', [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
    ca=get (gcf, "currentaxes");
    set(ca, "fontweight", "bold", "linewidth", 1.5)
    pbaspect([16, 9, 1])
    for m = measurements
      if (m == 1)
	col = "k";
      else
	if (m < 8)
	  col = "r";
	else
	  if (m == 9)
	    col = "g";
	  else
	    col = "b";
	  end
	end
      end
      semilogx(fr, sfft(m,s,1:end/2), col, "linewidth", 1.5);
    end
    hold off;
    if (exist("filename"))
      %% write file with eps plot
      print(fig, '-deps', '-tight', '-color', '-depsc', '-S1920,1080', ["../data/current/figures/" filename ".eps"]);
      %% write png file
      print(fig, '-deps', '-tight', '-color', '-dpng', '-S1920,1080', ["../data/current/figures/" filename ".png"]);
    end
  end
end

