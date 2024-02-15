%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_af_octa_calibrate_all: read all raw impulse response sweep
%%         measurements, convolve with the inverse sweep to calculate
%%         the impulse response, pre-trim the impulse, convolve with
%%         the speaker inverse filter (calculated with DRC), trim to
%%         eliminate the first reflection and beyond, window with a
%%         blackman window
%%
%% usage:
%%   [] = sphear_af_octa_calibrate_all(path, first)
%%
%% path: path to measurements, defaults to "../data/current/"
%% first: first reflection arrival time in seconds referenced to peak
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

function [] = sphear_octa_af_calibrate_measurements(path, first);
  if (strcmp(path, ""))
    path = "../data/current/";
  end
  %% location of sweep exported from aliki
  sweep_path = strcat(path, "export/sweep-001-F.wav");
  %% location of reverse sweep as exported from aliki
  rsweep_path = strcat(path, "export/sweep-001-I.wav");
  %% read sweep for file length
  [sweep, FS] = wavread(sweep_path);
  %%
  %% calculate impulse response of reference microphone
  %%
  printf("processing reference sweep\n");
  %% XXXX ref_ir = fconvolver(strcat(path, "capture/REF-001.wav"), rsweep_path);
  ref_ir = fconvolver(strcat(path, "capture/reference-001.wav"), rsweep_path);
  %% trim to exclude first reflections
  printf("finding peak...\n");
  [amps, locs, widths, residue] = sphear_findpeaks(abs(ref_ir), 10);
  %% now trim the ir (symmetric) to just before the first reflection
  ref_ir_trim = ref_ir(round(locs(1)) - (first*FS):(round(locs(1)) + (first*FS)));
  %% apply a blackman window
  ref_win = blackman(size(ref_ir_trim, 1));
  ref_ir_win = ref_ir_trim .* ref_win;
  %% and write it
  wavwrite(ref_ir_win, 24, strcat(path, "cal/reference-001-1.wav"));
  %% read inverse filter for the speaker
  %% this has to be calculated from the reference impulse response above...
  %% we need to recognize this and print a message so that this is run twice...
  ref = wavread(strcat(path, "cal/drc-filter.wav"));
  %% read measurement index file
  [measurements, azims, elevs, files] = textread(strcat(path, "capture/index.txt"), "%d %f %f %s");
  %% process all files
  for measurement = 1:size(measurements);
    printf("processing measurement %d, az=%f, el=%f, %s\n", measurement, azims(measurement), elevs(measurement), files(measurement){1,1});
    af = wavread(strcat(path, "capture/", regexprep(files(measurement){1,1}, "\"", "")));
    for capsule = 1:size(af, 2);
      %% process each capsule
      printf("  capsule %d\n", capsule);
      raw = strcat(path, "af/", "a-format-", sprintf("%.3d-%d.wav", measurement, capsule));
      wavwrite(af(:,capsule), FS, 24, raw);
      %% convolve captured data with reverse sweep and get ir
      printf("  convolving...\n");
      ir = fconvolver(raw, rsweep_path);
      %% trim to the valid region
      ir = ir(numel(sweep):numel(sweep)+numel(af(:,capsule)));

      %% FOR TESTING
      %% write raw impulse to file
      raw_file = strcat(path, "raw/", "a-format-", sprintf("%.3d-%d.wav", measurement, capsule));
      printf("  writing %s\n", raw_file);
      wavwrite(ir, FS, 24, raw_file);
      
      %% discard most of the impulse response data around the main peak,
      %% can be much shorter (almost down to the first reflection)
      trim = 0.050;
      if (measurement == 1 && capsule == 1)
	%% only find the peak in the first measurement and first capsule,
	%% we maintain the same trim after that to preserve the timing
	%% of all capsules and measurements
	[amps, locs, widths, residue] = sphear_findpeaks(abs(ir), 10);
      end
      ir_trim = ir(round(locs(1)) - (trim*FS):(round(locs(1)) + (trim*FS)));
      %% equalize ir with inverse filter for speaker
      ir_eq = conv(ir_trim, ref);
      if (measurement == 1 && capsule == 1)
	%% and find main peak for first measurement and capsule
	[eamps, elocs, ewidths, eresidue] = sphear_findpeaks(abs(ir_eq), 10);
      end
      %% now trim the ir (symmetric) to just before the first reflection
      ir_eq_trim = ir_eq(round(elocs(1)) - (first*FS):(round(elocs(1)) + (first*FS)));
      %% apply a blackman window
      win = blackman(size(ir_eq_trim, 1));
      ir_eq_win = ir_eq_trim .* win;
      %% write calibrated ir to file
      cal_file = strcat(path, "cal/", "a-format-", sprintf("%.3d-%d.wav", measurement, capsule));
      printf("  writing %s\n", cal_file);
      wavwrite(ir_eq_win, FS, 24, cal_file);
      ir_eq_win_all(:,capsule) = ir_eq_win;
    end
    %% write a multichannel version of the calibrated impulse response file
    %% all_file = strcat(path, "cal/", "a-format-", sprintf("%.3d.wav", measurement));
    %% printf("  writing %s\n", all_file);
    %% wavwrite(ir_eq_win_all, FS, 24, all_file);
  end
end
