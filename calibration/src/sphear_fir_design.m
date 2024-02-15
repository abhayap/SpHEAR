%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_fir_design: design a matrix of FIR filters that equalizes the microphone
%%
%% usage:
%%   [FIR] = sphear_fir_design(F, A2BF, n, maxboost, Fs, Fl, plot_on,
%%                             shelf_gain, shelf_freq, transition_octaves, W, X, Y, Z)
%%
%% F: array of filter section center frequencies
%% A2BF: vector of A2B matrixes, one for each frequency
%% n: order of the FIR filter being created
%% maxboost: max high and low frequency boost in dB of the final filter
%% Fs: sampling rate
%% Fl: frequency limit, below it use A2B matrixes, above it use W, X, Y, Z shapes
%% plot_on: plot frequency response of components, default is "epsc"
%%          can be one of 0, "eps", "epsc" (color), "png", "pngc" (color)
%%
%% shelf_gain: optional high pass shelf filter, gain in dB (0.0 dB turns it off)
%% shelf_freq: corner frequency in Hertz
%% transition_octaves: transition width in octaves below the corner frequency
%%
%% for the first run do not supply W/X/Y/Z, render the filters and then run
%% sphear_fir_extract to extract the W, X, Y and Z filter shapes, finally run
%% this again with the extra parameters below
%%
%% W: extracted shape of W filter (used above Fl)
%% X: extracted shape of X filter (used above Fl)
%% Y: extracted shape of Y filter (used above Fl)
%% Z: extracted shape of Z filter (used above Fl)
%%    Z is optional, if not supplied X and Y are averaged to obtain Z
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

function [FIR] = sphear_fir_design(F, A2BF, n, maxboost, Fs, Fl, plot_on, shelf_gain, shelf_freq, transition_octaves, W, X, Y, Z)

  if (plot_on != 0)
    fig = figure;
  end

  if (exist("W") == 1 && ! exist("Z"))
    %% Z was not supplied, just average X and Y data
    Z = (X + Y) / 2;
  end

  %% find the index of the transition frequency band
  fl_idx = 1;
  for d = 1:size(A2BF(:,1,1))(1)
    if (F(d) <= Fl)
      fl_idx = d;
    end
  end
  printf("transition band is %d at %f Hz\n", fl_idx, F(fl_idx));

  %% create optional high pass shelf filter (in dB)
  if (exist("shelf_gain") && (shelf_gain != 0.0))
    shelf_corner = shelf_freq / (2^transition_octaves);
    %% transition
    shelf = (tukeywin(32, 0.9)(1:end/2) * shelf_gain);
    %% interpolate over existing frequency array
    fr_profile = interp1([F(1), linspace(shelf_corner, shelf_freq, 16), F(end)], [0.0, shelf', shelf_gain], F);
  else
    fr_profile = interp1([F(1), F(fl_idx), F(end)], [0, 0, 0], F);
  end

  dmax = size(A2BF(:,1,1))(1);
  %% calculate running averages of WXYZ filters and A2B matrices
  for b = 1:4
    %% all capsules
    for c = 1:4
      %% all frequency bands going down
      for d = dmax:-1:1
	if (F(d) > Fl)
	  %% running average of A2B matrices
	  if (d == dmax)
	    upper_a2b(c, b, :) = A2BF(d, c, b);
	  else
	    if (d < dmax)
	      upper_a2b(c, b, :) = (upper_a2b(c, b, :) + A2BF(d, c, b)) / 2;
	    end
	  end
	  if (exist("W") == 1)
	    %% running average of the filter values
	    if (d == dmax)
	      upper_w(c, b) = W(d);
	      upper_x(c, b) = X(d);
	      upper_y(c, b) = Y(d);
	      upper_z(c, b) = Z(d);
	    else
	      if (d < dmax)
		upper_w(c, b) = (upper_w(c, b) + W(d)) / 2;
		upper_x(c, b) = (upper_x(c, b) + X(d)) / 2;
		upper_y(c, b) = (upper_y(c, b) + Y(d)) / 2;
		upper_z(c, b) = (upper_z(c, b) + Z(d)) / 2;
	      end
	    end
	  end
	end
      end
      %% all frequency bands going up
      for d = 1:dmax
	if (F(d) <= Fl)
	  %% running average of A2B matrices
	  if (d == 1)
	    lower_a2b(c, b, :) = A2BF(d, c, b);
	  else
	    if (d > 1)
	      lower_a2b(c, b, :) = (lower_a2b(c, b, :) + A2BF(d, c, b)) / 2;
	    end
	  end
	  if (exist("W") == 1)
	    %% running average of the filter values
	    if (d == 1)
	      lower_w(c, b) = W(d);
	      lower_x(c, b) = X(d);
	      lower_y(c, b) = Y(d);
	      lower_z(c, b) = Z(d);
	    else
	      if (d > 1)
		lower_w(c, b) = (lower_w(c, b) + W(d)) / 2;
		lower_x(c, b) = (lower_x(c, b) + X(d)) / 2;
		lower_y(c, b) = (lower_y(c, b) + Y(d)) / 2;
		lower_z(c, b) = (lower_z(c, b) + Z(d)) / 2;
	      end
	    end
	  end
	end
      end
    end
  end

  %% all b format components
  for b = 1:4
    %% all capsules
    for c = 1:4
      %% all frequency bands
      for d = 1:dmax
	%% create an array of points to design the filter
	if (F(d) <= Fl)
	  dlast = d;
	  %% apply frequency response profile
	  A2BF(d, c, b) = A2BF(d, c, b) * 10^(fr_profile(d)/10);
	else
	  %% above the limit frequency we insert the W, X, Y and Z
	  %% data if they exist, otherwise keep the last valid value
	  %% from the A2B coefficients (ie: flat above the transition
	  %% frequency
	  limit_a2b = ((lower_a2b(c, b, :) + lower_a2b(c, b, :)) / 2);
	  if (b == 1)
	    if (exist("W") == 1)
	      A2BF(d, c, b) = limit_a2b * (W(d)/((lower_w(c, b) + upper_w(c, b)) / 2)) * 10^(fr_profile(d)/10);
	    else
	      A2BF(d, c, b) = limit_a2b;
	    end
	  end
	  if (b == 2)
	    if (exist("X") == 1)
	      A2BF(d, c, b) = limit_a2b * (X(d)/((lower_x(c, b) + upper_x(c, b)) / 2)) * 10^(fr_profile(d)/10);
	    else
	      A2BF(d, c, b) = limit_a2b;
	    end
	  end
	  if (b == 3)
	    if (exist("Y") == 1)
	      A2BF(d, c, b) = limit_a2b * (Y(d)/((lower_y(c, b) + upper_y(c, b)) / 2)) * 10^(fr_profile(d)/10);
	    else
	      A2BF(d, c, b) = limit_a2b;
	    end
	  end
	  if (b == 4)
	    if (exist("Z") == 1)
	      A2BF(d, c, b) = limit_a2b * (Z(d)/((lower_z(c, b) + upper_z(c, b)) / 2)) * 10^(fr_profile(d)/10);
	    else
	      A2BF(d, c, b) = limit_a2b;
	    end
	  end
	end
      end
    end
  end

  %% normalize all components to the average of W levels for all
  %% capsules around the transition frequency
  if ((dlast+1) > size(A2BF(:,1,1))(1))
    %% special case for testing with a very high transition frequency
    avg = [dlast-3, dlast-2, dlast-1];
  else
    avg = [dlast-1, dlast, dlast+1];
  end

  nrm = mean([mean(A2BF(avg,1,1))
	      mean(A2BF(avg,2,1))
	      mean(A2BF(avg,3,1))
	      mean(A2BF(avg,4,1))]);

  for b = 1:4
    for c = 1:4
      %% normalize coefficients
      for dn = 1:size(A2BF(:,1,1))(1)
	A2BF(dn,c,b) = A2BF(dn,c,b) ./ nrm;
      end

      %% fit a spline to the W, X, Y and Z data and extrapolate
      %% highest frequency if it does not exist in the measurements
      %%
      %% the 200Hz spacing of the points is arbitrary, we should
      %% select something that makes more sense
      %%
      fh = (F(dlast-1)/(Fs/2):200/(Fs/2):1)';
      %% make the end really 1.0
      fh(end) = 1;
      rh = interp1(F(dlast-1:end)/(Fs/2), A2BF(dlast-1:end,c,b)', fh, "spline", "extrap");

      %% we fit the spline taking into account one additional point
      %% on the bottom edge so that it will fit better with the existing
      %% low frequency points, now we find the exact transition frequency
      %% in the interpolated array
      for idx = 1:size(fh(:))
	if (fh(idx) <= F(dlast)/(Fs/2))
	  istart = idx;
	end
      end
      
      %% extract the low frequency A2B coefficients
      fl = [0 F(1:dlast-1)']' ./ (Fs/2);
      rl = [A2BF(1,c,b) A2BF(1:dlast-1,c,b)']';

      %% concatenate low and high frequency arrays
      fi = cat(1, fl, fh(istart:end));
      ri = cat(1, rl, rh(istart:end));

      %% force a max boost at low and high frequencies
      if (maxboost != 0)
	printf("b-format component:%d capsule:%d \n", b, c);
	for idx = 1:size(ri(:))
	  if (abs(ri(idx)) > 10^(maxboost/10))
	    printf("freq=%.2f: limit boost from %.2f to %.2f dB\n", fi(idx)*Fs/2, 10*log10(ri(idx)), maxboost);
	    ri(idx) = sign(ri(idx)) * 10^(maxboost/10);
	  end
	end
      end
      
      if (plot_on != 0)
	if (strcmp(plot_on, "epsc") || strcmp(plot_on, "pngc"))
	  %% color plot
	  popts = '.k';
	  wopts = 'b';
	  xyopts = 'r';
	  zopts = 'g';
	  copt = '-color';
	  cext = "_color";
	else
	  %% mono plot
	  popts = '.k';
	  wopts = '-';
	  xyopts = '--';
	  zopts = ':';
	  copt = '-mono';
	  cext = "_mono";
	end
	grid on;
	axis([400, 20000]);
	xticks = [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 20000];
	set(gca, 'XTick', xticks);
	set(gca, 'XTickLabel', sprintf('%d|', xticks));
	ca=get (gcf, "currentaxes");
	set(ca,"fontweight","bold","linewidth",1.5)
	pbaspect([16, 9, 1])
	%% title(sprintf("B format FIR filters (transition frequency: %d Hz)", Fl));
	hold on;
	%% plot real measured points
	%% ph = semilogx(F, 10*log10(abs(A2BF(:,c,b)))', popts, "linewidth", 1.5);
	%% plot extrapolated filter
	if (b == 1)
	  %% W
	  wh = semilogx(fi*(Fs/2), 10*log10(abs(ri)), wopts, "linewidth", 1.5);
	else
	  if (b == 4)
	    %% Z
	    zh = semilogx(fi*(Fs/2), 10*log10(abs(ri)), zopts, "linewidth", 1.5);
	  else
	    %% XY
	    xyh = semilogx(fi*(Fs/2), 10*log10(abs(ri)), xyopts, "linewidth", 1.5);
	  end
	end
      end

      %% design the filter and try to get it close to minimum phase
      %%
      %% "Two alternative minimum-phase filters tested perceptually"
      %% Robert Mores and Ralf Hendrych, AES Convertion paper 9554
      %%
      IR = fir2(n - 1, fi, ri)';
      %%
      %% number of samples in the sin transition
      %%
      %% 8 seems to be the sweet spot for a FIR filter size of 256,
      %% 16 leads to bigger phase shift, 4 starts to impact negatively
      %% the flattness of the frequency response
      %%
      M = size(IR)(1);
      N = M/32;
      R = 0.5 + (0.5 * sin(pi * ((1:(2*N)) - N) / (2 * N)));
      ramp = cat(1, zeros(M/2 - N, 1), R', ones(M/2 - N, 1));
      IRMP = IR .* ramp * 2;
      %%
      %% now we trim the filter and return one that is 1/2 the size requested
      %% because it is now almost minimum phase and the first half is zeroed
      %%
      %% we also window the end of the impulse response... (unnecessary?)
      %% T = 4;
      %% tapper = cat(1, ones(M/2 - 2*T + 1, 1), (1.0 - (0.5 + (0.5 * sin(pi * ((1:(2*T)) - T) / (2 * T)))))');
      %%
      FIR(b, c, :) = IRMP(M/2 - N:M/2 - N + M/2 - 1);
    end
  end

  %% write a tetraproc compatible wav file
  fuma = [sqrt(2)/2, 1, 1, 1];
  for b = 1:4
    %% each column is one channel, W/X/Y/Z, all capsules concatenated
    TETRA(:, b) = fuma(b) * cat(1,
				reshape(FIR(b, 1, :), 1, [])',
				reshape(FIR(b, 2, :), 1, [])',
				reshape(FIR(b, 3, :), 1, [])',
				reshape(FIR(b, 4, :), 1, [])');
  end
  wavwrite(TETRA, Fs, '../data/current/cal/tetraproc_matrix.wav');
  
  if (plot_on != 0)
    l = legend([wh, zh, xyh], {'W', 'XY', 'Z'});
    legend(l, 'location', 'west');
    if (exist("W") == 1)
      if (strcmp(plot_on, 'eps') || strcmp(plot_on, 'epsc') || plot_on == 1)
	print(fig, '-deps','-tight',copt,["../data/current/figures/wxyz_filter_ff" cext ".eps"]);
      else
	print(fig, '-dpng',copt,["../data/current/figures/wxyz_filter_ff" cext ".png"]);
      end
    else
      if (strcmp(plot_on, 'eps') || strcmp(plot_on, 'epsc') || plot_on == 1)
	print(fig, '-deps','-tight',copt,["../data/current/figures/wxyz_filter_lf" cext ".eps"]);
      else
	print(fig, '-dpng',copt,["../data/current/figures/wxyz_filter_lf" cext ".png"]);
      end
    end
  end
end
