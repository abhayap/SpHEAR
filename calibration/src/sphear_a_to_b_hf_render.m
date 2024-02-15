%%
%% *SpHEAR Project
%%
%% sphear_a_to_b_hf_render: render impulse responses throught one A2B matrix
%%
%% usage:
%%   [] = sphear_a_to_b_hf_render()
%%
%% optional parameters:
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

function [BFF] = sphear_a_to_b_hf_render(A2B, N, Npre)

  for m = 1:16
    %% render b format components
    [bf(m,:,:) srate] = sphear_a_to_b_hf(m, A2B, N, Npre);
    %% write soundfile with rendered B format signals
    %%
    %% if we write a 32 bit soundfile we need to scale by 256
    %% if we want the same amplitude as when writing a 16 bit
    %% per sample soundfile, otherwise we get nasty clipping
    wavwrite(reshape(bf(m,:,:),4,[])' / 256, srate, 32, ["../data/current/bf/b-format-" sprintf("%02.0f", m) ".wav"]);
  end

end

