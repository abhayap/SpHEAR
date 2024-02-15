%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% Design a second order A2B encoder for the Octathingy
%%
%% Eight capsule equalization filters, static A to B matrix
%% and eight filters for the B-format components
%%
%% Copyright 2016-2019, Fernando Lopez-Lezcano, All Rights Reserved
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

pkg load plot;

sphear_calibration_common;
more off;

%% first calibrate all measurements
%% octathingy #1
sphear_af_calibrate_measurements("../data/2018.06.29/octathingy_01/3d/", 0.0045);

sphear_af_calibrate_measurements("../data/2018.06.29/octathingy_01/2d/", 0.0045);

%% octa#3
sphear_af_calibrate_measurements("../data/2018.08.16/octathingy_03/2d/", 0.0045);
sphear_af_calibrate_measurements("../data/2018.08.16/octathingy_03/3d/", 0.0045);


%% now we can read the A format signals into Octave, the function returns
%% an array with all the IRs and the azimuth and elevation of each measurement,
%% it also defines the sampling rate at which the measurements were sampled

%% octathingy #1
[AF1, AZ1, EL1, FS] = sphear_af_read_calibrated("../data/2018.06.29/octathingy_01/3d/");
[AFH1, AZH1, ELH1, FS] = sphear_af_read_calibrated("../data/2018.06.29/octathingy_01/2d/");

%% octathingy #2
[AF2, AZ2, EL2, FS] = sphear_af_read_calibrated("../data/2018.06.29/octathingy_02/3d/");
[AFH2, AZH2, ELH2, FS] = sphear_af_read_calibrated("../data/2018.06.29/octathingy_02/2d/");

%% octathingy #3
[AF3, AZ3, EL3, FS] = sphear_af_read_calibrated("../data/2018.06.29/octathingy_03/3d/");
[AFH3, AZH3, ELH3, FS] = sphear_af_read_calibrated("../data/2018.06.29/octathingy_03/2d/");

[AF3, AZ3, EL3, FS] = sphear_af_read_calibrated("../data/2018.08.16/octathingy_03/3d/");
[AFH3, AZH3, ELH3, FS] = sphear_af_read_calibrated("../data/2018.08.16/octathingy_03/2d/");

%% check that capsule signals are reasonable for horizontal measurements
%%
%% calculate signal power in a reference frequency range for all
%% measurements and capsules (horizontal only)
%% octa#1
[RH1] = sphear_signal_power(AFH1, FS, 800, 2000, 8192);
%% octa#2
[RH2] = sphear_signal_power(AFH2, FS, 800, 2000, 8192);
%% octa#3
[RH3] = sphear_signal_power(AFH3, FS, 800, 2000, 8192);

%% check that the capsule signals are reasonable
%%
%% we do not have equally spaced full 3d measurements, so we need to check this with
%% the set of horizontal only measurements
sphear_plot_r(RH1, 0);
%% octa#2
sphear_plot_r(RH2, 0);
%% octa#3
sphear_plot_r(RH3, 0);

%% just for checking the data, this plots the frequency response of each
%% measurement for each capsule.
%% octa#1
sphear_capsule_plot_frequency_response(AFH1, [1:16], 300, 20000, -50, -6, 48000, 8192);
sphear_af_plot_frequency_response(AFH1, 300, 20000, -60, -10, 48000, 8192);

%% octa#2
sphear_capsule_plot_frequency_response(AFH2, [1:16], 300, 20000, -50, -6, 48000, 8192);
sphear_af_plot_frequency_response(AFH2, 300, 20000, -60, -10, 48000, 8192);

%% octa#3
sphear_capsule_plot_frequency_response(AFH3, [1:16], 300, 20000, -50, -6, 48000, 8192);
sphear_af_plot_frequency_response(AFH3, 300, 20000, -60, -10, 48000, 8192);

%% azimuth and elevation angles of all capsules (octathingy), degrees
elev_angle = 35.2644;
capsule_angles = ...
[[22.5, elev_angle],       % C1
 [-22.5, -elev_angle],     % C2
 [22.5-90, elev_angle],    % C3
 [-22.5-90, -elev_angle],  % C4
 [22.5-180, elev_angle],   % C5
 [-22.5-180, -elev_angle], % C6
 [22.5-270, elev_angle],   % C7
 [-22.5-270, -elev_angle]  % C8
] / 180 * pi;              % in radians...

%% STEP #1
%%
%% define reference frequencies where capsules are co-located
fref_min = 800;
fref_max = 1600;

%% derive capsule calibration filters from horizontal only measurements
%%
%% we calibrate for the horizontal plane so that all capsules
%% try to reconstruct horizontal signals that the best

%% octa#1 power for full 3d signals
[AP1, FC, FE] = sphear_signal_power_all(AF1, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa#1 power for horizontal signals
[APH1, FC, FE] = sphear_signal_power_all(AFH1, FS, 300, 20000, fref_min, fref_max, 16, 8192);

%% octa#2 power for full 3d signals
[AP2, FC, FE] = sphear_signal_power_all(AF2, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa#2 power for horizontal signals
[APH2, FC, FE] = sphear_signal_power_all(AFH2, FS, 300, 20000, fref_min, fref_max, 16, 8192);

%% octa#3 power for full 3d signals
[AP3, FC, FE] = sphear_signal_power_all(AF3, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa# power for horizontal signals
[APH3, FC, FE] = sphear_signal_power_all(AFH3, FS, 300, 20000, fref_min, fref_max, 16, 8192);

%% inverse filters based on the horizontal plane measurements
%%
%% we should probably add regularization at the high end
%%%% TODO: normalize filter with respect to reference frequency %%%%
%% octa#1
[FSHAPESH1 PSHAPESH1] = sphear_find_capsule_filter_shapes(APH1, AZH1, ELH1, capsule_angles, 3, 0);
sphear_capsule_plot_filters(FC, FSHAPESH1);

%% octa#2
[FSHAPESH2 PSHAPESH2] = sphear_find_capsule_filter_shapes(APH2, AZH2, ELH2, capsule_angles, 3, 0);
sphear_capsule_plot_filters(FC, FSHAPESH2);

%% octa#3
[FSHAPESH3 PSHAPESH3] = sphear_find_capsule_filter_shapes(APH3, AZH3, ELH3, capsule_angles, 3, 0);
sphear_capsule_plot_filters(FC, FSHAPESH3);

%% design minimum phase FIR capsule equalization filters
%%
fir_length = 512;
fir_length = 256;

%% octa#1
[CFIRH1 CIR MPS] = sphear_design_capsule_fir_filters(FC, fir_length, 48000, FSHAPESH1);
%% octa#2
[CFIRH2 CIR MPS] = sphear_design_capsule_fir_filters(FC, fir_length, 48000, FSHAPESH2);
%% octa#3
[CFIRH3 CIR MPS] = sphear_design_capsule_fir_filters(FC, fir_length, 48000, FSHAPESH3);

%% filter all a-format signals with capsule equalization filters
%%
%% octa#1, horizontal signal with horizontal filters
[AFHF1] = sphear_filter_capsule_signals(AFH1, CFIRH1, 8192);
%% octa#1, 3d signals with horizontal filters
[AFF1] = sphear_filter_capsule_signals(AF1, CFIRH1, 8192);

%% octa#2, horizontal signal with horizontal filters
[AFHF2] = sphear_filter_capsule_signals(AFH2, CFIRH2, 8192);
%% octa#2, 3d signals with horizontal filters
[AFF2] = sphear_filter_capsule_signals(AF2, CFIRH2, 8192);

%% octa#3, horizontal signal with horizontal filters
[AFHF3] = sphear_filter_capsule_signals(AFH3, CFIRH3, 8192);
%% octa#1, 3d signals with horizontal filters
[AFF3] = sphear_filter_capsule_signals(AF3, CFIRH3, 8192);

%% capsule signals after equalization
%% octa#3
sphear_capsule_plot_frequency_response(AFHF3, [1:16], 300, 20000, -50, -15, 48000, 8192);
sphear_af_plot_frequency_response(AFH3, 300, 20000, -60, -10, 48000, 8192);


%% calculate projection matrix
%%
%% octa#1, 3d
[M1 x y z s t u v] = sphear_az_el_to_X_matrix(AZ1, EL1, 2);
%% octa#1, horizontal
[MH1 x y z s t u v] = sphear_az_el_to_X_matrix(AZH1, ELH1, 2);

%% octa#2, 3d
[M2 x y z s t u v] = sphear_az_el_to_X_matrix(AZ2, EL2, 2);
%% octa#2, horizontal
[MH2 x y z s t u v] = sphear_az_el_to_X_matrix(AZH2, ELH2, 2);

%% octa#3, 3d
[M3 x y z s t u v] = sphear_az_el_to_X_matrix(AZ3, EL3, 2);
%% octa#3, horizontal
[MH3 x y z s t u v] = sphear_az_el_to_X_matrix(AZH3, ELH3, 2);

%% calculate horizontal signal power in reference band
%% octa#1
[RH1] = sphear_signal_power(AFHF1, FS, fref_min, fref_max, 8192);
%% octa#2
[RH2] = sphear_signal_power(AFHF2, FS, fref_min, fref_max, 8192);
%% octa#3
[RH3] = sphear_signal_power(AFHF3, FS, fref_min, fref_max, 8192);

%% calculate static A to B matrix for horizontal calibration signals
%% octa#1
[A2BH1, PVH1, CONDH] = sphear_calculate_a2b(RH1, MH1);
%% octa#2
[A2BH2, PVH2, CONDH] = sphear_calculate_a2b(RH2, MH2);
%% octa#3
[A2BH3, PVH3, CONDH] = sphear_calculate_a2b(RH3, MH3);

%% generate b-format signal from calibrated a-format signal and static matrix
%% octa#1
[BFH1] = sphear_af_to_bf(AFHF1, A2BH1);
%% octa#2
[BFH2] = sphear_af_to_bf(AFHF2, A2BH2);
%% octa#3
[BFH3] = sphear_af_to_bf(AFHF3, A2BH3);

%% plot frequency response of b-format signal (only W/X/Y/U/V)
%% octa#1
sphear_bf_plot_frequency_response(BFH1(:,[1,2,3,7,8],:), AZH1, ELH1, fref_min, fref_max, 300, 20000, -35, 9, 48000, 8192);
%% octa#2
sphear_bf_plot_frequency_response(BFH2(:,[1,2,3,7,8],:), AZH2, ELH2, fref_min, fref_max, 300, 20000, -35, 9, 48000, 8192);
%% octa#3
sphear_bf_plot_frequency_response(BFH3(:,[1,2,3,7,8],:), AZH3, ELH3, fref_min, fref_max, 300, 20000, -35, 9, 48000, 8192);

%% calculate power of b-format signals in logarithmically spaced bands
%% octa#1
[BH1, FC, FE] = sphear_signal_power_all(BFH1, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa#2
[BH2, FC, FE] = sphear_signal_power_all(BFH2, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa#3
[BH3, FC, FE] = sphear_signal_power_all(BFH3, FS, 300, 20000, fref_min, fref_max, 16, 8192);

%% extract b-format equalizationb filter shapes for all components
W1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 1, -0.5, [1,5,9,13]+2);
X1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 2, -0.5);
Y1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 3, -0.5);
Z1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 4, -0.5);
S1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 5, -0.5);
T1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 6, -0.5);
U1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 7, -0.5);
V1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 8, -0.5);
%% with averaging above aliasing frequency band
U1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 7, -0.3, [], [8000, 12000]);
V1 = sphear_bf_extract_filter_shape(FC, MH1, BH1, 8, -0.3, [], [8000, 12000]);

%% plot b-format equalization filters (ommit Z/S/T)
sphear_bf_plot_filters(FC, W1, X1, Y1, [], [], [], U1, V1);

%% extract b-format equalizationb filter shapes for all components
W2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 1, -0.5, [1,5,9,13]+2);
X2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 2, -0.5);
Y2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 3, -0.5);
Z2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 4, -0.5);
S2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 5, -0.5);
T2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 6, -0.5);
U2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 7, -0.5);
V2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 8, -0.5);
%% with averaging above aliasing frequency band
U2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 7, -0.3, [], [8000, 12000]);
V2 = sphear_bf_extract_filter_shape(FC, MH2, BH2, 8, -0.3, [], [8000, 12000]);

%% plot b-format equalization filters (ommit Z/S/T)
sphear_bf_plot_filters(FC, W2, X2, Y2, [], [], [], U2, V2);

%% extract b-format equalizationb filter shapes for all components
W3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 1, -0.5, [1,5,9,13]+2);
X3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 2, -0.5);
Y3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 3, -0.5);
Z3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 4, -0.5);
S3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 5, -0.5);
T3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 6, -0.5);
U3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 7, -0.5);
V3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 8, -0.5);
%% with averaging above aliasing frequency band
U3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 7, -0.3, [], [8000, 12000]);
V3 = sphear_bf_extract_filter_shape(FC, MH3, BH3, 8, -0.3, [], [8000, 12000]);

%% plot b-format equalization filters (ommit Z/S/T)
sphear_bf_plot_filters(FC, W3, X3, Y3, [], [], [], U3, V3);

%% design the minimum phase FIR b-format equalization filters
%% octa#1
%% [FIRH1 IR MPS] = sphear_design_fir_filters(FC, 512, 48000, W1, X1, Y1, Z1, S1, T1, U1, V1, 0, 18, -10);
[FIRH1 IR MPS] = sphear_design_fir_filters(FC, fir_length, 48000, W1, X1, Y1, Z1, S1, T1, U1, V1, 400, 18, -10);
%% octa#2
%% [FIRH2 IR MPS] = sphear_design_fir_filters(FC, 512, 48000, W2, X2, Y2, Z2, S2, T2, U2, V2, 0, 18, -10);
[FIRH2 IR MPS] = sphear_design_fir_filters(FC, fir_length, 48000, W2, X2, Y2, Z2, S2, T2, U2, V2, 400, 18, -10);
%% octa#3
%% [FIRH3 IR MPS] = sphear_design_fir_filters(FC, 512, 48000, W3, X3, Y3, Z3, S3, T3, U3, V3, 0, 18, -10);
[FIRH3 IR MPS] = sphear_design_fir_filters(FC, fir_length, 48000, W3, X3, Y3, Z3, S3, T3, U3, V3, 400, 18, -10);

%% render the b-format signal using the static matrix and b-format equalization filters
%% octa#1
[BFH1, BFFH1] = sphear_af_to_bf(AFHF1, A2BH1, FIRH1, 8192);
%% octa#2
[BFH2, BFFH2] = sphear_af_to_bf(AFHF2, A2BH2, FIRH2, 8192);
%% octa#3
[BFH3, BFFH3] = sphear_af_to_bf(AFHF3, A2BH3, FIRH3, 8192);

%% TODO %% normalize matrix for proper gain

%% plot the frequency response of equalized b-format signals
%% octa#1
sphear_bf_plot_frequency_response(BFFH1(:,[1,2,3,7,8],:), AZH1, ELH1, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#2
sphear_bf_plot_frequency_response(BFFH2(:,[1,2,3,7,8],:), AZH2, ELH2, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#3
sphear_bf_plot_frequency_response(BFFH3(:,[1,2,3,7,8],:), AZH3, ELH3, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%%%%
%%%% STEP #2
%%%%
%%%%
%%%% calculate the remaining harmonics (Z/S/T) using the full 3d measurement set
%%%%

%% filter full 3d measurements with horizontal equalization filters
%% octa#1, 3d
[AFF1] = sphear_filter_capsule_signals(AF1, CFIRH1, 8192);
%% octa#2, 3d
[AFF2] = sphear_filter_capsule_signals(AF2, CFIRH2, 8192);
%% octa#3, 3d
[AFF3] = sphear_filter_capsule_signals(AF3, CFIRH3, 8192);

%% calculate projections matrix from measurement directions
%% octa#1
[M1 x y z s t u v] = sphear_az_el_to_X_matrix(AZ1, EL1, 2);
%% octa#2
[M2 x y z s t u v] = sphear_az_el_to_X_matrix(AZ2, EL2, 2);
%% octa#3
[M3 x y z s t u v] = sphear_az_el_to_X_matrix(AZ3, EL3, 2);

%% measure signal power in reference frequency band
%% octa#1
[R1] = sphear_signal_power(AFF1, FS, fref_min, fref_max, 8192);
%% octa#2
[R2] = sphear_signal_power(AFF2, FS, fref_min, fref_max, 8192);
%% octa#3
[R3] = sphear_signal_power(AFF3, FS, fref_min, fref_max, 8192);

%% calculate static A to B matrix for full 3d measurements
%% octa#1
[A2B1, PV1, COND] = sphear_calculate_a2b(R1, M1);
%% octa#2
[A2B2, PV2, COND] = sphear_calculate_a2b(R2, M2);
%% octa#3
[A2B3, PV3, COND] = sphear_calculate_a2b(R3, M3);

%% convert a-format to b-format using static matrix only
%% octa#1
[BF1] = sphear_af_to_bf(AFF1, A2B1);
%% octa#2
[BF2] = sphear_af_to_bf(AFF2, A2B2);
%% octa#3
[BF3] = sphear_af_to_bf(AFF3, A2B3);

%% calculate power of b format signal in reference frequency band
%% octa#1
[B1, FC, FE] = sphear_signal_power_all(BF1, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa#2
[B2, FC, FE] = sphear_signal_power_all(BF2, FS, 300, 20000, fref_min, fref_max, 16, 8192);
%% octa#3
[B3, FC, FE] = sphear_signal_power_all(BF3, FS, 300, 20000, fref_min, fref_max, 16, 8192);

%% extract filter shapes of full 3d b-format signals
%% octa#1
WF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 1, -0.5, [1,5,9,13]+2);
XF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 2, -0.3);
YF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 3, -0.3);
ZF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 4, -2.5);
SF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 5, -0.5);
TF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 6, -0.5);
UF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 7, -0.3);
VF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 8, -0.3);
%% add a 10KHz spatial aliasing cutover
SF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 5, -0.5, [], [8000, 12000]);
TF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 6, -0.5, [], [8000, 12000]);
UF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 7, -0.3, [], [8000, 12000]);
VF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 8, -0.3, [], [8000, 12000]);
%% ha, the Z component is getting a spike because of the difference in
%% response of the capsule versus the equalization filter it has
%% so hack it and smooth it out...
ZF1 = sphear_bf_extract_filter_shape(FC, M1, B1, 4, -2.5, [], [10000, 12500]);

%% plot the filter shapes
%% octa#1
sphear_bf_plot_filters(FC, WF1, XF1, YF1, ZF1, SF1, TF1, UF1, VF1);

%% extract filter shapes of full 3d b-format signals
%% octa#2
WF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 1, -0.5, [1,5,9,13]+2);
XF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 2, -0.3);
YF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 3, -0.3);
ZF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 4, -2.5);
SF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 5, -0.5);
TF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 6, -0.5);
UF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 7, -0.3);
VF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 8, -0.3);
%% add a 10KHz spatial aliasing cutover
SF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 5, -0.5, [], [8000, 12000]);
TF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 6, -0.5, [], [8000, 12000]);
UF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 7, -0.3, [], [8000, 12000]);
VF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 8, -0.3, [], [8000, 12000]);
%% ha, the Z component is getting a spike because of the difference in
%% response of the capsule versus the equalization filter it has
%% so hack it and smooth it out...
ZF2 = sphear_bf_extract_filter_shape(FC, M2, B2, 4, -2.5, [], [10000, 12500]);

%% plot the filter shapes
%% octa#2
sphear_bf_plot_filters(FC, WF2, XF2, YF2, ZF2, SF2, TF2, UF2, VF2);

%% extract filter shapes of full 3d b-format signals
%% octa#3
WF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 1, -0.5, [1,5,9,13]+2);
XF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 2, -0.3);
YF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 3, -0.3);
ZF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 4, -2.5);
SF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 5, -0.5);
TF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 6, -0.5);
UF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 7, -0.3);
VF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 8, -0.3);
%% add a 10KHz spatial aliasing cutover
SF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 5, -0.5, [], [8000, 12000]);
TF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 6, -0.5, [], [8000, 12000]);
UF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 7, -0.3, [], [8000, 12000]);
VF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 8, -0.3, [], [8000, 12000]);
%% ha, the Z component is getting a spike because of the difference in
%% response of the capsule versus the equalization filter it has
%% so hack it and smooth it out...
ZF3 = sphear_bf_extract_filter_shape(FC, M3, B3, 4, -2.5, [], [10000, 12500]);

%% plot the filter shapes
%% octa#3
sphear_bf_plot_filters(FC, WF3, XF3, YF3, ZF3, SF3, TF3, UF3, VF3);

%% the hybrid filters
%% octa#1
sphear_bf_plot_filters(FC, W1, X1, Y1, ZF1, SF1, TF1, U1, V1);
%% octa#2
sphear_bf_plot_filters(FC, W2, X2, Y2, ZF2, SF2, TF2, U2, V2);
%% octa#3
sphear_bf_plot_filters(FC, W3, X3, Y3, ZF3, SF3, TF3, U3, V3);

%% design the minimum phase FIR filters
%% octa#1
[FIR1 IR MPS] = sphear_design_fir_filters(FC, fir_length, 48000, WF1, XF1, YF1, ZF1, SF1, TF1, UF1, VF1, 400, 18, -10);
%% octa#2
[FIR2 IR MPS] = sphear_design_fir_filters(FC, fir_length, 48000, WF2, XF2, YF2, ZF2, SF2, TF2, UF2, VF2, 400, 18, -10);
%% octa#3
[FIR3 IR MPS] = sphear_design_fir_filters(FC, fir_length, 48000, WF3, XF3, YF3, ZF3, SF3, TF3, UF3, VF3, 400, 18, -10);

%% combine static matrix for horizontal and full sphere components
%% octa#1
%% WXY
A2BC1(:,[1,2,3]) = A2BH1(:,[1,2,3]);
%% ZST
A2BC1(:,[4,5,6]) = A2B1(:,[4,5,6]);
%% UV
A2BC1(:,[7,8]) = A2BH1(:,[7,8]);

%% combine FIR filters for horizontal and full sphere components
%% octa#1
%% WXY
FIRC1([1,2,3],:) = FIRH1([1,2,3],:);
%% ZST
FIRC1([4,5,6],:) = FIR1([4,5,6],:);
%% UV
FIRC1([7,8],:) = FIRH1([7,8],:);

%% combine static matrix for horizontal and full sphere components
%% octa#2
%% WXY
A2BC2(:,[1,2,3]) = A2BH2(:,[1,2,3]);
%% ZST
A2BC2(:,[4,5,6]) = A2B2(:,[4,5,6]);
%% UV
A2BC2(:,[7,8]) = A2BH2(:,[7,8]);

%% combine FIR filters for horizontal and full sphere components
%% octa#2
%% WXY
FIRC2([1,2,3],:) = FIRH2([1,2,3],:);
%% ZST
FIRC2([4,5,6],:) = FIR2([4,5,6],:);
%% UV
FIRC2([7,8],:) = FIRH2([7,8],:);

%% combine static matrix for horizontal and full sphere components
%% octa#3
%% WXY
A2BC3(:,[1,2,3]) = A2BH3(:,[1,2,3]);
%% ZST
A2BC3(:,[4,5,6]) = A2B3(:,[4,5,6]);
%% UV
A2BC3(:,[7,8]) = A2BH3(:,[7,8]);

%% combine FIR filters for horizontal and full sphere components
%% octa#3
%% WXY
FIRC3([1,2,3],:) = FIRH3([1,2,3],:);
%% ZST
FIRC3([4,5,6],:) = FIR3([4,5,6],:);
%% UV
FIRC3([7,8],:) = FIRH3([7,8],:);

%% render a-format signals to b-format through the static matrix and b-format filters
%% octa#1
%% full 3d set
[BFC1, BFFC1] = sphear_af_to_bf(AFF1, A2BC1, FIRC1, 8192);
%% horizontal only
[BFH1, BFFH1] = sphear_af_to_bf(AFHF1, A2BC1, FIRC1, 8192);
%% octa#2
%% full 3d set
[BFC2, BFFC2] = sphear_af_to_bf(AFF2, A2BC2, FIRC2, 8192);
%% horizontal only
[BFH2, BFFH2] = sphear_af_to_bf(AFHF2, A2BC2, FIRC2, 8192);
%% octa#3
%% full 3d set
[BFC3, BFFC3] = sphear_af_to_bf(AFF3, A2BC3, FIRC3, 8192);
%% horizontal only
[BFH3, BFFH3] = sphear_af_to_bf(AFHF3, A2BC3, FIRC3, 8192);

%%%%
%% render a-format signals to b-format through the matrix and filters derived from the 3d signals
%% octa#3
%% full 3d set
[BFC3, BFFC3] = sphear_af_to_bf(AFF3, A2B3, FIR3, 8192);
%% horizontal only
[BFH3, BFFH3] = sphear_af_to_bf(AFHF3, A2B3, FIR3, 8192);
%%%%

%% find normalization coefficients for spherical harmonics
%% octa#1
%% calculate power of B format signal in frequency range of interest
%% full 3d
[BPC1] = sphear_signal_power(BFFC1, FS, fref_min, fref_max, 8192);
%% and get coefficients
WN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 1, -0.2, [1,5,9,13]+3);
XN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 2, -0.2);
YN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 3, -0.2);
ZN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 4, -2.5);
SN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 5, -0.5);
TN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 6, -0.5);
UN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 7, -0.2);
VN1 = sphear_bf_normalization_factor(FC, M1, BPC1, 8, -0.2);

%% now scale the matrix...
A2BC1(:,2) = A2BC1(:,2) * (XN1/WN1);
A2BC1(:,3) = A2BC1(:,3) * (YN1/WN1);
A2BC1(:,4) = A2BC1(:,4) * (ZN1/WN1);
A2BC1(:,5) = A2BC1(:,5) * (SN1/WN1);
A2BC1(:,6) = A2BC1(:,6) * (TN1/WN1);
A2BC1(:,7) = A2BC1(:,7) * (UN1/WN1);
A2BC1(:,8) = A2BC1(:,8) * (VN1/WN1);

%% octa#2
%% calculate power of B format signal in frequency range of interest
%% full 3d
[BPC2] = sphear_signal_power(BFFC2, FS, fref_min, fref_max, 8192);
%% and get coefficients
WN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 1, -0.2, [1,5,9,13]+3);
XN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 2, -0.2);
YN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 3, -0.2);
ZN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 4, -2.5);
SN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 5, -0.5);
TN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 6, -0.5);
UN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 7, -0.2);
VN2 = sphear_bf_normalization_factor(FC, M2, BPC2, 8, -0.2);

%% now scale the matrix...
A2BC2(:,2) = A2BC2(:,2) * (XN2/WN2);
A2BC2(:,3) = A2BC2(:,3) * (YN2/WN2);
A2BC2(:,4) = A2BC2(:,4) * (ZN2/WN2);
A2BC2(:,5) = A2BC2(:,5) * (SN2/WN2);
A2BC2(:,6) = A2BC2(:,6) * (TN2/WN2);
A2BC2(:,7) = A2BC2(:,7) * (UN2/WN2);
A2BC2(:,8) = A2BC2(:,8) * (VN2/WN2);

%% octa#3
%% calculate power of B format signal in frequency range of interest
%% full 3d
[BPC3] = sphear_signal_power(BFFC3, FS, fref_min, fref_max, 8192);
%% and get coefficients
WN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 1, -0.2, [1,5,9,13]+3);
XN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 2, -0.2);
YN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 3, -0.2);
ZN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 4, -2.5);
SN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 5, -0.5);
TN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 6, -0.5);
UN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 7, -0.2);
VN3 = sphear_bf_normalization_factor(FC, M3, BPC3, 8, -0.2);

%% now scale the matrix...
A2BC3(:,2) = A2BC3(:,2) * (XN3/WN3);
A2BC3(:,3) = A2BC3(:,3) * (YN3/WN3);
A2BC3(:,4) = A2BC3(:,4) * (ZN3/WN3);
A2BC3(:,5) = A2BC3(:,5) * (SN3/WN3);
A2BC3(:,6) = A2BC3(:,6) * (TN3/WN3);
A2BC3(:,7) = A2BC3(:,7) * (UN3/WN3);
A2BC3(:,8) = A2BC3(:,8) * (VN3/WN3);

%% re-render the b-format signals with new scaled matrix and filters
%% octa#1
%% full 3d set
[BFC1, BFFC1] = sphear_af_to_bf(AFF1, A2BC1, FIRC1, 8192);
%% horizontal only
[BFH1, BFFH1] = sphear_af_to_bf(AFHF1, A2BC1, FIRC1, 8192);
%% octa#2
%% full 3d set
[BFC2, BFFC2] = sphear_af_to_bf(AFF2, A2BC2, FIRC2, 8192);
%% horizontal only
[BFH2, BFFH2] = sphear_af_to_bf(AFHF2, A2BC2, FIRC2, 8192);
%% octa#3
%% full 3d set
[BFC3, BFFC3] = sphear_af_to_bf(AFF3, A2BC3, FIRC3, 8192);
%% horizontal only
[BFH3, BFFH3] = sphear_af_to_bf(AFHF3, A2BC3, FIRC3, 8192);

%% plot frequency response of b-format signals
%% octa#1
sphear_bf_plot_frequency_response(BFFH1, AZH1, ELH1, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#2
sphear_bf_plot_frequency_response(BFFH2, AZH2, ELH2, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#3
sphear_bf_plot_frequency_response(BFFH3, AZH3, ELH3, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%%
%% some plots selecting ranges in the full 3d measurement signals

%% front over full elevation range
%% octa#1
[BFFC1f, M1f, AZ1f, EL1f] = sphear_select_azimuth_elevation_range(BFFC1, M1, AZ1, EL1, -12, 12, -90, 90);
sphear_bf_plot_frequency_response(BFFC1f, AZ1f, EL1f, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#2
[BFFC2f, M2f, AZ2f, EL2f] = sphear_select_azimuth_elevation_range(BFFC2, M2, AZ2, EL2, -12, 12, -90, 90);
sphear_bf_plot_frequency_response(BFFC2f, AZ2f, EL2f, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#3
[BFFC3f, M3f, AZ3f, EL3f] = sphear_select_azimuth_elevation_range(BFFC3, M3, AZ3, EL3, -12, 12, -90, 90);
sphear_bf_plot_frequency_response(BFFC3f, AZ3f, EL3f, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%% full azimuth close to the horizontal plane
%% octa#1
[BFFC1h, M1h, AZ1h, EL1h] = sphear_select_azimuth_elevation_range(BFFC1, M1, AZ1, EL1, -180, 180, -10, 10);
sphear_bf_plot_frequency_response(BFFC1h, AZ1h, EL1h, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#2
[BFFC2h, M2h, AZ2h, EL2h] = sphear_select_azimuth_elevation_range(BFFC2, M2, AZ2, EL2, -180, 180, -10, 10);
sphear_bf_plot_frequency_response(BFFC1h, AZ1h, EL1h, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#3
[BFFC3h, M3h, AZ3h, EL3h] = sphear_select_azimuth_elevation_range(BFFC3, M3, AZ3, EL3, -180, 180, -10, 10);
sphear_bf_plot_frequency_response(BFFC3h, AZ3h, EL3h, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%% full azimuth, between 25 and 35 degrees elevation
%octa#1
[BFFC1u, M1u, AZ1u, EL1u] = sphear_select_azimuth_elevation_range(BFFC1, M1, AZ1, EL1, -180, 180, 25, 35);
sphear_bf_plot_frequency_response(BFFC1u, AZ1u, EL1u, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%octa#2
[BFFC2u, M2u, AZ2u, EL2u] = sphear_select_azimuth_elevation_range(BFFC2, M2, AZ2, EL2, -180, 180, 25, 35);
sphear_bf_plot_frequency_response(BFFC1u, AZ1u, EL1u, fref_min, fref_max, 300, 20000, -30, 9, 48000, 8192);
%octa#3
[BFFC3u, M3u, AZ3u, EL3u] = sphear_select_azimuth_elevation_range(BFFC3, M3, AZ3, EL3, -180, 180, 25, 35);
sphear_bf_plot_frequency_response(BFFC3u, AZ3u, EL3u, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%% full azimuth, above 35 degrees elevation
%% octa#1
[BFFC1t, M1t, AZ1t, EL1t] = sphear_select_azimuth_elevation_range(BFFC1, M1, AZ1, EL1, -180, 180, 35, 90);
sphear_bf_plot_frequency_response(BFFC1t, AZ1t, EL1t, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#2
[BFFC2t, M2t, AZ2t, EL2t] = sphear_select_azimuth_elevation_range(BFFC2, M2, AZ2, EL2, -180, 180, 35, 90);
sphear_bf_plot_frequency_response(BFFC1t, AZ1t, EL1t, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#3
[BFFC3t, M3t, AZ3t, EL3t] = sphear_select_azimuth_elevation_range(BFFC3, M3, AZ3, EL3, -180, 180, 35, 90);
sphear_bf_plot_frequency_response(BFFC1t, AZ1t, EL1t, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%% full azimuth, between -25 and -35 degrees elevation
%% octa#1
[BFFC1d, M1d, AZ1d, EL1d] = sphear_select_azimuth_elevation_range(BFFC1, M1, AZ1, EL1, -180, 180, -35, -20);
sphear_bf_plot_frequency_response(BFFC1d, AZ1d, EL1d, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#2
[BFFC2d, M2d, AZ2d, EL2d] = sphear_select_azimuth_elevation_range(BFFC2, M2, AZ2, EL2, -180, 180, -35, -20);
sphear_bf_plot_frequency_response(BFFC1d, AZ1d, EL1d, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);
%% octa#3
[BFFC3d, M3d, AZ3d, EL3d] = sphear_select_azimuth_elevation_range(BFFC3, M3, AZ3, EL3, -180, 180, -35, -20);
sphear_bf_plot_frequency_response(BFFC1d, AZ1d, EL1d, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%% all measurements
%% octa#1
[BFFC1t, M1t, AZ1t, EL1t] = sphear_select_azimuth_elevation_range(BFFC1, M1, AZ1, EL1, -180, 180, 35, 90);
sphear_bf_plot_frequency_response(BFFC1t, AZ1t, EL1t, fref_min, fref_max, 300, 20000, -30, 6, 48000, 8192);

%% directions plot at high frequencies, horizontal signals, first order in cardinal and diagonal directions
%% (using 64 point smoothing)
%% octa#1
sphear_plot_directions(BFFH1, 2000, 20000, -15, 3, 48000, 8192, 64);
%% octa#2
sphear_plot_directions(BFFH2, 2000, 20000, -15, 3, 48000, 8192, 64);
%% octa#3
sphear_plot_directions(BFFH3, 2000, 20000, -15, 3, 48000, 8192, 64);

%% plot one spherical harmonic for all (or a subset of) directions
%% W
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 1, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH2(:,:,:), AZH2, ELH2, 1, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH3(:,:,:), AZH3, ELH3, 1, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);

%% octa#1
%% X
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 2, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH2(:,:,:), AZH2, ELH2, 2, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH3(:,:,:), AZH3, ELH3, 2, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
%% > 1KHz, 64 point smoothing
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 2, fref_min, fref_max, 1000, 20000, -35, 6, 48000, 8192, 64);

%% Y
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 3, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH2(:,:,:), AZH2, ELH2, 3, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH3(:,:,:), AZH3, ELH3, 3, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
%% > 1.5KHz, smooth x 128
sphear_bfc_plot_frequency_response(BFFH2(:,:,:), AZH2, ELH2, 3, fref_min, fref_max, 1500, 20000, -35, 6, 48000, 8192, 128);

%% U
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 7, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH2(:,:,:), AZH2, ELH2, 7, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH3(:,:,:), AZH3, ELH3, 7, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);

%% V
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 8, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH2(:,:,:), AZH2, ELH2, 8, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH3(:,:,:), AZH3, ELH3, 8, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);

%% Z/S/T (horizontal plane, should be null)
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 4, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 5, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFH1(:,:,:), AZH1, ELH1, 6, fref_min, fref_max, 300, 20000, -35, 6, 48000, 8192, 0);

%% S (above 35 degrees)
sphear_bfc_plot_frequency_response(BFFC1t, AZ1t, EL1t, 6, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFC2t, AZ2t, EL2t, 6, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 0);
sphear_bfc_plot_frequency_response(BFFC3t, AZ3t, EL3t, 6, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 0);
%% no smoothing
sphear_bfc_plot_frequency_response(BFFC2t, AZ2t, EL2t, 6, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 0);

%% S (below at around -30)
sphear_bfc_plot_frequency_response(BFFC1d, AZ1d, EL1d, 6, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 64);

%% Z (azim 0, all elevations)
sphear_bfc_plot_frequency_response(BFFC2f, AZ2f, EL2f, 4, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 64);
sphear_bfc_plot_frequency_response(BFFC3f, AZ3f, EL3f, 4, 800, 1600, 300, 20000, -35, 6, 48000, 8192, 64);


%% polar plots for different frequency bands
%%
%% around 1.7KHz, near horizontal plane
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1h, M1h, AZ1h, EL1h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0);
%% add cardioid, order 2
sphear_bf_az_el_plot_polar_response(BFFC1h, M1h, AZ1h, EL1h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 2, -45);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0);
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0, 0, 0);
%% add cardioid, order 2
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 1, -45, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0);
%% add cardioid, order 2
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 2, -45);

%% around 3.7KHz, near horizontal plane
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1h, M1h, AZ1h, EL1h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 0);
%% add cardioid, order 2
sphear_bf_az_el_plot_polar_response(BFFC1h, M1h, AZ1h, EL1h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 2, -45);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 0);
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 0, 0, 0);
%% add cardioid, order 2
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 1, -45, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 0);
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 0, 0, 0);
%% add cardioid, order 2
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 3700, 2, -45);

%% around 7KHz, near horizontal plane
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1h, M1h, AZ1h, EL1h, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0);
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0, 0);
%% cardioid
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 1, -45, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0);

%% around 10KHz, near horizontal plane
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1h, M1h, AZ1h, EL1h, 600, 1200, 300, 20000, 3, 8192, FS, 10000, 0, 0);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 10000, 0, 0);
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 10000, 0, 0, 0);
%% cardioid
sphear_bf_az_el_plot_polar_response(BFFC2h, M2h, AZ2h, EL2h, 600, 1200, 300, 20000, 3, 8192, FS, 10000, 1, -45, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3h, M3h, AZ3h, EL3h, 600, 1200, 300, 20000, 3, 8192, FS, 10000, 0, 0);

%% around 1.7KHz, between 25 and 35 degree elevation
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1u, M1u, AZ1u, EL1u, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0, 0);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2u, M2u, AZ2u, EL2u, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0, 0);
sphear_bf_az_el_plot_polar_response(BFFC2u, M2u, AZ2u, EL2u, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0, 0, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3u, M3u, AZ3u, EL3u, 600, 1200, 300, 20000, 3, 8192, FS, 1700, 0, 0);

%% around 5KHz, between 25 and 35 degree elevation
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1u, M1u, AZ1u, EL1u, 600, 1200, 300, 20000, 3, 8192, FS, 5000, 0, 0);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2u, M2u, AZ2u, EL2u, 600, 1200, 300, 20000, 3, 8192, FS, 5000, 0, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3u, M3u, AZ3u, EL3u, 600, 1200, 300, 20000, 3, 8192, FS, 5000, 0, 0);

%% around 7KHz, between 25 and 35 degree elevation
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1u, M1u, AZ1u, EL1u, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2u, M2u, AZ2u, EL2u, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3u, M3u, AZ3u, EL3u, 600, 1200, 300, 20000, 3, 8192, FS, 7000, 0, 0);

%% around 9KHz, between 25 and 35 degree elevation
%% octa#1
sphear_bf_az_el_plot_polar_response(BFFC1u, M1u, AZ1u, EL1u, 600, 1200, 300, 20000, 3, 8192, FS, 9000, 0, 0);
%% octa#2
sphear_bf_az_el_plot_polar_response(BFFC2u, M2u, AZ2u, EL2u, 600, 1200, 300, 20000, 3, 8192, FS, 9000, 0, 0);
sphear_bf_az_el_plot_polar_response(BFFC2u, M2u, AZ2u, EL2u, 600, 1200, 300, 20000, 3, 8192, FS, 9000, 0, 0, 0);
%% octa#3
sphear_bf_az_el_plot_polar_response(BFFC3u, M3u, AZ3u, EL3u, 600, 1200, 300, 20000, 3, 8192, FS, 9000, 0, 0);


%% cardioid...

%% write A2B encoder Faust file

%% octa#1
sphear_write_simple_octa_a2b_encoder(CFIRH1, A2BC1, FIRC1, name="OctaSpHEAR_A2B_FUMA_01", serial=1, faust_version=1, create_r=1, fuma=1);
sphear_write_simple_octa_a2b_encoder(CFIRH1, A2BC1, FIRC1, name="OctaSpHEAR_A2B_FUMA_01", serial=1, faust_version=2, create_r=1, fuma=1);

sphear_write_simple_octa_a2b_encoder(CFIRH1, A2BC1, FIRC1, name="OctaSpHEAR_A2B_ACN_01", serial=1, faust_version=1, create_r=1, fuma=0);
sphear_write_simple_octa_a2b_encoder(CFIRH1, A2BC1, FIRC1, name="OctaSpHEAR_A2B_ACN_01", serial=1, faust_version=2, create_r=1, fuma=0);

%% octa#2
sphear_write_simple_octa_a2b_encoder(CFIRH2, A2BC2, FIRC2, name="OctaSpHEAR_A2B_FUMA_02", serial=2, faust_version = 1, create_r=1, fuma=1);
sphear_write_simple_octa_a2b_encoder(CFIRH2, A2BC2, FIRC2, name="OctaSpHEAR_A2B_FUMA_02", serial=2, faust_version = 2, create_r=1, fuma=1);

sphear_write_simple_octa_a2b_encoder(CFIRH2, A2BC2, FIRC2, name="OctaSpHEAR_A2B_ACN_02", serial=2, faust_version = 1, create_r=1, fuma=0);
sphear_write_simple_octa_a2b_encoder(CFIRH2, A2BC2, FIRC2, name="OctaSpHEAR_A2B_ACN_02", serial=2, faust_version = 2, create_r=1, fuma=0);

%% octa#3
sphear_write_simple_octa_a2b_encoder(CFIRH3, A2BC3, FIRC3, name="OctaSpHEAR_A2B_ACN_03", serial=2, faust_version = 2, create_r=1, fuma=0);


%%%% END OF CALIBRATION %%%%

