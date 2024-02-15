%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_fir_render: render impulse responses throught the FIR filter A2B matrix
%%
%% usage:
%%   [] = sphear_fir_render(FIR, fmin, fmax, ymin, ymax, Nfft, plot_on, smooth)
%%
%% FIR: A2B matrix of FIR filters
%% fmin, fmax: range of frequencies to use
%% ymin, ymax: y range to plot
%% Fs: sampling rate
%% Nfft: size of fft used to calculate frequency response
%%
%% optional parameters:
%%
%% plot_on: plot frequency response of components, default is "epsc"
%%          can be one of 0, "eps", "epsc" (color), "png", "pngc" (color)
%% smooth: number of samples to average, default is 0
%%
%% Copyright 2016, Fernando Lopez-Lezcano, All Rights Reserved
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

function [BFF] = sphear_fir_render(FIR, fmin, fmax, ymin, ymax, Fs, Nfft, plot_on, smooth)

  %% no smoothing or plotting by default
  if (!exist("smooth"))
    smooth = 0;
  end
  if (!exist("plot_on"))
    plot_on = "epsc";
  else
    if (plot_on == 1)
      plot_on = "epsc"
    end
  end

  for m = 1:16
    %% render b format components
    bf(m,:,:) = sphear_a_to_b(m, FIR, Nfft);

    %% calculate B format frequency responses
    for b = 1:4
      if (smooth > 0)
	bfft(m,b,:) = fastsmooth(20*log10(abs(fft(bf(m,b,:), Nfft))), smooth, 2, 1);
      else
	bfft(m,b,:) = 20*log10(abs(fft(bf(m,b,:), Nfft)));
      end
    end

    %% write soundfile with rendered B format signals
    %%
    %% if we write a 32 bit soundfile we need to scale by 256
    %% if we want the same amplitude as when writing a 16 bit
    %% per sample soundfile, otherwise we get nasty clipping
    wavwrite(reshape(bf(m,:,:),4,[])' / 256, Fs, 32, ["../data/current/bf/b-format-" sprintf("%02.0f", m) ".wav"]);

    %% plot if requested
    if (plot_on != 0)
      if (strcmp(plot_on, "epsc") || strcmp(plot_on, "pngc"))
	%% color plot
	wopts = 'k;W;';
	xopts = 'r;X;';
	yopts = 'b;Y;';
	zopts = 'g;Z;';
	copt = '-color';
	cext = "_color";
      else
	%% mono plot
	wopts = '-;W;';
	xopts = '--;X;';
	yopts = '-.;Y;';
	zopts = ':;Z;';
	copt = '-mono';
	cext = "_mono";
      end
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
      semilogx(fr, bfft(m,1,1:end/2), wopts, "linewidth", 1.5);
      semilogx(fr, bfft(m,2,1:end/2), xopts, "linewidth", 1.5);
      semilogx(fr, bfft(m,3,1:end/2), yopts, "linewidth", 1.5);
      semilogx(fr, bfft(m,4,1:end/2), zopts, "linewidth", 1.5);
      l = legend('W', 'X', 'Y', 'Z');
      legend(l, 'location', 'west');
      hold off;
      if (strcmp(plot_on, 'eps') || strcmp(plot_on, 'epsc') || plot_on == 1)
	print(f, '-deps', '-tight', copt, ["../data/current/figures/sphear_bf_azimuth_" sprintf("%03.0f", angle) cext ".eps"]);
      else
	print(f, '-dpng', copt, ["../data/current/figures/sphear_bf_azimuth_" sprintf("%03.0f", angle) cext ".png"]);
      end
    end
  end

end

