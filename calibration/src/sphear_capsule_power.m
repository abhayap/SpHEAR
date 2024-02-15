%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_capsule_power: return sorted array of power for capsule measurements
%%
%% usage:
%%   [R Fs] = sphear_af_power(measurements, fmin, fmax, N, Npre)
%%
%% measurements: list of measurements to consider
%% fmin, fmax: range of frequencies to consider
%% Npre: number of samples before the main impulse
%% N: total number of samples to analyze
%%
%% The name of capsule measurement files iscurrently hardwired into this
%% file, this needs to be fixed and turned into input parameters
%%
%% Copyright Fernando Lopez-Lezcano 2016-2018
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

function [RS Fs] = sphear_capsule_power(measurements, fmin, fmax, Nfft, Npre, Npost)
  pkg load signal;

  capname = "EM200";
  onames = cellstr(['001'; '002']);

  %% all submitted measurements
  i = 1;
  for m = measurements
    %% orientation
    for o = [1, 2]

      printf("%s\n", ["../data/current/" capname "/export/capsule-" sprintf("%02.0f", m) "-" char(onames(o)) "-1.wav"]);

      if (exist(["../data/current/" capname "/export/capsule-" sprintf("%02.0f", m) "-"  char(onames(o)) "-1.wav"]))
	[capsule, Fs] = wavread(["../data/current/" capname "/export/capsule-" sprintf("%02.0f", m) "-"  char(onames(o)) "-1.wav"]);

	%% indexes in array for frequency bins
	imin = round((Nfft/2) * fmin / (Fs/2));
	imax = round((Nfft/2) * fmax / (Fs/2));

	%% find peak for this measurement
	[peaks, locs] = findpeaks(abs(capsule));
	[~, index] = max(peaks);
	start = locs(index) - Npre;
	range = start:(start + Npost);
	fdom = fft(capsule(range), Nfft);

	%% return total power in dB of signal in frequency range
	R(i, o) = 20*log10(sqrt(sum(fdom(imin:imax).*conj(fdom(imin:imax)))/(imax - imin)));
      else
	printf("missing capsule %d\n", m);
	R(i, o) = -100;
      end
    end
    %% add 0 to 90 degree difference in dB (front to side ratio)
    R(i, 3) = R(i, 1) - R(i, 2);
    if (i > 1)
      R(i, 4) = R(i, 3) - R(i - 1, 3);
    else
      R(i, 4) = 0;
    end
    R(i, 5) = i;
    i = i + 1;
  end
  printf("calculating results...\n");
  avg = mean(R(:,1));
  R(:,1) = R(:,1) - avg;
  R(:,2) = R(:,2) - avg;
  %% sort the results by directivity
  [RS, I] = sort(R'(3,:));
  %% sort the results by 0 degree gain
  %%[RS, I] = sort(R'(1,:));
  RS = R'(:,I)';
  %% calculate the derivative of directivity
  i = 1;
  for m = measurements
    if (i > 1)
      RS(i, 4) = RS(i, 3) - RS(i - 1, 3);
    else
      RS(i, 4) = 0;
    end
    %% add an index for plots
    RS(i, 6) = i;
    i = i + 1;
  end
end

