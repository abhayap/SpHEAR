%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_af_plot_frequency_response: plot frequency response of B-Format signals
%%
%% usage:
%%   [] = sphear_af_plot_frequency_response(SIG, fmin, fmax, ymin, ymax, Fs, Nfft, smooth)
%%
%% SIG: signals for each measurement
%% fmin, fmax: range of frequencies to use
%% ymin, ymax: y range to plot
%% Fs: sampling rate
%% Nfft: size of fft used to calculate frequency response
%%
%% optional parameters:
%%
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

function [] = sphear_af_plot_frequency_response(SIG, fmin, fmax, ymin, ymax, Fs, Nfft, smooth)

  %% no smoothing or plotting by default
  if (!exist("smooth"))
    smooth = 0;
  end
  for m = 1:16
    %% calculate frequency responses
    for c = 1:size(SIG,2)
      if (smooth > 0)
	sfft(m,c,:) = fastsmooth(20*log10(abs(fft(SIG(m,c,:), Nfft))), smooth, 2, 1);
      else
	sfft(m,c,:) = 20*log10(abs(fft(SIG(m,c,:), Nfft)));
      end
    end
    %% color plot
    copts = ['k', 'r', 'b', 'g', ':g', ':b', ':r', ':k'];
    cext = "_color";

    f = figure;
    hold on;
    fr = (1:Nfft/2) * Fs/Nfft;
    grid on;
    angle = 360 / 16 * (m - 1);
    %% we add the title as a subfigure in the paper
    %% title(sprintf("azimuth = %.1f degrees", angle));
    axis([fmin, fmax, ymin, ymax]);
    tics('y', [6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30, -40, -50]);
    tics('x', [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
    ca=get (gcf, "currentaxes");
    set(ca,"fontweight","bold","linewidth",1.5)
    pbaspect([16, 9, 1])
    for c = 1:size(SIG,2)
      semilogx(fr, sfft(m,c,1:end/2), copts(c), "linewidth", 1.5);
    end
    if (size(SIG,2) > 4)
      %%l = legend('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8');
    else
      %%l = legend('C1', 'C2', 'C3', 'C4');
    end
    %%legend(l, 'location', 'west');
    hold off;
    print(f, '-deps', '-tight', '-color', ["../data/current/figures/sphear_bf_azimuth_" sprintf("%03.0f", angle) cext ".eps"]);
  end
end

