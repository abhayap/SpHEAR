%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% Common functions for A2B encoder design
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

%% make sure octave treats this as a script file
1;

pkg load signal;
pkg load plot;

%% turn off the pager
more off

%%
%% Read an A-Format signal for specified measurements
%%

global DATA = "../data/";
global CURRENT = "current/";

function [AF, FS] = sphear_af_read(measurements, raw = false);
  global DATA;
  global CURRENT;
  if (raw)
    type = "";
  else
    type = "cal-";
  end
  if (exist([DATA CURRENT "af/a-format-cal-001-5.wav"]))
    %% assume it is an eight capsule microphone
    capnames = cellstr(['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8']);
    capsules = 8;
  else
    %% otherwise a tetrahedral microphone
    capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);
    capsules = 4;
  end
  %% read all measurements
  for m = measurements
    %% read all capsules
    for c = 1:capsules
      %% read in calibrated capsule measurement
      [A, FS] = wavread([DATA CURRENT "af/a-format-" type sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
      AF(m, c, :) = A;
    end
  end
  %% read any up/down measurements
  if (exist([DATA CURRENT "af/a-format-cal-up-001-5.wav"]))
    for m = measurements
      %% read all capsules
      for c = 1:capsules
	%% read in calibrated capsule measurement
	[A, FS] = wavread([DATA CURRENT "af/a-format-" type sprintf("up-%03d", m) "-" char(capnames(c)) ".wav"]);
	AF(m + 16, c, :) = A;
      end
    end
  end
  if (exist([DATA CURRENT "af/a-format-cal-down-001-5.wav"]))
    for m = measurements
      %% read all capsules
      for c = 1:capsules
	%% read in calibrated capsule measurement
	[A, FS] = wavread([DATA CURRENT "af/a-format-" type sprintf("down-%03d", m) "-" char(capnames(c)) ".wav"]);
	AF(m + 16 + 16, c, :) = A;
      end
    end
  end
end

function [AF, FS] = sphear_af_read_all(measurements, raw = false);
  global DATA;
  global CURRENT;
  if (raw)
    type = "";
  else
    type = "cal-";
  end
  %% are there more than 4 capsules?
  if (exist([DATA CURRENT "af/a-format-cal-001-5.wav"]))
    %% assume it is an eight capsule microphone
    capnames = cellstr(['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8']);
    capsules = 8;
  else
    %% otherwise a tetrahedral microphone
    capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);
    capsules = 4;
  end
  %% read all measurements
  for m = measurements
    %% read all capsules
    for c = 1:capsules
      %% read in calibrated capsule measurement
      [A, FS] = wavread([DATA CURRENT "af/a-format-" type sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
      AF(m, c, :) = A;
    end
  end
  %% read any up/down measurements
  if (exist([DATA CURRENT "af/a-format-up-cal-001-5.wav"]))
    for m = measurements
      %% read all capsules
      for c = 1:capsules
	%% read in calibrated capsule measurement
	[A, FS] = wavread([DATA CURRENT "af/a-format-up-" type sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
	AF(m + 16, c, :) = A;
      end
    end
  end
  if (exist([DATA CURRENT "af/a-format-down-cal-001-5.wav"]))
    for m = measurements
      %% read all capsules
      for c = 1:capsules
	%% read in calibrated capsule measurement
	[A, FS] = wavread([DATA CURRENT "af/a-format-down-" type sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
	AF(m + 16 + 16, c, :) = A;
      end
    end
  end
end

%%
%% Read set of calibrated measurements
%%
%% path: path to index of measurements (default: ../data/current/)
%%
%% returns:
%% AF: array of calibrated impulse responses
%% AZ: azimuth for each IR in radians
%% EL: elevation for each IR in radians
%%
%%
%% The index.txt file has the following format:
%%     m az el file_name
%% m: measurement number
%% az: azimuth of measurement (radians)
%% el: elevation of measurement (radians)
%% file_name: string with file name of measurement relative to the capture
%%            directory where the index.txt file is located

function [AF, AZ, EL, FS] = sphear_af_read_calibrated(path);
  if (strcmp(path, ""))
    path = "../data/current/";
  end
  %% read measurement index file
  [measurements, azims, elevs, files] = textread(strcat(path, "capture/index.txt"), "%d %f %f %s");
  %% find number of channels from first raw measurement capture file
  [frames, chans] = wavread(strcat(path, "capture/a-format-", sprintf("%.3d.wav", 1)), "size");
  %% read all calibrated files
  for measurement = 1:size(measurements);
    printf("reading measurement %d, az=%f, el=%f, %s\n", measurement, azims(measurement), elevs(measurement), files(measurement){1,1});
    for capsule = 1:chans
      [A, FS] = wavread(strcat(path, "cal/a-format-", sprintf("%.3d-%d.wav", measurement, capsule)));
      AF(measurement, capsule, :) = A;
    end
    AZ(measurement) = azims(measurement);
    EL(measurement) = elevs(measurement);
  end
  AZ = AZ';
  EL = EL';
end

function [AF, FS] = sphear_af_read_capsule(measurements, raw = false);
  global DATA;
  global CURRENT;
  if (raw)
    type = "";
  else
    type = "cal-";
  end
  if (exist([DATA CURRENT "af/capsule_u-cal-001-1.wav"]))
    %% assume it is an eight capsule microphone
    capnames = cellstr(['1'; '2'; '3'; '4'; '5'; '6'; '7'; '8']);
    capsules = 1;
  else
    %% otherwise a tetrahedral microphone
    capnames = cellstr(['LF'; 'RF'; 'LB'; 'RB']);
    capsules = 4;
  end
  %% read all measurements
  for m = measurements
    %% read all capsules
    for c = 1:capsules
      %% read in calibrated capsule measurement
      printf("m:%d -> c:%d\n", m, c);
      [A, FS] = wavread([DATA CURRENT "af/capsule_u-" type sprintf("%03d", m) "-" char(capnames(c)) ".wav"]);
      AF(m, c, :) = A;
    end
  end
end

%%
%% Read full t-design coordinates
%%
%% path: path to t-design file (default: ../data/current/)
%%
%% returns:
%% AZ: azimuth for each t-design point in radians
%% EL: elevation for each t-design point in radians
%%
%% The index.txt file has the following format:
%%     m az el file_name
%% m: measurement number
%% az: azimuth of measurement (radians)
%% el: elevation of measurement (radians)

function [AZ, EL] = sphear_af_read_t_design(path);
  if (strcmp(path, ""))
    path = "../data/current/";
  end
  %% read measurement index file
  [measurements, azims, elevs] = textread(strcat(path, "capture/t_design.txt"), "%d %f %f");
  AZ = azims;
  EL = elevs;
end

%%
%% Calculate power for signal in a frequency range
%%
%% cardioid == 1: replace Z with a cardioid pointing at horizontal angle "azim"
%% cardioid == 2: replace Z with a second order lobe pointing at horizontal angle "azim"

function [R] = sphear_signal_power(SIG, FS, fmin, fmax, fft_size, cardioid = 0, azim = 45)
  %% indexes in array for frequency bins
  imin = round((fft_size/2) * fmin / (FS/2));
  imax = round((fft_size/2) * fmax / (FS/2));
  measurements = size(SIG)(1);
  signals = size(SIG,2);
  %% calculate power in frequency range
  for m = (1:measurements)
    for s = (1:signals)
      if (s == 4 && cardioid > 0)
	if (cardioid < 2)
	  %% replace Z with a cardioid
	  spectrum = fft((SIG(m, 1, :) +
			  1.0 * SIG(m, 2, :) * cos(azim/180*pi) +
			  1.0 * SIG(m, 3, :) * sin(azim/180*pi)) / 2, fft_size);
	else
	  %% replace Z with a second order lobe
	  spectrum = fft((SIG(m, 1, :) +
			  (1.0 * SIG(m, 2, :) * cos(azim/180*pi)) +
			  (1.0 * SIG(m, 3, :) * sin(azim/180*pi)) +
			  (1.0 * SIG(m, 7, :) * cos((2 * azim)/180*pi)) +
			  (1.0 * SIG(m, 8, :) * sin((2 * azim)/180*pi))) / 2.5, fft_size);
	end
      else
	spectrum = fft(SIG(m, s, :), fft_size);
      end
      %% return total power of signal in frequency range
      R(m,s,:) = sqrt(sum(spectrum(imin:imax).*conj(spectrum(imin:imax)))/(imax - imin));
    end
  end
end

%%
%% Calculate power for capsule in a frequency range
%%

function [R] = sphear_capsule_power(SIG, FS, fmin, fmax, fft_size)
  %% indexes in array for frequency bins
  imin = round((fft_size/2) * fmin / (FS/2));
  imax = round((fft_size/2) * fmax / (FS/2));
  measurements = size(SIG)(1);
  signals = size(SIG,2);
  %% calculate power in frequency range
  for m = (1:measurements)
    for s = (1:signals)
      spectrum = fft(SIG(m, s, :), fft_size);
      %% return total power of signal in frequency range
      R(m,s,:) = sqrt(sum(spectrum(imin:imax).*conj(spectrum(imin:imax)))/(imax - imin));
    end
  end
end

%%
%% Calculate A to B matrix from matrix of power measurements
%%

function [A2B PV COND ERROR] = sphear_calculate_a2b(R, M)
  if (exist("M"))
    [A2B PV ERROR] = A2B_matrix(R, M);
  else
    [A2B PV ERROR] = A2B_matrix(R);
  end
  %% normalize matrix
  %%
  %% normalize first order components of the matrix first
  WXYZ_avg = mean(mean(abs(A2B(:,1:3))));
  A2B = A2B ./ WXYZ_avg;
  if (size(A2B, 2) > 4)
    %% S/T/U/V are difference microphones, so at the reference
    %% frequency range their signal is much lower than the
    %% first order components, so normalize separately
    ST_avg = mean(mean(abs(A2B(:,5:6))));
    if (ST_avg != 0)
      A2B(:,5:6) = A2B(:,5:6) ./ ST_avg;
    end
    UV_avg = mean(mean(abs(A2B(:,7:8))));
    if (UV_avg != 0)
      A2B(:,7:8) = A2B(:,7:8) ./ UV_avg;
    end
  else
    ST_avg = 0;
    UV_avg = 0;
  end
  printf("WXYZ avg = %f, ST avg = %f, UV avg = %f\n", WXYZ_avg, ST_avg, UV_avg);
  %% return condition number
  COND = cond(A2B);
end

%%
%% Render a calibrated capsule impulse response through an A2B matrix and optional FIR filter
%%
%% m: number of measurement to render
%% A2B: A to B matrix
%% FIR: optional FIR filters
%% fft_size: FFT size for filtering

function [BF, BFF] = sphear_af_to_bf_old(AF, A2B, FIR, fft_size);
  measurements = size(AF)(1);
  BF = zeros(measurements, size(A2B, 2), size(AF, 3));
  for m = (1:measurements)
    for c = (1:size(AF,2))
      bfc(1,:,:) = reshape(AF(m,c,:), 1, []) .* reshape(A2B(c,:), 1, [])';
      BF(m,:,:) = BF(m,:,:) .+ bfc(1,:,:);
    end
  end
  if exist("FIR")
    if (size(FIR, 1) <= 8)
      %% filter the B format signal through the common FIR filters
      for m = (1:measurements)
	for b = 1:size(FIR, 1)
	  %% we add trailing zeros to let the filter ring
	  BFF(m,b,:) = fftfilt(reshape(FIR(b,:), 1, [])', cat(1, reshape(BF(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
	end
      end
    else
      %% first four components use common filters, U/V use filter arrays
      for m = (1:measurements)
	for b = 1:4
	  BFF(m,b,:) = fftfilt(reshape(FIR(b,:), 1, [])', cat(1, reshape(BF(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
	end
      end
      capsules = 8;
      for m = (1:measurements)
	for b = 5:6
	  for c = 1:capsules
	    fi = 4 + (b - 5)*capsules + c;
	    if (c == 1)
	      BFF(m,b,:) = fftfilt(reshape(FIR(fi,:), 1, [])', cat(1, reshape(BF(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
	    else
	      BFF(m,b,:) = reshape(BFF(m,b,:), size(BFF, 3), 1)' .+ fftfilt(reshape(FIR(fi,:), 1, [])', cat(1, reshape(BF(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
	    end
	  end
	end
      end
    end
  else
    BFF = BF;
  end
end

function [BF, BFF] = sphear_af_to_bf(AF, A2B, FIR, fft_size);
  measurements = size(AF)(1);
  BF = zeros(measurements, size(A2B, 2), size(AF, 3));
  for m = (1:measurements)
    for c = (1:size(AF,2))
      bfc(1,:,:) = reshape(AF(m,c,:), 1, []) .* reshape(A2B(c,:), 1, [])';
      BF(m,:,:) = BF(m,:,:) .+ bfc(1,:,:);
    end
  end
  if exist("FIR")
    %% filter the B format signal through the common FIR filters
    for m = (1:measurements)
      for b = 1:size(FIR, 1)
	%% we add trailing zeros to let the filter ring
	BFF(m,b,:) = fftfilt(reshape(FIR(b,:), 1, [])', cat(1, reshape(BF(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
      end
    end
  else
    BFF = BF;
  end
end

%%
%% Filter BF components with FIR filters
%%

function [BF] = sphear_filter_bf(B, FIR, fft_size);
  measurements = size(B, 1);
  bf = size(FIR, 1);
  for m = (1:measurements)
    for b = (1:bf)
      BF(m,b,:) = fftfilt(reshape(FIR(b,:), 1, [])', cat(1, reshape(B(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
    end
  end
end

%%
%% Render a calibrated capsule impulse response through UV matrix filters
%%
%% m: number of measurement to render
%% A2B: A to B matrix
%% FIR: optional FIR filters
%% fft_size: FFT size for filtering

function [UV, UVF] = sphear_af_to_bf_new(AF, A2B, FIR, fft_size);
  measurements = size(AF)(1);
  BF = zeros(measurements, size(A2B, 2), size(AF, 3));
  for m = (1:measurements)
    for c = (1:size(AF,2))
      bfc(1,:,:) = reshape(AF(m,c,:), 1, []) .* reshape(A2B(c,:), 1, [])';
      BF(m,:,:) = BF(m,:,:) .+ bfc(1,:,:);
    end
  end
  if exist("FIR")
    if (size(FIR, 1) <= 6)
      %% filter the B format signal through four or six FIR filters
      for m = (1:measurements)
	for b = 1:size(FIR, 1)
	  %% we add trailing zeros to let the filter ring
	  BFF(m,b,:) = fftfilt(reshape(FIR(b,:), 1, [])', cat(1, reshape(BF(m,b,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size);
	end
      end
    else
      %% filter the B format signal through single filters for first order
      %% and array of filters for second order
    end
  else
    BFF = BF;
  end
end

%% Render a capsule signal through an A2B matrix of filters
%%
%% FIR: matrix of FIR filters
%% fft_size: FFT size for filtering

function [BF] = sphear_af_matrix_filter_to_bf(SIG, FIR, fft_size)
  measurements = size(SIG, 1);
  %% number of capsules (A format signals)
  afcount = size(SIG, 2);
  %% number of B format components
  bfcount = size(FIR, 3);
  for m = (1:measurements)
    for afi = (1:afcount)
      for bfi = (1:bfcount)
	if (afi == 1)
	  BF(m,bfi,:) = fftfilt(reshape(FIR(:,afi,bfi), 1, [])', cat(1, reshape(SIG(m,afi,:), 1, [])', zeros(2*size(FIR(:,1,1), 1), 1))', fft_size);
	else
	  BF(m,bfi,:) = reshape(BF(m,bfi,:), size(BF, 3), 1)' .+ ...
			fftfilt(reshape(FIR(:,afi,bfi), 1, [])', cat(1, reshape(SIG(m,afi,:), 1, [])', zeros(2*size(FIR(:,1,1), 1), 1))', fft_size);
	end
      end
    end
  end
end

%%
%% Calculate B format power in logarithmic frequency bands
%%

function [SP, FC, FE] = sphear_signal_power_all(SIG, FS, fmin, fmax, frefmin, frefmax, Noct, fft_size)
  %% calculate number of frequency bands spaced Noct
  n = floor(log(fmax/fmin)/log(2^(1/Noct)));
  %% adjust width of band so they fit exactly in frequency range
  N = log(2)/(log(fmax/fmin)/n);
  printf("%d frequency bands, %f bands per octave\n", n, N);

  %% first center frequency
  fcmin = fmin * 2^(1/(N * 2));
  %% all center and edge frequencies
  FC = fcmin * 2.^((0:n - 1)/N)';
  FE = fmin * 2.^((0:n)/N)';

  %% normalize power with respect to reference frequency band
  %% (measurement,signal,power)
  ref = sphear_signal_power(SIG, FS, frefmin, frefmax, fft_size);
  norm = mean(ref(:,:));

  %% we only normalize with respect to WXYZ, STUV in the frequency range
  %% where WXYZ are well behaved has low power (high pass filter due
  %% to the difference microphones) so we don't want to average that.
  %% If we do that the A2B coefficients are much higher than the ones
  %% for WXYZ and we get clipping for signals close to full scale (and
  %% then attenuation in the filtering stage after that)
  WXYZnorm = mean(ref(:,[1,2,3,4]));
  XYavg = mean(WXYZnorm([2,3]));
  if (size(SIG, 2) > 4)
    %% use XY average for STUV
    norm = cat(1, WXYZnorm', [XYavg], [XYavg], [XYavg], [XYavg])';
  end
  for i = (1:size(FC))
    %% (measurement,signal,band,power)
    SP(:,:,i) = sphear_signal_power(SIG, FS, FE(i), FE(i + 1), fft_size) ./ norm;
  end
end

function [SP, FC, FE, FC1, FE1, FC2, FE2] = sphear_signal_power_all_test(SIG, FS, fmin, fmax, frefmin, frefmax, Noct, fft_size)
  %% calculate number of frequency bands spaced Noct
  n = floor(log(fmax/fmin)/log(2^(1/Noct)));
  n2 = floor(log(fmax/fmin)/log(2^(1/(Noct/2))));
  n4 = floor(log(fmax/fmin)/log(2^(1/(Noct/2))));
  %% adjust width of band so they fit exactly in frequency range
  N = log(2)/(log(fmax/fmin)/n);
  N2 = log(2)/(log(fmax/fmin)/n2);
  N4 = log(2)/(log(fmax/fmin)/n4);
  printf("%d frequency bands, %f bands per octave\n", n, N);

  %% first center frequency
  fcmin = fmin * 2^(1/(N * 2));
  fcmin2 = fmin * 2^(1/(N2 * 2));
  fcmin4 = fmin * 2^(1/(N4 * 2));
  %% all center and edge frequencies
  FC1 = fcmin * 2.^((0:n - 1)/N)';
  FE1 = fmin * 2.^((0:n)/N)';
  FC2 = fcmin2 * 2.^((0:n2 - 1)/N2)';
  FE2 = fmin * 2.^((0:n2)/N2)';
  FC4 = fcmin4 * 2.^((0:n4 - 1)/N4)';
  FE4 = fmin * 2.^((0:n4)/N4)';

  %% merge.....
  printf("starting merge\n");
  index = 1;
  for fi = (1:size(FC2))
    fc = FC2(fi);
    if (fc < 2000)
      FC(index) = FC2(fi);
      FE(index) = FE2(fi);
      FE(index+1) = FE2(fi+1);
      index = index + 1;
    end
  end
  printf("second part of merge\n");
  for fi = (1:size(FC1))
    fc = FC1(fi);
    if (fc >= 2000)
      FC(index) = FC1(fi);
      FE(index) = FE1(fi);
      FE(index+1) = FE1(fi+1);
      index = index + 1;
    end
  end

  FC = FC';
  FE = FE';
  for fc = (1:size(FC))
    %% fprintf("fc=%f <%f -> %f>\n", FC(fc), FE(fc), FE(fc+1));
  end

  %% normalize power with respect to reference frequency band
  %% (measurement,signal,power)
  ref = sphear_signal_power(SIG, FS, frefmin, frefmax, fft_size);
  norm = mean(ref(:,:));

  %% we only normalize with respect to WXYZ, STUV in the frequency range
  %% where WXYZ are well behaved has low power (high pass filter due
  %% to the difference microphones) so we don't want to average that.
  %% If we do that the A2B coefficients are much higher than the ones
  %% for WXYZ and we get clipping for signals close to full scale (and
  %% then attenuation in the filtering stage after that)
  WXYZnorm = mean(ref(:,[1,2,3,4]));
  XYavg = mean(WXYZnorm([2,3]));
  %% use XY average for STUV
  norm = cat(1, WXYZnorm', [XYavg], [XYavg], [XYavg], [XYavg])';

  for i = (1:size(FC))
    %% (measurement,signal,band,power)
    SP(:,:,i) = sphear_signal_power(SIG, FS, FE(i), FE(i + 1), fft_size) ./ norm;
  end
end

%%
%% Extract average shapes of B format filters
%%
%% old version, use sphear_bf_extract_filter_shape

%% measurements:
%% 0 -> use defaults
%% 1 -> use all measurements
%% 2 -> use cardinal measurements
%% 3 -> use diagonal measurements

function [W X Y Z S T U V] = sphear_bf_extract_filter_shapes(B, measurements)
  %% cardinal and diagonal directions for four capsule array
  TETRA_CARDINALS = [1, 5, 9, 13];
  TETRA_DIAGONALS = [3, 7, 11, 15];
  %% cardinal and diagonal directions for eight capsule array
  OCTA_CARDINALS = [1, 3, 5, 7, 9, 11, 13, 15];
  OCTA_DIAGONALS = [2, 4, 6, 8, 10, 12, 14, 16];
  %% best directions for octa WXY
  OCTA_FLAT = OCTA_DIAGONALS;
  OCTA_BRIGHT = OCTA_CARDINALS;
  %% best directions for octa Z
  if (size(B, 1) > 32)
    OCTA_FLAT_Z = [OCTA_FLAT + 16, OCTA_FLAT + 32];
  else
    OCTA_FLAT_Z = [OCTA_FLAT + 16];
  end
  %% best directions for octa UV
  U_DIRS = [1, 5, 9, 13];
  V_DIRS = [3, 7, 11, 15];
  %% best directions for octa ST (up and down layers)
  %% hack for only top hemisphere
  if (size(B, 1) > 32)
    S_DIRS = [U_DIRS + 16, U_DIRS + 32];
    T_DIRS = [V_DIRS + 16, V_DIRS + 32];
  else
    S_DIRS = [U_DIRS + 16];
    T_DIRS = [V_DIRS + 16];
  end
  %% all directions
  ALL_DIRS = [1:16];

  if (measurements == 0)
    %% cardinal directions
    if (size(B, 2) > 4)
      %% 8 capsules
      %% averaging all measurements for W seems to do better
      %%W_m = [OCTA_FLAT, OCTA_FLAT + 16, OCTA_FLAT + 32];
      %%Y_m = [OCTA_FLAT, OCTA_FLAT + 16, OCTA_FLAT + 32];
      %%X_m = [OCTA_FLAT, OCTA_FLAT + 16, OCTA_FLAT + 32];
      W_m = OCTA_FLAT;
      Y_m = OCTA_FLAT;
      X_m = OCTA_FLAT;
      if (size(B, 1) > 16)
	Z_m = OCTA_FLAT_Z;
      else
	Z_m = W_m;
      end
      S_m = S_DIRS;
      T_m = T_DIRS;
      U_m = U_DIRS;
      V_m = V_DIRS;
    else
      %% four capsules
      W_m = TETRA_CARDINALS;
      X_m = TETRA_CARDINALS;
      Y_m = TETRA_CARDINALS;
      Z_m = W_m;
    end
  else
    if (measurements == 1)
      %% diagonal directions
      if (size(B, 2) > 4)
	%% 8 capsules
	W_m = OCTA_BRIGHT;
	Y_m = OCTA_BRIGHT;
	X_m = OCTA_BRIGHT;
	Z_m = W_m;
	U_m = U_DIRS;
	V_m = V_DIRS;
      else
	%% four capsules
	W_m = TETRA_DIAGONALS;
	X_m = TETRA_DIAGONALS;
	Y_m = TETRA_DIAGONALS;
	Z_m = W_m;
      end
    else
      if (measurements == 2)
	%% average all measurements for all components
	W_m = ALL_DIRS;
	X_m = ALL_DIRS;
	Y_m = ALL_DIRS;
	Z_m = ALL_DIRS;
	U_m = ALL_DIRS;
	V_m = ALL_DIRS;
      end
    end
  end
  %% extract average response shape for W
  W = 1.0 ./ reshape(mean(B(W_m,1,:)), size(B(:,:,:))(3), 1);
  %% extract average response shape for XYZ
  X = 1.0 ./ reshape(mean(B(X_m,2,:)), size(B(:,:,:))(3), 1);
  Y = 1.0 ./ reshape(mean(B(Y_m,3,:)), size(B(:,:,:))(3), 1);
  Z = 1.0 ./ reshape(mean(B(Z_m,4,:)), size(B(:,:,:))(3), 1);
  if (size(B, 2) > 4)
    if (size(B, 1) > 16)
      %% full 3d measurements
      S = 1.0 ./ reshape(mean(B(S_m,5,:)), size(B(:,:,:))(3), 1);
      T = 1.0 ./ reshape(mean(B(T_m,6,:)), size(B(:,:,:))(3), 1);
    else
      %% flat 2d measurements, no S/T filters (ie: flat 1.0 filter)
      S = 1.0 ./ ones(size(B, 3), 1);
      T = 1.0 ./ ones(size(B, 3), 1);
    end
    U = 1.0 ./ reshape(mean(B(U_m,7,:)), size(B(:,:,:))(3), 1);
    V = 1.0 ./ reshape(mean(B(V_m,8,:)), size(B(:,:,:))(3), 1);
  end
end

%%
%% Extract the filter shape of one B format component
%%
%% FC: array of frequency centers of frequency ranges
%% M: projection of measurement points into harmonics
%% B: signals at measurement points
%% H: harmoni to be extracted (w:1, x:2, y:3, z:4, s:5, t:6, u:7, v:8)
%% db: dB's down from peak (1.0) to consider measurement
%% directions: force selection of measurements to consider (for W, mainly)
%% alias_freq: high frequency limit for spatial aliasing

function [FSHAPE] = sphear_bf_extract_filter_shape(FC, M, B, H, db, directions = [], alias_freq = 0)
  limit = db2mag(db);
  h = 1;
  indexes(1) = 0;
  if (H == 1)
    %% special case for W, it has no entry in M
    %% this should be changed in the A2B code...
    m = ones(size(M(:,1)), 1);
  else
    m = M(:,H-1);
  end
  if (exist("directions") && (numel(directions) > 0))
    indexes = directions;
    h = numel(directions);
  else
    %% collect measurements that fit the amplitude criteria
    for index = 1:numel(m);
      if (abs(m(index)) > limit)
	printf("harm:%d select measurement %d\n", H, index);
	indexes(h) = index;
	h = h + 1;
      end
    end
  end
  if (h > 1)
    FSHAPE = reshape(mean(abs(m(indexes))) ./ mean(B(indexes,H,:)), [], 1);
  else
    printf("no %d component above %f dB found\n", H, db);
    FSHAPE = ones(size(B,3),1);
  end
  if (numel(alias_freq) == 1)
    %% flatten above alias frequency
    alias_slot = 0;
    if (alias_freq > 0)
      %% find slot
      for s = 1:numel(FC)
	if (alias_freq <= FC(s) && alias_slot == 0)
	  alias_slot = s;
	end
      end
      if (alias_slot > 0)
	FSHAPE(alias_slot:end,:) = FSHAPE(alias_slot,:);
      end
    end
  else
    %% interpolate to the average of an alias transition band
    alias_slot(1) = 0;
    alias_slot(2) = 0;
    %% find slots for band limits
    for s = 1:numel(FC)
      for ai = 1:2
	if (alias_freq(ai) <= FC(s) && alias_slot(ai) == 0)
	  alias_slot(ai) = s;
	end
      end
    end
    %% calculate average on band
    band_avg = mean(FSHAPE(alias_slot(1):alias_slot(2),:));
    %% size of band in slots
    band_s = alias_slot(2) - alias_slot(1) + 1;
    %% make an interpolation line
    band_int = (1.0:-1/(band_s - 1):0.0)';
    %% now replace band with interpolation to average
    FSHAPE(alias_slot(1):alias_slot(2),:) = FSHAPE(alias_slot(1):alias_slot(2),:) .* band_int;
    FSHAPE(alias_slot(1):alias_slot(2),:) = FSHAPE(alias_slot(1):alias_slot(2),:) .+ (band_avg(:,:) .* (1.0 - band_int));
    band_avg
    size(FSHAPE,1)
    FSHAPE(alias_slot(2)+1:end,:) = FSHAPE(alias_slot(2),:);
  end
end

%%
%% Calculate normalization factor for a spherical harmonic
%%

function [NF] = sphear_bf_normalization_factor(FC, M, B, H, db, directions)
  limit = db2mag(db);
  h = 1;
  indexes(1) = 0;
  if (H == 1)
    %% special case for W, it has no entry in M
    %% this should be changed in the A2B code...
    m = ones(size(M(:,1)), 1);
  else
    m = M(:,H-1);
  end
  if (exist("directions"))
    indexes = directions;
    h = numel(directions);
  else
    %% collect measurements that fit the amplitude criteria
    for index = 1:numel(m);
      if (abs(m(index)) > limit)
	printf("harm:%d select measurement %d\n", H, index);
	indexes(h) = index;
	h = h + 1;
      end
    end
  end
  if (h > 1)
    NF = mean(reshape(mean(abs(m(indexes)) / B(indexes,H)), [], 1));
  else
    printf("no %d component above %f dB found\n", H, db);
    NF = ones(size(B,3),1);
  end
end

%%
%% Extract average shapes of capsule equalization filters
%%
%% (using for now only the horizontal plane measurements)

function [SHAPE] = sphear_extract_capsule_filter_shapes_old(A, neighbors)
  %% for each capsule
  for c = (1:size(A,2))
    %% get indexes of measurements to average for each capsule
    mlll = mod(16 - (c * 2) + 0, 16) + 1;
    mll = mod(16 - (c * 2) + 1, 16) + 1;
    ml = mod(16 - (c * 2) + 2, 16) + 1;
    m = mod(16 - (c * 2) + 3, 16) + 1;
    mr = mod(16 - (c * 2) + 4, 16) + 1;
    mrr = mod(16 - (c * 2) + 5, 16) + 1;
    mrrr = mod(16 - (c * 2) + 6, 16) + 1;
    for n = (1:5)
      mm(n,:) = mod(16 - (c * 2) - n + 2, 16) + 1;
      mm(n + 5,:) = mod(16 - (c * 2) + n + 2, 16) + 1;
    end
    printf("c:%d -> %d %d %d %d %d %d %d\n", c, mlll, mll, ml, m, mr, mrr, mrrr);
    if (neighbors > 3)
      %% average all directions
      SHAPE(c,:) = (1.0 ./ reshape(mean(A(:,c,:)), size(A,3), 1));
    else
      if (neighbors == 3)
	SHAPE(c,:) = (1.0 ./ reshape(mean(A([mlll, mll,ml,m,mr,mrr, mrrr],c,:)), size(A,3), 1));
      else
	if (neighbors == 2)
	  SHAPE(c,:) = (1.0 ./ reshape(mean(A([mll,ml,m,mr,mrr],c,:)), size(A,3), 1));
	else
	  SHAPE(c,:) = (1.0 ./ reshape(mean(A([ml,m,mr],c,:)), size(A,3), 1));
	end
      end
    end
  end
end

function [D] = distance_between_points(AZ0, EL0, AZ1, EL1)
  %% angles expressed in radians, points in unity sphere
  D = sqrt(2 + 2*cos(EL1 - EL0) - 2*sin(EL1)*sin(EL0)*cos(AZ1 - AZ0) - 1);
end

function [A] = angle_between_points(AZ0, EL0, AZ1, EL1)
  %% angles expressed in radians, points in unity sphere
  A = acos(sin(EL1)*sin(EL0) + cos(EL1)*cos(EL0)*cos(AZ1 - AZ0));
end

function [SHAPE PSHAPE] = sphear_find_capsule_filter_shapes(AP, AZ, EL, C, neighbors, min_angle, smooth)
  if (!exist("smooth"))
    smooth = 0;
  end
  %% for each capsule
  for c = (1:size(C,1))
    %% for each measurement
    for m = (1:size(AZ,1))
      %% find angle between measurement and capsule
      angle(m) = angle_between_points(AZ(m), EL(m), C(c,1), C(c,2));
    end
    %% sort angles in ascending order
    [angle_s, i] = sort(angle);
    %% select the ones that have a minimum angle with respect to the capsule
    %% (this allows us to exclude on-axis measurements)
    ii = 1;
    for m = 1:size(AZ,1)
      if (angle_s(m) >= min_angle)
	angle_si(ii) = angle_s(m);
	i_i(ii) = i(m);
	ii = ii + 1;
      end
    end
    %% now select the neighbors
    for n = (1:neighbors)
      distance = distance_between_points(AZ(i_i(n)), EL(i_i(n)), C(c,1), C(c,2));
      printf("capsule %d: m=%d, a=%f, d=%f (az=%f, elev=%f, corr=%f)\n", c, i_i(n), angle_si(n)/pi*180, distance,
	     (AZ(i_i(n))/pi*180), (EL(i_i(n))/pi*180), cos(angle_si(n)));
    end
    if (neighbors == 1)
      PSHAPE(c,:) = AP(i_i(1),c,:);
      SHAPE(c,:) = 1.0 ./ AP(i_i(1),c,:);
    else
      %% normalize the shape relative to an ideal cardioid
      for n = 1:neighbors
	APN(n,:) = AP(i_i(n),c,:) / cos(angle_si(n));
      end
      PSHAPE(c,:) = mean(APN(1:neighbors,:));
      SHAPE(c,:) = 1.0 ./ mean(APN(1:neighbors,:));
      %% SHAPE(c,:) = 1.0 ./ reshape(mean(AP(i(1:neighbors),c,:)), [], 1);
      %% apply smoothing if requested
      if (smooth > 0)
	PSHAPE(c,:) = fastsmooth(PSHAPE(c,:),smooth,2,1);
	SHAPE(c,:) = fastsmooth(SHAPE(c,:),smooth,2,1);
      end
    end
  end
end

%%
%% Select a set of measurements based on azimuth and elevation constraints
%%

function [SS MS AZS ELS] = sphear_select_azimuth_elevation_range(S, M, AZ, EL, azmin, azmax, elmin, elmax)
  q = 1;
  for i = 1:numel(AZ)
    if ((AZ(i) <= (azmax/180*pi)) && (AZ(i) >= (azmin/180*pi)) && (EL(i) <= (elmax/180*pi)) && EL(i) >= (elmin/180*pi))
      %% we are within boundaries
      printf("m:%d: found az=%f, el=%f\n", i, AZ(i)/pi*180, EL(i)/pi*180);
      SS(q,:,:) = S(i,:,:);
      AZS(q,:) = AZ(i);
      ELS(q,:) = EL(i);
      MS(q,:) = M(i,:);
      q = q + 1;
    end
  end
  printf("found %d measurements that qualify\n", numel(AZS));
end

%%
%% Extract equalization filter shape for each capsule
%%

function [SHAPE] = sphear_capsule_filter_shapes(AP, AZ, EL, C)
  %% for each capsule
  for c = (1:size(C,1))
    %%if ((AZ(c) != C(c,1)) || (EL(c) != C(c,2)))
    %%  printf("error for capsule %d, azimuth or elevation does not match (%f:%f != %f:%f\n", c, AZ(c), EL(c), C(c,1), C(c,2));
    %%else
      SHAPE(c,:) = 1.0 ./ AP(c,c,:);
    %%end
  end
end

function [SHAPE] = sphear_side_capsule_filter_shapes(AP, AZ, EL, C)
  %% for each capsule
  for c = (1:size(C,1))
    %%if ((AZ(c) != C(c,1)) || (EL(c) != C(c,2)))
    %%  printf("error for capsule %d, azimuth or elevation does not match (%f:%f != %f:%f\n", c, AZ(c), EL(c), C(c,1), C(c,2));
    %%else
    if (c > 2)
      cside = mod(c+7,8)-1;
    else
      cside = c+6;
    end
%%    printf("c:%d, cside=%f\n", c, cside);
    SHAPE(c,:) = 1.0 ./ AP(c,cside,:);
    %%end
  end
end

%%
%% Filter signals through capsule correction filters
%%

function [AFF] = sphear_filter_capsule_signals(AF, FIR, fft_size);
  measurements = size(AF, 1);
  capsules = size(AF, 2);
  samples = size(AF,3);
  AFF = zeros(measurements, capsules, samples);
  for m = (1:measurements)
    for c = (1:capsules)
      %% we add trailing zeros to let the filter ring
      AFF(m,c,:) = fftfilt(reshape(FIR(c,:), 1, [])', cat(1, reshape(AF(m,c,:), 1, [])', zeros(2*size(FIR(1,:))(2),1))', fft_size)(1:samples);
    end
  end
end

%%
%% Calculate average power for each B format component and normalize A2B matrix
%%

function [A2B XY_gain, S_gain, T_gain, U_gain, V_gain, B_power] = sphear_bf_normalize_gain(A2B, B, FS, fmin, fmax, fft_size)
  do_Z = false;
  if (size(B,1)/3 > 8)
    %% we assume we have three sets of measurements and can do Z averaging
    do_Z = true;
  end
  %% (measurement,signal,band,power)
  B_power = sphear_signal_power(B, FS, fmin, fmax, fft_size);
  %% W, all measurements
  W_avg = mean(B_power(:,1));
  %% XY, peak of first order lobes
  XY_avg = mean([mean(B_power([1,9], 2)), mean(B_power([5, 13], 3))]);
  XY_gain = XY_avg/W_avg;
  if (do_Z)
    %% Z, +-elev weighted by elevation angle
    %% FIXME: we just hardwire the elevation angle for now
    if (size(B, 1) > 32)
      Z_avg = mean(B_power([17:32,33:48],4)) / sin(43/180*pi);
    else
      Z_avg = mean(B_power([17:32],4)) / sin(43/180*pi);
    end
    Z_gain = Z_avg/W_avg;
  else
    Z_gain = 0.0;
  end
  if (size(A2B, 2) > 4)
    %% UV, peak of second order lobes
    U_avg = mean(mean(B_power([1,5,9,13], 7)));
    U_gain = U_avg/W_avg;
    V_avg = mean(mean(B_power([3,7,11,15], 8)));
    V_gain = V_avg/W_avg;
    if (abs(mean(mean(A2B(:,[5,6])))) > 0)
      %% calculate peak value of s/t at measured elevation
      el = 43.0;
      s_t_val = 1.0 * sin((2*el)/180*pi);
      %% ST, peaks of lobes at +-elevation
      if (size(B, 1) > 32)
	S_avg = mean([mean(B_power([1,9] + 16, 5)), mean(B_power([1,9] + 32, 5))]);
	T_avg = mean([mean(B_power([5,13] + 16, 6)), mean(B_power([5, 13] + 32, 6))]);
      else
	S_avg = mean([mean(B_power([1,9] + 16, 5))]);
	T_avg = mean([mean(B_power([5,13] + 16, 6))]);
      end
      S_gain = (S_avg/W_avg) * s_t_val;
      T_gain = (T_avg/W_avg) * s_t_val;
    else
      S_gain = 0.0;
      T_gain = 0.0;
    end
  else
    S_gain = 0.0;
    T_gain = 0.0;
    U_gain = 0.0;
    V_gain = 0.0;
  end
  %% normalize the A2B matrix
  if (do_Z)
    A2B(:,[2,3]) = A2B(:,[2,3]) / XY_gain;
    A2B(:,[4]) = A2B(:,[4]) / Z_gain;
  else
    A2B(:,[2,3,4]) = A2B(:,[2,3,4]) / XY_gain;
  end
  if (size(A2B, 2) > 4)
    if (abs(mean(mean(A2B(:,[5,6])))) > 0)
      printf("correct ST %f %f\n", S_gain, T_gain);
      A2B(:,[5]) = A2B(:,[5]) / S_gain;
      A2B(:,[6]) = A2B(:,[6]) / T_gain;
    end
    A2B(:,[7]) = A2B(:,[7]) / U_gain;
    A2B(:,[8]) = A2B(:,[8]) / V_gain;
  else
  end
  %% we want the W contribution of each capsule to be 1/8,
  %% so scale the whole matrix relative to mean W
  A2B(:,:) = A2B(:,:) / (mean(A2B(:, 1)) * 8);
  %% print gain scaling coefficients
  printf("XY gain: %f, Z gain: %f, ST: %f|%f, UV: %f|%f\n", XY_gain, Z_gain, S_gain, T_gain, U_gain, V_gain);
end

%%
%% Calculate A2B coefficients in logarithmic frequency bands
%%

function [A2BF FC FE] = sphear_calculate_a2b_all(SIG, M, FS, fmin, fmax, Noct, fft_size)
  %% calculate number of frequency bands spaced Noct
  n = floor(log(fmax/fmin)/log(2^(1/Noct)));
  %% adjust width of band so they fit exactly in frequency range
  N = log(2)/(log(fmax/fmin)/n);
  printf("%d frequency bands, %f bands per octave\n", n, N);

  %% first center frequency
  fcmin = fmin * 2^(1/(N * 2));
  %% all center and edge frequencies
  FC = fcmin * 2.^((0:n - 1)/N)';
  FE = fmin * 2.^((0:n)/N)';

  band = 1;
  for i = (1:size(FC))
    %% get power in band
    R = sphear_signal_power(SIG, FS, FE(i), FE(i + 1), fft_size);
    %% calculate a2b matrix in band
    [a2b pv cond] = A2B_matrix(R, M);
    A2BF(band,:,:) = a2b;
    band = band + 1;
  end
end

%%
%% Normalize A2B coefficients in all matrices
%%

function [A2BF] = sphear_normalize_a2b_all(A2BF)
  %% normalize WXYZ
  WXYZ_gain = mean(mean(mean(abs(A2BF(:,:,1:4)))));
  A2BF = A2BF ./ WXYZ_gain;
  %% and then ST/UV separately (they have different
  %% gains at the frequency of interest)
  ST_gain = mean(mean(mean(abs(A2BF(:,:,5:6)))));
  UV_gain = mean(mean(mean(abs(A2BF(:,:,7:8)))));
  A2BF(:,:,5:6) = A2BF(:,:,5:6) ./ ST_gain;
  A2BF(:,:,7:8) = A2BF(:,:,7:8) ./ UV_gain;
  printf("WXYZ gain = %f, ST gain = %f, UV gain = %f\n", WXYZ_gain, ST_gain, UV_gain);
end


%%
%% Plot coefficients of A2B matrices as a function of frequency
%%

function sphear_plot_a2b_all(FC, A2B, fmin, fmax)
  hold on;
  grid on;
  axis([fmin, fmax]);
  xticks = [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000];
  set(gca, 'XTick', xticks);
  set(gca, 'XTickLabel', sprintf('%d|', xticks));
  ca=get (gcf, "currentaxes");
  set(ca,"fontweight","bold","linewidth",1.5)
  cmap = jet(size(A2B, 2));
  %% find the max frequency bin
  ifmin = 0;
  ifmax = 0;
  for i = (1:size(A2B, 1))
    if (FC(i) <= fmax)
      ifmax = i;
    end
  end
  ifmax
  FC(ifmax)
  size(A2B, 1)
  %% plot
  semilogx(FC([1:ifmax]), 10*log10(abs(A2B([1:ifmax],:,:))), ".-", "linewidth", 1.5);
  l = legend("C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8");
  %%legend(l, 'location', 'west', 'outside');
  hold off;
end

%%%
%%% Merge 2nd order low frequency filter shape with overall filter shape
%%%

function [UC, VC] = sphear_merge_filters(FC, FE, U, V, A2BF, fmax)
  %% find max frequency index
  imax = 0;
  for f = 1:size(FC, 1)
    if (FC(f) < fmax)
      imax = f;
    end
  end
  %% merge filters below the maximum frequency
  for f = 1:size(FC, 1)
    if (FC(f) < fmax)
      for c = 1:size(A2BF, 2)
	%%UC(f,c,:) = U(f) + real(10 * log10(abs(A2BF(f,c,5) / A2BF(imax,c,5))));
	%%VC(f,c,:) = V(f) + real(10 * log10(abs(A2BF(f,c,6) / A2BF(imax,c,6))));
	UC(f,c,:) = U(f) + real(10 * log10(abs(A2BF(imax,c,5) / A2BF(f,c,5))));
	VC(f,c,:) = V(f) + real(10 * log10(A2BF(imax,c,6) / abs(A2BF(f,c,6))));
      end
    else
      for c = 1:size(A2BF, 2)
	UC(f,c,:) = U(f);
	VC(f,c,:) = V(f);
      end
    end
  end
end

%%%
%%% Plot component filters
%%%

function sphear_plot_all_filters(FC, UC, fmin, fmax)
  hold on;
  grid on;
  axis([fmin, fmax]);
  xticks = [300, 500, 1000, 2000, 3000, 5000, 7000, 10000, 15000, 20000];
  set(gca, 'XTick', xticks);
  set(gca, 'XTickLabel', sprintf('%d|', xticks));
  ca=get (gcf, "currentaxes");
  set(ca,"fontweight","bold","linewidth",1.5)
  %% find the max frequency bin
  ifmin = 0;
  ifmax = 0;
  for i = (1:size(UC, 1))
    if (FC(i) <= fmax)
      ifmax = i;
    end
  end
  %% plot
  semilogx(FC([1:ifmax]), UC([1:ifmax],:,:), ".-", "linewidth", 1.5);
  l = legend("C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8");
  %%legend(l, 'location', 'west', 'outside');
  hold off;
end

%%%
%%% Plot B format signal for three elevation measurement angles
%%%

function sphear_plot_measurements_3d(SIG, FC, FE, FS, N, freq)
  figure;
  hold on;
  axis([1, 16]);
  grid on;
  ca=get (gcf, "currentaxes");
  set(ca,"fontweight","bold","linewidth",1.5)
  %% find the approximate desired frequency band
  for f = [1:size(FC)]
    if (FC(f) <= freq)
      band = f;
    end
  end
  title(["B format power in frequency band (" sprintf("%.0f", FE(band)) " to " sprintf("%.0f", FE(band+1)) " Hz)"]);
  %% and plot the powers
  for i = [1,17,33]
    if (i < 17)
      wstyle = "ko-;W0;";
      color = "r";
      Xname = "X 0elev";
      Yname = "Y 0elev";
    else
      if (i < 33)
	wstyle = "ko--;WU;";
	color = "b";
	Xname = "X +elev";
	Yname = "Y +elev";
      else
	wstyle = "ko:;WD;";
	color = "g";
	Xname = "X -elev";
	Yname = "Y -elev";
      end
    end
    %% W
    plot(SIG((i:i+15),1,band), wstyle, "linewidth", 1.5);
    %% X/Y
    plot(SIG((i:i+15),[2],band), "color", color, sprintf("o-;%s;", Xname), "linewidth", 1.5);
    plot(SIG((i:i+15),[3],band), "color", color, sprintf("o-;%s;", Yname), "linewidth", 1.5);
    %% Z
    pZ = plot(SIG((i:i+15),4,band), "co-;Z;", "linewidth", 1.5);
  end
  legend('location', 'southwestoutside');
  hold off;
end

%%%
%%% Create X matrix for given elevation angles
%%%

function [M x y z s t u v az el] = sphear_X_matrix(n, up, down)
  eps = 0.01;
  %% create arrays of angles
  az = (0:360/n:360-eps)';
  %% map zero elevation into spherical harmonic components
  el = 0;
  for i = 1:size(az)
    x(i) = cos(az(i)/180*pi) * cos(el/180*pi);
    y(i) = sin(az(i)/180*pi) * cos(el/180*pi);
    z(i) = sin(el/180*pi);
    s(i) = cos(az(i)/180*pi) * sin((2*el)/180*pi);
    t(i) = sin(az(i)/180*pi) * sin((2*el)/180*pi);
    u(i) = cos((2*az(i))/180*pi) * cos(el/180*pi) * cos(el/180*pi);
    v(i) = sin((2*az(i))/180*pi) * cos(el/180*pi) * cos(el/180*pi);
  end
  %% map positive elevation measurements
  el = up;
  for i = 1:size(az)
    x(i + 16) = cos(az(i)/180*pi) * cos(el/180*pi);
    y(i + 16) = sin(az(i)/180*pi) * cos(el/180*pi);
    z(i + 16) = sin(el/180*pi);
    s(i + 16) = cos(az(i)/180*pi) * sin((2*el)/180*pi);
    t(i + 16) = sin(az(i)/180*pi) * sin((2*el)/180*pi);
    u(i + 16) = cos((2*az(i))/180*pi) * cos(el/180*pi) * cos(el/180*pi);
    v(i + 16) = sin((2*az(i))/180*pi) * cos(el/180*pi) * cos(el/180*pi);
  end
  %% map negative elevation measurements
  el = down;
  for i = 1:size(az)
    x(i + 32) = cos(az(i)/180*pi) * cos(el/180*pi);
    y(i + 32) = sin(az(i)/180*pi) * cos(el/180*pi);
    z(i + 32) = sin(el/180*pi);
    s(i + 32) = cos(az(i)/180*pi) * sin((2*el)/180*pi);
    t(i + 32) = sin(az(i)/180*pi) * sin((2*el)/180*pi);
    u(i + 32) = cos((2*az(i))/180*pi) * cos(el/180*pi) * cos(el/180*pi);
    v(i + 32) = sin((2*az(i))/180*pi) * cos(el/180*pi) * cos(el/180*pi);
  end
  %% return big matrix of projections
  M = [x' y' z' s' t' u' v'];
end

%%%
%%% Create X matrix for given azimuth and elevation angles
%%%

function [M x y z s t u v] = sphear_az_el_to_X_matrix(az, el, order = 1)
  for i = 1:size(az)
    x(i) = cos(az(i)) * cos(el(i));
    y(i) = sin(az(i)) * cos(el(i));
    z(i) = sin(el(i));
    if (order > 1)
      s(i) = cos(az(i)) * sin(2*el(i));
      t(i) = sin(az(i)) * sin(2*el(i));
      u(i) = cos(2*az(i)) * cos(el(i)) * cos(el(i));
      v(i) = sin(2*az(i)) * cos(el(i)) * cos(el(i));
    end
  end
  %% return big matrix of projections
  x = x'; y = y'; z = z';
  if (order > 1)
    s = s'; t = t'; u = u'; v = v';
  end
  if (order > 1)
    M = [x y z s t u v];
  else
    M = [x y z];
  end
end

%%%
%%% Fractional delay
%%%
%%% based on:
%%% http://www.labbookpages.co.uk/audio/beamforming/fractionalDelay.html
%%%
%%% Also:
%%% http://users.spa.aalto.fi/vpv/publications/vesan_vaitos/ch3_pt1_fir.pdf
%%%
%%% N = length of sinc function (should be odd)

function [SINC] = sphear_delayed_sinc(N, delay)
  center = floor(N / 2);
  for t = (1:N)
    x = (t - 1) - delay;
    window = 0.54 - 0.46 * cos(2.0 * pi * (x + 0.5) / N);
    SINC(t) = sinc(x - center) * window;
  end
end

function [DSIG FIR] = sphear_delay_signal(SIG, delay, N, fft_size)
  FIR = sphear_delayed_sinc(N, delay);
  for m = [1:size(SIG, 1)]
    for c = [1:size(SIG, 2)]
      %% we add trailing zeros to let the filter ring
      DSIG(m, c, :) = fftfilt(FIR, cat(1, reshape(SIG(m, c, :), 1, [])', zeros(2*size(FIR, 2), 1))', fft_size)(round(N/2):end);
    end
  end
end

%%%
%%% Fix wobble delays in a set of measurements
%%%

function [FIXED] = sphear_fix_wobble(SIG, DELAY);
  sinc_size = 1023;
  min_delay = min(DELAY);
  DELAY = DELAY - min_delay;
  max_delay = max(DELAY);
  for m = [1:size(DELAY, 1)]
    %% delay = max_delay - DELAY(m);
    delay = DELAY(m);

%%    if (delay >= 1)
%%      i_delay = floor(delay);
%%      f_delay = mod(delay, 1.0);
%%      printf("m: %d, delay: %f, integer %f, frac %f\n", m, delay, i_delay, f_delay);
%%      FIXED(m,:,:) = zeros(size(SIG, 3));
%%      FIXED(m,:,[i_delay:end]) = SIG(m,:,[1:end - i_delay])
%%      FIXED(m,:,:) = sphear_delay_signal(FIXED(m,:,:), f_delay, sinc_size, 8192);
%%    else
      printf("m: %d, delay: %f\n", m, delay);
      FIXED(m,:,:) = sphear_delay_signal(SIG(m,:,:), delay, sinc_size, 8192);
%%    end
  end
end

%%%
%%% Fast convolution using external fconvolver program
%%%
%%% SIG = recorded sweep file path
%%% SWEEP = inverse sweep file path

function [IR] = fconvolver(IN, ISWEEP);
  %% make temporary file name from input file
  [dir, infile, ext] = fileparts(IN);
  outfile = strcat(infile, "_out", ext);
  %% write an fconvolver configuration file
  cfile = ".fconvolver.cfg";
  cfg = fopen(cfile, 'w');
  %% /convolver/new  <inputs> <outputs> <partition size> <maximum impulse length>
  fprintf(cfg, '/convolver/new 1 1 1024 1000000\n');
  %% /impulse/read   <input> <output> <gain> <delay> <offset> <length> <channel> <file>
  fprintf(cfg, '/impulse/read 1 1 1.0 0 0 0 1 %s\n', ISWEEP);
  fclose(cfg);
  %% run convolution
  system(sprintf("fconvolver .fconvolver.cfg %s %s\n", IN, outfile));
  %% remove temporary configuration file
  unlink(cfile);
  %% load and return impulse response
  IR = wavread(outfile);
  unlink(outfile);
end

%%%
%%% Do a basic encoder design, static A2B matrix plus FIR filters
%%%

function [BFF A2B FIR W X Y Z U V] = sphear_calculate_design(fref_min, fref_max)
  fft_size = 8192;
  N_oct = 16;
  %% read in data
  [AF, FS] = sphear_af_read((1:16));
  %% power in reference band
  [R] = sphear_signal_power(AF, FS, fref_min, fref_max, fft_size);
  %% static A2B matrix
  [A2B, PV, COND] = sphear_calculate_a2b(R);
  %% generate a B-format signal
  [BF] = sphear_af_to_bf(AF, A2B);
  %% calculate power of B-format signals
  [B, FC, FE] = sphear_signal_power_all(BF, FS, 300, 20000, fref_min, fref_max, N_oct, fft_size);
  %% extract the shapes of wxyz[uv] filters
  %% average response in cardinal directions
  [W X Y Z U V] = sphear_bf_extract_filter_shapes(B, 0);
  %% design FIR filters
  [FIR IR MPS] = sphear_design_fir_filters(FC, 512, FS, W, X, Y, Z, U, V, 400, 18, -10);
  %% re-calculate the full B-format signal with the filters
  [BF, BFF] = sphear_af_to_bf(AF, A2B, FIR, fft_size);
  %% get the average power in the directions of the lobes for W, XY and UV
  %% and normalize the A2B matrix so that ZY and UV have the same peak amplitude
  %% as W
  [A2B XY_gain UV_gain] = sphear_bf_normalize_gain(A2B, BFF, FS, fref_min, fref_max, fft_size);
  %% re-calculate the B-format signal
  [BF, BFF] = sphear_af_to_bf(AF, A2B, FIR, fft_size);
end

