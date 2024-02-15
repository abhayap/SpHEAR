%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_design_fir_filters: design 8x8 matrix of FIR filters
%%
%% usage:
%%   [FIR IR MPS] = sphear_design_fir_filter_matrix(F, n, SR, SHAPE)
%%
%% F: array of filter section center frequencies
%% n: order of the FIR filter being created
%% SR: sampling rate
%%
%% SHAPE: extracted shape of the capsule filter
%%
%% FIR: array of minimum phase FIR filters
%% IR: calculated FIR filters
%% MPS: output of mps without windowing (minimum phase)
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

%% NOTES: using fir2 for now, firls calculates non-smooth filters with worse
%% frequency response, remez does not converge in my tests

function [FIR IR MPS] = sphear_design_fir_filter_matrix(F, n, SR, SHAPE)
  %% make a 0 to 1 vector of relative frequencies
  freqs = [0, (F/(SR/2))', 1]';
  %% design the filters
  for a = (1:size(SHAPE, 2))
    for b = (1:size(SHAPE, 3))
      IR(:,a,b) = fir2(n, freqs, [SHAPE(1,a,b), SHAPE(:,a,b)', SHAPE(end,a,b)]);
      %% we need to preserve the sign, the minimum phase transformation strips it
      sgn = sign(IR(round(n/2+1),a,b));
      %%
      %% convert FIR filter to minimum phase filter
      %%
      %% https://ccrma.stanford.edu/~jos/filters/Conversion_Minimum_Phase.html
      %%
      MPS(:,a,b) = real(ifft(mps(fft(IR(:,a,b)))));
      %%
      %% create a raised cosine window for the end of the IR
      %% to make sure IR decays to zero (last 8 samples of a 256 sample IR)
      end_window = tukeywin(2 * n, 0.025)(n+1:end);
      %% truncate to original size and window end
      FIR(:,a,b) = (MPS(:,a,b))(1:n) .* end_window * sgn;
    end
  end
end

