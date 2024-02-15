%%
%% *SpHEAR Project
%% sphear_fir_render: render impulse responses throught the FIR filter A2B matrix
%%
%% usage:
%%   [] = sphear_fir_render(FIR, fmin, fmax, N, Npre)
%%
%% FIR: A2B matrix of FIR filters
%% fmin, fmax: range of frequencies to use
%% N: number of samples to filter
%% Npre: number of samples before the main impulse peak
%% Fs: sampling rate
%% plt: plot response
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

function [bf Fs] = sphear_a_to_b_hf(m, A2B, N, Npre);
  capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);
  %% read in capsule signals and apply FIR filter
  for c = 1:4
    [cs(c,:) Fs] = wavread(["../data/current/af/a-format-0" sprintf("%02.0f", m) "-" char(capnames(c)) ".wav"]);
    if (c == 1)
      %% find highest peak location and define sample range
      [index, value] = findmaxpeak(cs(c,:)');
      r_start = index - Npre;
      r_end = r_start + N -1;
      range = r_start:r_end;
      printf("reference: peak %f at %d, sample range [%d %d], sampling rate: %d\n",
	     value, index, r_start, r_end, Fs);
    end
    cr(c,:) = cs(c,:)(range);
    for b = 1:4
      bs(c,b,:) = A2B(c,b) * cr(c,:);
    end
  end
  %% accumulate b format signals
  for b = 1:4
    bf(b,:) = bs(1,b,:) + bs(2,b,:) + bs(3,b,:) + bs(4,b,:);
  end
end
