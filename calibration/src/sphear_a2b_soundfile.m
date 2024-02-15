%%
%% *SpHEAR Project
%% sphear_a2b_soundfile: read in A format soundfiles and render B format outputs
%%
%% usage:
%%   [] = sphear_a2b_soundfile(FIR, ifile, ofile, start, duration, Fs, Nfft)
%%
%% FIR: A2B matrix of FIR filters
%% ifile: input soundfile (first four channels are the A-format signal)
%% ofile: output soundfile, currently ignored
%% start: start time in seconds from the beginning of the file
%% duration: duration in seconds of processed segment
%% Fs: sampling rate
%% Nfft: size of the FFT used to do the filtering
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

function [BF] = sphear_a2b_soundfile(FIR, ifile, ofile, start, duration, Fs, Nfft)

  [AF, FS, BPS] = wavread(ifile, [start, (start + duration)] .* Fs);
  printf("sr = %d, bits = %d\n", FS, BPS);

  w1 = fftfilt(reshape(FIR(1,1,:), 1, [])', AF(:,1), Nfft);
  x1 = fftfilt(reshape(FIR(2,1,:), 1, [])', AF(:,1), Nfft);
  y1 = fftfilt(reshape(FIR(3,1,:), 1, [])', AF(:,1), Nfft);
  z1 = fftfilt(reshape(FIR(4,1,:), 1, [])', AF(:,1), Nfft);
  
  w2 = fftfilt(reshape(FIR(1,2,:), 1, [])', AF(:,2), Nfft);
  x2 = fftfilt(reshape(FIR(2,2,:), 1, [])', AF(:,2), Nfft);
  y2 = fftfilt(reshape(FIR(3,2,:), 1, [])', AF(:,2), Nfft);
  z2 = fftfilt(reshape(FIR(4,2,:), 1, [])', AF(:,2), Nfft);
  
  w3 = fftfilt(reshape(FIR(1,3,:), 1, [])', AF(:,3), Nfft);
  x3 = fftfilt(reshape(FIR(2,3,:), 1, [])', AF(:,3), Nfft);
  y3 = fftfilt(reshape(FIR(3,3,:), 1, [])', AF(:,3), Nfft);
  z3 = fftfilt(reshape(FIR(4,3,:), 1, [])', AF(:,3), Nfft);
  
  w4 = fftfilt(reshape(FIR(1,4,:), 1, [])', AF(:,4), Nfft);
  x4 = fftfilt(reshape(FIR(2,4,:), 1, [])', AF(:,4), Nfft);
  y4 = fftfilt(reshape(FIR(3,4,:), 1, [])', AF(:,4), Nfft);
  z4 = fftfilt(reshape(FIR(4,4,:), 1, [])', AF(:,4), Nfft);

  wc = (w1 + w2 + w3 + w4) ./ (sqrt(2)/2);
  xc = (x1 + x2 + x3 + x4);
  yc = (y1 + y2 + y3 + y4);
  zc = (z1 + z2 + z3 + z4);

  BF(:,1) = wc;
  BF(:,2) = xc;
  BF(:,3) = yc;
  BF(:,4) = zc;

  att = 0.005;
  wavwrite(BF * att, Fs, 32, ["mattness-b-format-w.wav"]);
  
end
