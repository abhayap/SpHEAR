%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_design_fir_filters: design FIR filters based on B format spectrum shapes
%%
%% usage:
%%   [FIR IR MPS] = sphear_design_fir_filters(F, n, SR, W, X, Y, Z, U, V,
%%                                            UV_lf_freq, UV_lf_slope, DC_gain_offset_db)
%%
%% F: array of filter section center frequencies
%% n: order of the FIR filter being created
%% SR: sampling rate
%%
%% W, X, Y, Z, U, V: extracted shape of B format component filter (used above Fl)
%%    Z: optional, if not supplied X and Y are averaged to obtain Z
%%    UV: optional, if not supplied only first order shapes are calculated
%%        can be arrays and then an array of filters will be calculated and returned
%%
%% UV_lf_freq: corner frequency of low pass filter that limits low frequency gain of UV
%% UV_lf_slop: slope in dB/oct of the low pass filter
%% DC_gain_offset_db: DC filter gain in dB
%%
%% FIR: array of minimum phase FIR filters
%% IR: calculated FIR filters
%% MPS: output of mps without windowing (minimum phase)
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
%%  along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% NOTES: using fir2 for now, firls calculates non-smooth filters with worse
%% frequency response, remez does not converge in my tests

function [FIR IR MPS] = sphear_design_fir_filters(F, n, SR, W, X, Y, Z, S, T, U, V, UV_lf_freq, UV_lf_slope, DC_gain_offset_db)
  if ! exist("Z")
    %% if Z was not supplied, just average X and Y data
    Z = (X + Y) / 2;
  end
  if ! exist("DC_gain_offset_db")
    %% by default no gain offset at DC for UV filters
    DC_gain_offset_db = 0;
  end
  DC_gain_offset = db2mag(DC_gain_offset_db);
  %% make a 0 to 1 vector of relative frequencies
  freqs = [0, (F/(SR/2))', 1]';
  %% design the filters, we use twice the requested size as the
  %% final filters will become 1/2 the size when folded for minimum phase
  IR(1,:) = fir2(n, freqs, [W(1), W', W(end)]');
  IR(2,:) = fir2(n, freqs, [X(1), X', X(end)]');
  IR(3,:) = fir2(n, freqs, [Y(1), Y', Y(end)]');
  IR(4,:) = fir2(n, freqs, [Z(1), Z', Z(end)]');
  if (exist("U") && exist("V"))
    %% make a n-dB/oct low pass filter shape for UV components
    %% this limits the high pass filter gain (and noise) at low frequencies
    for f = (1:size(F))
      if (F(f) > UV_lf_freq)
	UV_lpf(f,:) = 1.0;
      else
	UV_lpf(f,:) = db2mag((F(f) - UV_lf_freq)/UV_lf_freq*UV_lf_slope);
      end
    end
    UV_lpf = [DC_gain_offset, UV_lpf', 1.0]';
    %% calculate UV filters
    if (size(U, 2) > 1)
      %% we are using one U/V filter for each capsule
      %% add all filters at end of array (16 total)
      for c = 1:size(U, 2)
	IR(4+c,:) = fir2(n, freqs, [U(1,c), U(:,c)', U(end,c)]' .* UV_lpf);
	IR(4+size(U,2)+c,:) = fir2(n, freqs, [V(1,c), V(:,c)', V(end,c)]' .* UV_lpf);
      end
    else
      IR(5,:) = fir2(n, freqs, [S(1), S', S(end)]' .* UV_lpf);
      IR(6,:) = fir2(n, freqs, [T(1), T', T(end)]' .* UV_lpf);
      IR(7,:) = fir2(n, freqs, [U(1), U', U(end)]' .* UV_lpf);
      IR(8,:) = fir2(n, freqs, [V(1), V', V(end)]' .* UV_lpf);
    end
  end

  for b = (1:size(IR, 1))
    %%
    %% convert FIR filter to minimum phase filter
    %%
    %% https://ccrma.stanford.edu/~jos/filters/Conversion_Minimum_Phase.html
    %%
    MPS(b,:) = real(ifft(mps(fft(IR(b,:)))));
    %% we need to preserve the sign, the minimum phase transformation strips it
    sgn = sign(IR(b,round(n/2+1)));
    %%
    %% create a raised cosine window for the end of the IR
    %% to make sure IR decays to zero (last 8 samples of a 256 sample IR)
    end_window = tukeywin(2 * n, 0.025)(n+1:end);
    %% truncate to original size and window end
    FIR(b,:) = (MPS(b,:)')(1:n) .* end_window * sgn;
  end
end

