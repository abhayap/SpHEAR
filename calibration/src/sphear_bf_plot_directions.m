%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_plot_directions: render amplitude response plots of B format signals
%%                            version for current prototype
%%
%% usage:
%%   [] = sphear_bf_plot_directions(fmin, fmax, ymin, ymax, Nfft, plot_on, smooth)
%%
%% fmin, fmax: range of frequencies to plot (Hz)
%% ymin, ymax: vertical scale for plot (dB)
%% Nfft: size of FFT
%%
%% optional parameters:
%%
%% plot_on: plot frequency response of components, default is "epsc"
%%          can be one of 0, "eps", "epsc" (color), "png", "pngc" (color)
%% smooth: number of samples to average, default is 0
%%
%% implied parameter:
%%     files: "../data/current/bf-tetraproc/b-format-xxx.wav"
%%     four channel B format, FUMA ordering and weights
%%
%% example:
%%   sphear_bf_plot_directions(lf_limit, hf_limit, -15, 3, render_fft_size, 1, 0);
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

function [] = sphear_bf_plot_directions(fmin, fmax, ymin, ymax, Nfft, plot_on, smooth)

  %% no smoothing or plotting by default
  if (!exist("smooth"))
    smooth = 0;
  end
  if (!exist("plot_on"))
    plot_on = "epsc";
  else
    if (plot_on == 1)
      plot_on = "epsc";
    end
  end

  %% plot if requested
  if (plot_on != 0)
    if (strcmp(plot_on, "epsc") || strcmp(plot_on, "pngc"))
      %% color plot
      wopts = 'k;W;';
      xopts = 'r;X;';
      yopts = 'b;Y;';
      copt = '-color';
      cext = "_color";
    else
      %% mono plot
      wopts = '-';
      xopts = '--';
      yopts = ':';
      copt = '-mono';
      cext = "_mono";
    end
    f = figure;
    hold on;
    grid on;
    axis([fmin, fmax, ymin, ymax]);
    tics('y', [6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30]);
    tics('x', [300, 500, 1000, 1500, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
    ca=get (gcf, "currentaxes");
    set(ca,"fontweight","bold","linewidth",1.5);

    %% measurements, first four in cardinal directions
    measurements = [1, 5, 9, 13, 3, 7, 11, 15];

    %% which components to plot, we ommit the ones that are nulled
    %% 0: do not plot, 1: cardinal, 2: diagonal plot
    m_W = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0];
    m_X = [1, 0, 2, 0, 0, 0, 2, 0, 1, 0, 2, 0, 0, 0, 2, 0];
    m_Y = [0, 0, 2, 0, 1, 0, 2, 0, 0, 0, 2, 0, 1, 0, 2, 0];
    m_Z = [1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0];
    
    idx = 1;
    for m = measurements
      %% read rendered four channel B format measurement
      %% trim to just the needed part
      range = [512:4096];
      [bsig, Fs] = wavread(["../data/current/bf-tetraproc/b-format-" sprintf("%03d", m(1)) ".wav"]);
      %% convert tetraproc FUMA output to SN3D
      bsig(:,1) = bsig(:,1) / 0.707;
      %% calculate B format frequency responses
      for b = 1:4
	bsig_fft = fft(bsig(range,b), Nfft);
	if (smooth > 0)
	  bfft(idx,b,:) = fastsmooth(10*log10(abs(bsig_fft)), smooth, 2, 1)(1:end/2);
	else
	  bfft(idx,b,:) = 10*log10(abs(bsig_fft))(1:end/2);
	end
	idx = idx + 1;
      end
    end

    %% scale everything to average of W (1st measurement)
    fft_avg = mean(bfft(1,1,round(end/4):round(end/2)));

    %% now do the plots
    idx = 1;
    W_offset = +0;
    X_offset = -6;
    Y_offset = -6;
    fr = (1:Nfft/2) * Fs/Nfft;
    for m = measurements
      for b = 1:4
	if (m_W(m) > 0 && b == 1)
	  if (m_W(m) > 1)
	    pW = semilogx(fr, bfft(idx,b,:) - fft_avg + W_offset, wopts, "linewidth", 1.5, "color", 'k', "linestyle", "--");
	  else
	    pW = semilogx(fr, bfft(idx,b,:) - fft_avg + W_offset, wopts, "linewidth", 1.5, "color", 'k');
	  end
	end
	if (m_X(m) > 0 && b == 2)
	  if (m_X(m) > 1)
	    pXd = semilogx(fr, bfft(idx,b,:) - fft_avg + X_offset, xopts, "linewidth", 1.5, "color", "r", "linestyle", "--");
	  else
	    pXp = semilogx(fr, bfft(idx,b,:) - fft_avg + X_offset, xopts, "linewidth", 1.5, "color", 'r');
	  end
	end
	if (m_Y(m) > 0 && b == 3)
	  if (m_Y(m) > 1)
	    pYd = semilogx(fr, bfft(idx,b,:) - fft_avg + Y_offset, yopts, "linewidth", 1.5, "color", "b", "linestyle", "--");
	  else
	    pYp = semilogx(fr, bfft(idx,b,:) - fft_avg + Y_offset, yopts, "linewidth", 1.5, "color", 'b');
	  end
	end
	idx = idx + 1;
      end
    end
    l = legend([pW, pXp, pXd, pYp, pYd],
	       {sprintf("W principal directions (%.1fdB offset)", W_offset),
		sprintf("X principal directions (%.1fdB offset)", X_offset),
		sprintf("X diagonal directions (%.1fdB offset)", Y_offset),
		sprintf("Y principal directions (%.1fdB offset)", X_offset),
		sprintf("Y diagonal directions (%.1fdB offset)", Y_offset),
	       });
    legend(l, 'location', 'southwest');
    if (strcmp(plot_on, 'eps') || strcmp(plot_on, 'epsc') || plot_on == 1)
      print(f, '-deps', '-tight', '-S1920,1080', copt, ["../figures/b_format_sphear3.eps"]);
    else
      print(f, '-deps', copt, ["../figures/b_format_sphear3.eps"]);
    end

  end
end

