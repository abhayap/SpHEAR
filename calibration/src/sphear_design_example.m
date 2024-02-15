%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% Design a simple A2B encoder, static matrix and four (WXYZ) FIR filters
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


%% captured measurements of sine sweeps are stored in "path/capture/*",
%% it is assumed there is an index.txt file in that directory that includes
%% the information for each measurement in this format:
%%
%% measurement_number azimuth (radians) elevation (radians) file_name
%% (text file, fields separated by spaces)

%% when we run this function for the first time we do not know where are
%% the first reflections in our impulse response, so we need to choose a
%% much longer time as the second parameter (for example, 0.020 secs). This
%% will generate impulse response files that we can visually inspect
%% with a good sound editor to determine the location of the first reflections
%% with respect to the main peak of the impulse response (for example, in our
%% measurements we are able to get clean 4.5mSec impulse responses).

%% before we start the design process we need to equalize the measurements
%% to take into account the frequency response of the speaker used. The first
%% time the function below is run it will convolve the reference microphone
%% sweep with the inverse sweep to create the raw impulse response, it will
%% then see if the DRC generated speaker inverse filter is there and if not
%% will print an appropriate message

%% if the inverse filter is missing we generate it with the shell function
%% sphear_make_reference_filter, the first parameter is the name of the
%% reference microphone (used to get its calibration file) and the second
%% is the path to the base directory where the reference impulse response
%% is stored

%% run the function again and it will read the reference, the drc filter
%% and convolve all the measurements with the filter, trim and window them

%% calibrate measurements
sphear_af_calibrate_measurements("../data/2018.07.11/tetra_jette/2d/", 0.0045);
sphear_af_calibrate_measurements("../data/2018.08.14/tetra_2d_03/", 0.0045);

%% read all measurements and their azimuth and elevation angles
[AF, AZ, EL, FS] = sphear_af_read_calibrated("../data/2018.07.11/tetra_jette/2d/");
[AF, AZ, EL, FS] = sphear_af_read_calibrated("../data/2018.08.14/tetra_03/2d/");

%% just for checking the data, this plots the frequency response of each
%% measurement for each capsule. 
sphear_capsule_plot_frequency_response(AF, [1:16], 300, 20000, -60, -6, 48000, 8192);

sphear_af_plot_frequency_response(AF, 300, 20000, -60, -10, 48000, 8192);

%% calculate signal power in reference frequency interval for all
%% measurements and capsules
[R] = sphear_signal_power(AF, FS, 600, 1200, 8192);

[R] = sphear_signal_power(AF, FS, 800, 2000, 8192);

%% check that capsule signals are reasonable
sphear_plot_r(R, 0);

%% calculate the projections matrix for 1st order components
[M x y z] = sphear_az_el_to_X_matrix(AZ, EL, 1);

%% calculate a static A2B matrix based on the power measurements in the reference band
[A2B, PV, COND] = sphear_calculate_a2b(R, M);

%% generate a B-format signal using the A-format signal and the static A to B matrix
[BF] = sphear_af_to_bf(AF, A2B);
				  
%% plot frequency response of B-format components for each measurement direction
%% this shows the high frequency problems due to capsules not being co-located
sphear_bf_plot_frequency_response(BF, AZ, EL, 600, 1200, 300, 20000, -50, 9, 48000, 8192);

%% calculate power of B-format signals in logarithmically spaced frequency bands
[B, FC, FE] = sphear_signal_power_all(BF, FS, 300, 20000, 600, 1200, 16, 8192);
[B, FC, FE] = sphear_signal_power_all(BF, FS, 300, 20000, 800, 2000, 16, 8192);

%% above the transition frequency (see plots above) the B-format behavior
%% deviates from the ideal as the capsules are no longer co-located, we use
%% the signal power to extract filter shapes from the B-format signals. 

%% extract the shapes of wxyz[uv] filters
%%
%% average response in cardinal directions
%% [W X Y Z] = sphear_bf_extract_filter_shapes(B, 0);
%% average response in diagonal directions
%% [W X Y Z] = sphear_bf_extract_filter_shapes(B, 1);
%% average all measurements
%% [W X Y Z] = sphear_bf_extract_filter_shapes(B, 2);

%% these are the cardinal directions (verify for your measurements)
AZ([1,5,9,13])/pi*180
%% and the diagonals
AZ([1,5,9,13]+2)/pi*180

%% average W in cardinal directions
W = sphear_bf_extract_filter_shape(FC, M, B, 1, -0.5, [1,5,9,13]);
%% or in diagonals
W = sphear_bf_extract_filter_shape(FC, M, B, 1, -0.5, [1,5,9,13]+2);
%% average all
W = sphear_bf_extract_filter_shape(FC, M, B, 1, -0.5);
%% find averages for X and Y
X = sphear_bf_extract_filter_shape(FC, M, B, 2, -0.5);
Y = sphear_bf_extract_filter_shape(FC, M, B, 3, -0.5);

%% look at the shapes of the filters
%%
%% for tetrahedral microphones Z is an average estimation so do not plot it
sphear_bf_plot_filters(FC, W, X, Y, [], [], [], [], []);

%% now design minimum phase FIR filters, one for each B-format component

[FIR IR MPS] = sphear_design_fir_filters(FC, 256, 48000, W, X, Y);

%% W needs a longer filter for our microphone, 512 really flattens,
%% 256 makes a little bump at around 5KHz. XYZ are happy with a lot
%% less, 128 seems fine

%% re-calculate the full B-format signal with the filters
[BF, BFF] = sphear_af_to_bf(AF, A2B, FIR, 8192);

%% get the average power in the directions of the lobes for W, XY and UV
%% and normalize the A2B matrix so that ZY and UV have the same peak amplitude
%% as W
[A2B XY_gain UV_gain] = sphear_bf_normalize_gain(A2B, BFF, FS, 1000, 2000, 8192);
[A2B XY_gain UV_gain] = sphear_bf_normalize_gain(A2B, BFF, FS, 800, 2000, 8192);

%% re-calculate the B-format signal
[BF, BFF] = sphear_af_to_bf(AF, A2B, FIR, 8192);

%% plot the frequency response of the B-format components for each measurement
%% direction, they should all be flat
sphear_bf_plot_frequency_response(BFF, AZ, EL, 600, 1200, 300, 20000, -30, 6, 48000, 8192);

%% a revealing plot that highlights the cardinal direction response versus
%% the diagonal direction response
sphear_plot_directions(BFF, 300, 20000, -15, 3, 48000, 8192, 0);
sphear_plot_directions(BFF, 2000, 20000, -15, 3, 48000, 8192, 64);

%% plot the polar response of the B-format components, 1/3 octave bands
sphear_bf_plot_polar_response(BFF, 600, 1200, 300, 20000, 3, 8192, FS, []);

sphear_bf_az_el_plot_polar_response(BFF, M, AZ, EL, 600, 1200, 300, 20000, 3, 8192, FS, []);

%% replace the Z polar response with a virtual cardioid pointing at -45 degrees azimuth
sphear_bf_plot_polar_response(BFF, 800, 1600, 300, 20000, 3, 8192, FS, [], 1, -45);
%% or plot just one band around a defined frequency
sphear_bf_plot_polar_response(BFF, 800, 1600, 300, 20000, 3, 8192, FS, 2000.0);
%% or plot several frequency bands around defined frequencies
sphear_bf_plot_polar_response(BFF, 800, 1600, 300, 20000, 3, 8192, FS, [1000.0, 2000.0, 5000.0]);

%% write a simple Faust A to B encoder that includes the static matrix
%% and all FIR filters (not efficient but works)
sphear_write_simple_a2b_encoder(A2B, FIR, "TinySpHEAR_A2B_04");

sphear_write_simple_a2b_encoder(A2B, FIR, "TinySpHEAR_A2B_J");

%% compile a standalone A to B encoder program for batch processing:
%%
%% faust -a sndfile.cpp TinySpHEAR_A2B_04.dsp > TinySpHEAR_A2B_04.cpp
%% g++ TinySpHEAR_A2B_04.cpp -o TinySpHEAR_A2B_03 -l sndfile
%%
%% (we need to have libsndfile installed for this to work)

%%%% END OF CALIBRATION %%%%


%%%% 3D CALIBRATION %%%%

[AF3, AZ3, EL3, FS] = sphear_af_read_calibrated("../data/2018.08.14/tetra_03/3d/");

%% re-calculate the B-format signal
[BF3, BFF3] = sphear_af_to_bf(AF3, A2B, FIR, 8192);

%% plot the frequency response of the B-format components for each measurement
%% direction, they should all be flat
sphear_bf_plot_frequency_response(BFF3, AZ3, EL3, 600, 1200, 300, 20000, -30, 6, 48000, 8192);

