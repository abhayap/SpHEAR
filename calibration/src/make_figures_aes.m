%%
%% Make all figures for the AES SFC 2016 Conference paper
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

function [FIR] = make_figures_aes(col)

  %% start from scratch and load common functions
  close all;
  clear all;
  sphear_common;

  global AESDIR = "../figures/";

  %% color figures
  cext = "_color";
  copt = "epsc";
  %% mono figures
  %% cext = "_mono";
  %% copt = "eps";
    
  %% frequency response with just A2B matrices
  [F FE Fs A2BF] = sphear_a2b_all((1:16), 300, 20000, 8, 256, 32);
  %% deliberately use nyquist to extend this to high frequencies
  FIR = sphear_fir_design(F, A2BF, 256, 20, Fs, 24000, copt);
  sphear_fir_render(FIR, 300, 20000, -45, 12, 256, 32, 8192, copt);
  close all;

  system(["cp -p figures/sphear_bf_azimuth_000" cext ".eps " AESDIR "sphear_bf_azimuth_000_a2b_all.eps"]);
  system(["cp -p figures/sphear_bf_azimuth_045" cext ".eps " AESDIR "sphear_bf_azimuth_045_a2b_all.eps"]);
  system(["cp -p figures/wxyz_filter_lf" cext ".eps " AESDIR "wxyz_filter_a2b_only.eps"]);

  %% frequency response with just the A2B matrices and limit frequency
  FIR = sphear_fir_design(F, A2BF, 256, 20, Fs, 4000, copt);
  sphear_fir_render(FIR, 300, 20000, -45, 12, 256, 32, 8192, copt);
  close all;

  system(["cp -p figures/sphear_bf_azimuth_000" cext ".eps " AESDIR "sphear_bf_azimuth_000_a2b.eps"]);
  system(["cp -p figures/sphear_bf_azimuth_045" cext ".eps " AESDIR "sphear_bf_azimuth_045_a2b.eps"]);
  system(["cp -p figures/wxyz_filter_lf" cext ".eps " AESDIR "wxyz_filter_lf_a2b.eps"]);

  %% and now design the full filter, on-axis averaging only
  FIR = sphear_fir_design(F, A2BF, 256, 20, Fs, 4000, 0);
  sphear_fir_render(FIR, 300, 20000, -45, 0, 256, 32, 8192, 0);
  [B] = sphear_a2b_fir_all(300, 20000, 8, 8192, 48000, 0);
  [W X Y Z] = sphear_fir_extract(B, 0, 1);
  FIR = sphear_fir_design(F, A2BF, 256, 20, Fs, 4000, copt, W, X, Y);
  sphear_fir_render(FIR, 300, 20000, -45, 0, 256, 32, 8192, copt);
  sphear_fir_render_directions(FIR, 3000, 20000, 256, 32, 4096, copt);
  [B] = sphear_a2b_fir_all(300, 20000, 8, 8192, 48000, 1);
  close all;

  %% recovered cardioid versus frequency
  sphear_cardioid_plot_all([500, 2000, 5000, 7000, 10000, 14000], 300, 20000, 8, 8192, 48000, "epsc");
  
  system(["cp -p figures/sphear_bf_azimuth_000" cext ".eps " AESDIR "sphear_bf_azimuth_000.eps"]);
  system(["cp -p figures/sphear_bf_azimuth_045" cext ".eps " AESDIR "sphear_bf_azimuth_045.eps"]);
  system(["cp -p figures/wxyz_filter_ff" cext ".eps " AESDIR "wxyz_filter_ff.eps"]);
  system(["cp -p figures/sphear_directions.eps " AESDIR "sphear_directions_onaxis.eps"]);
  system(["cp -p figures/sphear_polar_multi_00604_00659_color.eps " AESDIR "sphear_polar_multi_600.eps"]);
  system(["cp -p figures/sphear_polar_multi_01216_01327_color.eps " AESDIR "sphear_polar_multi_1200.eps"]);
  system(["cp -p figures/sphear_polar_multi_05383_05875_color.eps " AESDIR "sphear_polar_multi_5000.eps"]);
  system(["cp -p figures/sphear_polar_multi_10840_11831_color.eps " AESDIR "sphear_polar_multi_10000.eps"]);
  system(["cp -p figures/sphear_cardioid_polar.eps " AESDIR "sphear_cardioid_polar.eps"]);

  %% and again with all angles averaging
  FIR = sphear_fir_design(F, A2BF, 256, 20, Fs, 4000, 0);
  sphear_fir_render(FIR, 300, 20000, -45, 0, 256, 32, 8192, 0);
  [B] = sphear_a2b_fir_all(300, 20000, 8, 8192, 48000, 0);
  [W X Y Z] = sphear_fir_extract(B, 1, 1);
  FIR = sphear_fir_design(F, A2BF, 256, 20, Fs, 4000, copt, W, X, Y);
  sphear_fir_render(FIR, 300, 20000, -45, 0, 256, 32, 8192, copt);
  sphear_fir_render_directions(FIR, 3000, 20000, 256, 32, 4096, copt);
  close all;

  system(["cp -p figures/sphear_bf_azimuth_000" cext ".eps " AESDIR "sphear_bf_azimuth_000_all.eps"]);
  system(["cp -p figures/sphear_bf_azimuth_045" cext ".eps " AESDIR "sphear_bf_azimuth_045_all.eps"]);
  system(["cp -p figures/wxyz_filter_ff" cext ".eps " AESDIR "wxyz_filter_ff_all.eps"]);
  system(["cp -p figures/sphear_directions.eps " AESDIR "sphear_directions_all.eps"]);
  
end
