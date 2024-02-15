%%
%% *SpHEAR Project
%%
%% sphear_a_power: return array of power for WXYZ B format signals in a range of frequencies
%%
%% usage:
%%   [B Fs] = sphear_wxyz_power(measurements, fmin, fmax, N, Npre, Nfft, plotz)
%%
%% measurements: measurements to consider
%% fmin, fmax: range of frequencies to consider
%% N: total number of samples to analyze
%% Npre: number of samples before the main impulse
%% Nfft: size of fft
%% plotz: 0 -> plot cardioid, 1 -> plot Z
%%
%% The names of reference microphone impulse response and capsule measurements are
%% currently hardwired into this file, this needs to be fixed and turned into
%% parameters
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

function [B Fs] = sphear_wxyz_power(measurements, fmin, fmax, N, Npre, Nfft, plotz)

  %% read in reference microphone, select samples to process
  [ref, Fs] = wavread('../data/2016.08.03/st250/reference-001-1.wav');
  [peaks, locs] = findpeaks(abs(ref));
  [~, index] = max(peaks);
  start = locs(index) - Npre;
  range = start:(start + N - 1);
  ref_fft = fft(ref(range), Nfft);
  
  %% indexes in array for frequency bins
  imin = round((N/2) * fmin / (Fs/2));
  imax = round((N/2) * fmax / (Fs/2));

  %% name of B format components
  bnames = cellstr(['W'; 'X'; 'Y'; 'Z']);

  %% all measurements
  for m = measurements
    %% all components
    for c = 1:4
      %% all b format components, 4 channel soundfile
      bsignal = wavread(["../data/2016.08.03/st250/b-format-0" sprintf("%02.0f", m)  "-" char(bnames(c)) ".wav"]);
      if (c == 1)
	%% FUMA to SN3D for W
	bsignal = bsignal / 0.707;
      end
      bfft = fft(bsignal(range), Nfft) ./ ref_fft;
      if (plotz == 0)
	%% calculate a forward facing cardiod
	cfft = (fft(bsignal(range) + 1.0 * bsignal(range), Nfft)) ./ ref_fft;
      end
      %% return total power of signal in frequency range
      B(m, c) = sqrt(sum(bfft(imin:imax,:).*conj(bfft(imin:imax,:)))/size(bfft(imin:imax,:),1));
      %% make a cardiod if we don't want Z
      if (c == 4)
	if (plotz == 0)
	  B(m, 4) = sqrt(sum(cfft(imin:imax).*conj(cfft(imin:imax)))/size(cfft(imin:imax),1)) / 2.0;
	end
      end
    end
  end
end

