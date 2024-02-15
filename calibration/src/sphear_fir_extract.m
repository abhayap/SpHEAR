%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_fir_extract: extract W and XYZ filter shapes from B format response
%%
%% usage:
%%   [] = sphear_fir_extract()
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

function [W X Y Z] = sphear_fir_extract(B, all, cardinal);
  %% select which measurements to average
  if (all == 1)
    m = (1:16);
  else
    if (cardinal == 1)
      m = [1, 5, 9, 13];
    else
      m = [3, 7, 11, 15];
    end
  end
  
  %% extract average response shape for W
  W = 1.0 ./ reshape(mean(B(m,1,:)), size(B(:,:,:))(3), 1);
  %% extract average response shape for XYZ
  X = 1.0 ./ reshape(mean(B(m,2,:)), size(B(:,:,:))(3), 1);
  Y = 1.0 ./ reshape(mean(B(m,3,:)), size(B(:,:,:))(3), 1);
  Z = 1.0 ./ reshape(mean(B(m,4,:)), size(B(:,:,:))(3), 1);
end
