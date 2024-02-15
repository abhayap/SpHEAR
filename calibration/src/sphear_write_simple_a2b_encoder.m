%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_write_a2b_encoder: write simple Faust code for an A format to B format converter
%%                           (static A to B matrix plus 4 FIR filters, one of each B component)
%%
%% usage:
%%   [] = sphear_write_simple_a2b_encoder(A2B, FIR)
%%
%% A2B: static A to B matrix
%% FIR: FIR filter matrix
%%
%% Copyright 2017, Fernando Lopez-Lezcano, All Rights Reserved
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

function [] = sphear_write_simple_a2b_encoder(A2B, FIR, name = "A2B_encoder", faust_version = 2)

  filename = strcat('../data/current/cal/', name, '.dsp');
  [file, msg] = fopen(filename,'w');
  if msg
    error([msg ': ' filename]);
  end

  fprintf(file, strcat('declare name "', name, '";\n'));
  fprintf(file, 'declare version "1.0";\n');
  fprintf(file, 'declare author "Fernando Lopez-Lezcano";\n');
  fprintf(file, 'declare license "GPL";\n');
  fprintf(file, 'declare copyright "(c) Fernando Lopez-Lezcano 2016-17";\n\n');

  %% write beginning of file...
  if (faust_version == 2)
    fprintf(file, 'import("stdfaust.lib");\n');
    fprintf(file, '\n');
    firname = "fi.fir";
  else
    fprintf(file, 'import("filter.lib");\n');
    fprintf(file, 'import("music.lib");\n');
    fprintf(file, 'import("oscillator.lib");\n');
    fprintf(file, '\n');
    firname = "fir";
  end

  bnames = cellstr(['w'; 'x'; 'y'; 'z'; 's'; 't'; 'u'; 'v']);

  %% write static A to B matrix rows
  fuma = [sqrt(2)/2, 1, 1, 1, 1, 1, 1, 1];
  for a = 1:size(A2B,1)
    for b = 1:size(FIR, 1)
      fprintf(file, ["a" sprintf("%d", a) char(bnames(b)) " = "]);
      write_faust_vector(file, fuma(b) * A2B(a, b));
      fprintf(file, ';\n');
    end
  end
  fprintf(file, '\n');
  
  %% write FIR filter coefficients
  for b = 1:size(FIR,1)
    bf_filter = reshape(FIR(b, :), 1, []);
    fprintf(file, [char(bnames(b)) "_fir = "]);
    write_faust_vector(file, bf_filter);
    fprintf(file, ';\n\n');
  end
  
  %% be done with it...
  if (size(A2B,1) == 4)
    fprintf(file, 'process = _,_,_,_ <: w*gain, x*gain, y*gain, z*gain \n');
  else
    %% assume 8 input channels for now
    if (size(A2B,2) > 4)
      %% add second order horizontal
      if (mean(mean(A2B(:,[5,6]))) > 0)
	%% STUV
	fprintf(file, 'process = _,_,_,_,_,_,_,_ <: w*gain, x*gain, y*gain, z*gain, s*gain, t*gain, u*gain, v*gain \n');
      else
	% UV
	fprintf(file, 'process = _,_,_,_,_,_,_,_ <: w*gain, x*gain, y*gain, z*gain, u*gain, v*gain \n');
      end
    else
      fprintf(file, 'process = _,_,_,_,_,_,_,_ <: w*gain, x*gain, y*gain, z*gain \n');
    end
  end
  fprintf(file, 'with {\n');
  if (size(A2B,1) == 4)
    fprintf(file, sprintf('     w = *(a1w), *(a2w), *(a3w), *(a4w) :> %s(w_fir) ;\n', firname));
    fprintf(file, sprintf('     x = *(a1x), *(a2x), *(a3x), *(a4x) :> %s(x_fir) ;\n', firname));
    fprintf(file, sprintf('     y = *(a1y), *(a2y), *(a3y), *(a4y) :> %s(y_fir) ;\n', firname));
    fprintf(file, sprintf('     z = *(a1z), *(a2z), *(a3z), *(a4z) :> %s(z_fir) ;\n', firname));
  else
    fprintf(file, sprintf('     w = *(a1w), *(a2w), *(a3w), *(a4w), *(a5w), *(a6w), *(a7w), *(a8w) :> %s(w_fir) ;\n', firname));
    fprintf(file, sprintf('     x = *(a1x), *(a2x), *(a3x), *(a4x), *(a5x), *(a6x), *(a7x), *(a8x) :> %s(x_fir) ;\n', firname));
    fprintf(file, sprintf('     y = *(a1y), *(a2y), *(a3y), *(a4y), *(a5y), *(a6y), *(a7y), *(a8y) :> %s(y_fir) ;\n', firname));
    fprintf(file, sprintf('     z = *(a1z), *(a2z), *(a3z), *(a4z), *(a5z), *(a6z), *(a7z), *(a8z) :> %s(z_fir) ;\n', firname));
    if (size(A2B,2) > 4)
      %% add second order horizontal
      if (mean(mean(A2B(:,[5,6]))) > 0)
	fprintf(file, sprintf('     s = *(a1s), *(a2s), *(a3s), *(a4s), *(a5s), *(a6s), *(a7s), *(a8s) :> %s(s_fir) ;\n', firname));
	fprintf(file, sprintf('     t = *(a1t), *(a2t), *(a3t), *(a4t), *(a5t), *(a6t), *(a7t), *(a8t) :> %s(t_fir) ;\n', firname));
	fprintf(file, sprintf('     u = *(a1u), *(a2u), *(a3u), *(a4u), *(a5u), *(a6u), *(a7u), *(a8u) :> %s(u_fir) ;\n', firname));
	fprintf(file, sprintf('     v = *(a1v), *(a2v), *(a3v), *(a4v), *(a5v), *(a6v), *(a7v), *(a8v) :> %s(v_fir) ;\n', firname));
      else
	fprintf(file, sprintf('     u = *(a1u), *(a2u), *(a3u), *(a4u), *(a5u), *(a6u), *(a7u), *(a8u) :> %s(u_fir) ;\n', firname));
	fprintf(file, sprintf('     v = *(a1v), *(a2v), *(a3v), *(a4v), *(a5v), *(a6v), *(a7v), *(a8v) :> %s(v_fir) ;\n', firname));
      end
    end
  end
  fprintf(file, '     gain = hslider("Gain",1,0,1,0.01);\n');
  fprintf(file, '};\n');
  fprintf(file, '\n');
  fclose(file);
end

function [] = write_faust_vector(file, v)
  v = v(:);
  fprintf(file, '(');
  fprintf(file, '% 14.10g,', v(1:end-1));
  fprintf(file, '% 14.10g)', v(end));
end
