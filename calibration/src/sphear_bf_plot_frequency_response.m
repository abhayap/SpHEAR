%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_plot_frequency_response: plot frequency response of B-Format signals
%%
%% usage:
%%   [] = sphear_bf_plot_frequency_response(BF, AZ, EL, frefmin, frefmax, fmin, fmax, ymin, ymax, FS, fft_size, smooth)
%%
%% BF: B-Format signals for each measurement
%% frefmin, frefmax: reference frequency range to normalize W to 0dB
%% fmin, fmax: range of frequencies to use
%% ymin, ymax: y range to plot
%% FS: sampling rate
%% fft_size: size of fft used to calculate frequency response
%%
%% optional parameters:
%%
%% smooth: number of samples to average, default is 0
%%
%% Copyright 2016-2018, Fernando Lopez-Lezcano, All Rights Reserved
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

function [] = sphear_bf_plot_frequency_response(BF, AZ, EL, frefmin, frefmax, fmin, fmax, ymin, ymax, FS, fft_size, smooth)
  %% no smoothing by default
  if (!exist("smooth"))
    smooth = 0;
  end
  %% find average W power in reference frequency range
  SP = sphear_signal_power(BF, FS, frefmin, frefmax, fft_size);
  W_ref = mean(SP(:,1));
  %% calculate B format frequency responses
  for m = 1:size(BF, 1)
    for b = 1:size(BF, 2)
      if (smooth > 0)
	bfft(m,b,:) = fastsmooth(20*log10(abs(fft(BF(m,b,:) ./ W_ref, fft_size))), smooth, 2, 1);
      else
	bfft(m,b,:) = 20*log10(abs(fft(BF(m,b,:) ./ W_ref, fft_size)));
      end
    end
  end
  %% decide which components to plot based on size of array
  b_size = size(BF,2);
  %% plot frequency responses for each measurement
  for m = 1:size(BF, 1)
    fig = figure;
    hold on;
    fr = (1:fft_size/2) * FS/fft_size;
    grid on;
    title(sprintf(" azimuth = %.1f, elevation = %.1f (degrees)", AZ(m)/pi*180, EL(m)/pi*180));
    axis([fmin, fmax, ymin, ymax]);
    tics('y', [9, 6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30, -40, -50]);
    tics('x', [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
    ca=get(gcf, "currentaxes");
    set(ca, "fontweight", "bold", "linewidth", 1.0);
    pbaspect([16, 9, 1]);
    if (b_size == 4)
      %% WXYZ
      semilogx(fr, bfft(m,1,1:end/2), 'k;W;', "linewidth", 1.25);
      semilogx(fr, bfft(m,2,1:end/2), 'r;X;', "linewidth", 1.25);
      semilogx(fr, bfft(m,3,1:end/2), 'b;Y;', "linewidth", 1.25);
      semilogx(fr, bfft(m,4,1:end/2), 'g;Z;', "linewidth", 1.25);
      l = legend('W', 'X', 'Y', 'Z');
    end
    if (b_size == 5)
      %% WXYUV (second order horizontal)
      semilogx(fr, bfft(m,1,1:end/2), 'k;W;', "linewidth", 1.25);
      semilogx(fr, bfft(m,2,1:end/2), 'r;X;', "linewidth", 1.25);
      semilogx(fr, bfft(m,3,1:end/2), 'b;Y;', "linewidth", 1.25);
      semilogx(fr, bfft(m,4,1:end/2), 'r--;U;', "linewidth", 1.25);
      semilogx(fr, bfft(m,5,1:end/2), 'b--;V;', "linewidth", 1.25);
      l = legend('W', 'X', 'Y', 'U', 'V');
    end
    if (b_size > 5)
      %% WXYZSTUV (second order full sphere)
      semilogx(fr, bfft(m,1,1:end/2), 'k;W;', "linewidth", 1.25);
      semilogx(fr, bfft(m,2,1:end/2), 'r;X;', "linewidth", 1.25);
      semilogx(fr, bfft(m,3,1:end/2), 'b;Y;', "linewidth", 1.25);
      semilogx(fr, bfft(m,4,1:end/2), 'g;Z;', "linewidth", 1.25);
      semilogx(fr, bfft(m,5,1:end/2), 'r:;S;', "linewidth", 1.25);
      semilogx(fr, bfft(m,6,1:end/2), 'b:;T;', "linewidth", 1.25);
      semilogx(fr, bfft(m,7,1:end/2), 'r--;U;', "linewidth", 1.25);
      semilogx(fr, bfft(m,8,1:end/2), 'b--;V;', "linewidth", 1.25);
      l = legend('W', 'X', 'Y', 'Z', 'S', 'T', 'U', 'V');
    end
    legend(l, 'location', 'west');
    hold off;
    %% write file with eps plot
    %% print(fig, '-deps', '-tight', '-color', ["../data/current/figures/sphear_bf_azimuth_" sprintf("%03.0f", angle) ".eps"]);
  end
end
