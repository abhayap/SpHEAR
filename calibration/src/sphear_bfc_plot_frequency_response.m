%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_bf_plot_frequency_response: plot frequency response of B-Format signals
%%
%% usage:
%%   [] = sphear_bf_plot_frequency_response(BF, AZ, EL, b, frefmin, frefmax, fmin, fmax, ymin, ymax, FS, fft_size, smooth)
%%
%% BF: B-Format signals for each measurement
%% AZ: azimuth
%% EL: elevation
%% b: number of component to plot
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

function [] = sphear_bfc_plot_frequency_response(BF, AZ, EL, b, frefmin, frefmax, fmin, fmax, ymin, ymax, FS, fft_size, smooth)
  %% no smoothing by default
  if (!exist("smooth"))
    smooth = 0;
  end
  %% find average power in reference frequency range
  SP = sphear_signal_power(BF, FS, frefmin, frefmax, fft_size);
  W_ref = mean(SP(:,1));
  %% calculate B format frequency responses
  for m = 1:size(BF, 1)
    if (smooth > 0)
      bfft(m,b,:) = fastsmooth(20*log10(abs(fft(BF(m,b,:) ./ W_ref, fft_size))), smooth, 2, 1);
    else
      bfft(m,b,:) = 20*log10(abs(fft(BF(m,b,:) ./ W_ref, fft_size)));
    end
  end
  bnames = ['W', 'X', 'Y', 'Z', 'S', 'T', 'U', 'V'];
  f = figure;
  hold on;
  fr = (1:fft_size/2) * FS/fft_size;
  grid on;
  title(sprintf("%s", bnames(b)));
  axis([fmin, fmax, ymin, ymax]);
  tics('y', [9, 6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30, -40, -50]);
  tics('x', [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
  ca=get(gcf, "currentaxes");
  set(ca, "fontweight", "bold", "linewidth", 1.0);
  pbaspect([16, 9, 1]);
  %% plot frequency responses for each measurement
  for m = 1:size(BF, 1)
    azim = AZ(m)/pi*180;
    elev = EL(m)/pi*180;
    %% do some coloring
    if (mod(azim, 360) <= 90 || mod(azim, 360) > 270)
      c = 'r';
    else
      c = 'b';
    end
    if (azim == 0) c = 'k'; end
    if (azim == 180) c = 'g'; end
    %% and plot it
    semilogx(fr, bfft(m,b,1:end/2), c, "linewidth", 1.25);
    %% add azimuth and elevation markings
    fidx=500 * (1.095^m);
    idx=round(fft_size/fmax*fidx/2);
    text(fidx, bfft(m,b,idx) / 1.02, sprintf("%d:%d:%d", m, azim, elev),
	 "fontweight", "bold", "fontsize", 12, "verticalalignment", "baseline", "color", c);
    %% l = legend('W', 'X', 'Y', 'Z');
    %% legend(l, 'location', 'west');
  end
  hold off;
end
