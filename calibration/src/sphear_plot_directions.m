%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_plot_directions: render amplitude response plots of B format signals
%%                            version for current prototype
%%
%% usage:
%%   [] = sphear_plot_directions(BF, fmin, fmax, ymin, ymax, Fs, Nfft, smooth)
%%
%% fmin, fmax: range of frequencies to plot (Hz)
%% ymin, ymax: vertical scale for plot (dB)
%% Nfft: size of FFT
%%
%% optional parameters:
%%
%% smooth: number of samples to average, default is 0
%%
%% implied parameter:
%%     files: "../data/current/bf-tetraproc/b-format-xxx.wav"
%%     four channel B format, FUMA ordering and weights
%%
%% example:
%%   sphear_plot_directions(lf_limit, hf_limit, -15, 3, render_fft_size, 1, 0);
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

function [] = sphear_plot_directions(BF, fmin, fmax, ymin, ymax, Fs, Nfft, smooth)
  f = figure;
  hold on;
  grid on;
  %% pbaspect([16, 9, 1]);
  axis([fmin, fmax, ymin, ymax]);
  tics('y', [9, 6, 3, 0, -3, -6, -9, -12, -15, -20, -25, -30]);
  tics('x', [300, 500, 1000, 1500, 2000, 3000, 5000, 7000, 10000, 15000, 20000]);
  ca=get (gcf, "currentaxes");
  set(ca,"fontweight","bold");

  %% which directions to plot for each microphone array and each componentx
  %% 0: do not plot, 1: cardinal plot, 2: diagonal plot
  if (size(BF, 2) > 4)
    %% octa
    %%m_W = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1];
    m_W = [1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0];
    m_X = [1, 0, 2, 0, 0, 0, 2, 0, 1, 0, 2, 0, 0, 0, 2, 0];
    m_Y = [0, 0, 2, 0, 1, 0, 2, 0, 0, 0, 2, 0, 1, 0, 2, 0];
    m_Z = [1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0];
  else
    %% tetra
    m_W = [1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0];
    m_X = [1, 0, 2, 0, 0, 0, 2, 0, 1, 0, 2, 0, 0, 0, 2, 0];
    m_Y = [0, 0, 2, 0, 1, 0, 2, 0, 0, 0, 2, 0, 1, 0, 2, 0];
    m_Z = [1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0];
  end

  for m = 1:size(BF, 1)
    %% calculate B format frequency responses
    for b = 1:size(BF, 2)
      if (smooth > 0)
	printf("m:%d, c:%d: applying smoothing of %f...\n", m, b, smooth);
	bfft(m,b,:) = fastsmooth(10*log10(abs(fft(BF(m, b, :), Nfft))), smooth, 3, 1)(1:end/2);
      else
	bfft(m,b,:) = 10*log10(abs(fft(BF(m, b, :), Nfft)))(1:end/2);
      end
    end
  end

  %% scale everything to average of W (1st measurement)
  fft_avg = mean(bfft(1,1,round(end/4):round(end/2)));

  %% now do the plots
  W_offset = +0;
  Wd_offset = -3;
  X_offset = -6;
  Y_offset = -6;
  fr = (1:Nfft/2) * Fs/Nfft;
  for m = 1:size(BF, 1)
    %% W cardinals
    if (m_W(m) == 1)
      pW = semilogx(fr, bfft(m,1,:) - fft_avg + W_offset, "k-", "linewidth", 1.25);
    end
  end
  for m = 1:size(BF, 1)
    %% W diagonals
    if (m_W(m) == 2)
      pWd = semilogx(fr, bfft(m,1,:) - fft_avg + Wd_offset, "k--", "linewidth", 1.25);
    end
  end
  for m = 1:size(BF, 1)
    %% X cardinals
    if (m_X(m) == 1)
      pXp = semilogx(fr, bfft(m,2,:) - fft_avg + X_offset, "r-", "linewidth", 1.25);
    end
  end
  for m = 1:size(BF, 1)
    %% X diagonals
    if (m_X(m) == 2)
      pXd = semilogx(fr, bfft(m,2,:) - fft_avg + X_offset, "r--", "linewidth", 1.25);
    end
  end
  for m = 1:size(BF, 1)
    %% Y cardinals
    if (m_Y(m) == 1)
      pYp = semilogx(fr, bfft(m,3,:) - fft_avg + Y_offset, "b-", "linewidth", 1.25);
    end
  end
  for m = 1:size(BF, 1)
    %% Y diagonals
    if (m_Y(m) == 2)
      pYd = semilogx(fr, bfft(m,3,:) - fft_avg + Y_offset, "b--", "linewidth", 1.25);
    end
  end
  l = legend([pW, pWd, pXp, pXd, pYp, pYd], ...
	     {sprintf("W principal directions (%.1fdB offset)", W_offset), ...
	      sprintf("W diagonal directions (%.1fdB offset)", W_offset), ...
	      sprintf("X principal directions (%.1fdB offset)", X_offset), ...
	      sprintf("X diagonal directions (%.1fdB offset)", Y_offset), ...
	      sprintf("Y principal directions (%.1fdB offset)", X_offset), ...
	      sprintf("Y diagonal directions (%.1fdB offset)", Y_offset), ...
	     });
  legend("boxoff");
  %% legend(l, 'location', 'south');
  rect = [0.15, 0.15, 0.5, 0.16];
  set(l, 'position', rect);
end

