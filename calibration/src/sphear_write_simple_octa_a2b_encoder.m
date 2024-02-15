%% -*- mode: octave -*-
%%
%% *SpHEAR Project
%%
%% sphear_write_simple_octa_a2b_encoder: write example Faust code for an A format to B format converter
%%
%% capsule equalization filters -> A to B matrix -> B format equalization filters
%%
%% usage:
%%   [] = sphear_write_simple_octa_a2b_encoder(CFIR, A2B, FIR)
%%
%% CFIR: FIR capsule equalization filters
%% A2B: static A to B matrix
%% FIR: FIR filter matrix
%%
%% Copyright 2017-2018, Fernando Lopez-Lezcano, All Rights Reserved
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

%%
%% FUMA to ACN conversion
%% https://sursound.music.vt.narkive.com/gaA7EHw6/fuma-to-acn-conversion
%% posted by Fons in the same thread:
%%
%% If you want to check the conversion factors FuMa -> SN3D:
%% 
%% W 1.414214 sqrt(2)
%% 
%% X 1
%% Y 1
%% Z 1
%% 
%% R 1
%% S 0.866025 sqrt(3)/2
%% T id
%% U id
%% V id

function [] = sphear_write_simple_octa_a2b_encoder(CFIR, A2B, FIR, name = "A2B_encoder", serial = 0, faust_version = 2, create_r = 1, fuma = 1)

  filename = strcat('../data/current/cal/', name, '.dsp');
  [file, msg] = fopen(filename,'w');
  if msg
    error([msg ': ' filename]);
  end

  printf("writing A to B encoder, name is \"%s\", for Faust version %d, serial #%d, create R is %d, FUMA is %d\n", name, faust_version, serial, create_r, fuma);
  printf("path:\n    %s\n", filename);
  printf("absolute path:\n    %s/%s\n", pwd, filename);
  
  fprintf(file, strcat('declare name "', name, '";\n'));
  if (serial > 0)
    proto_str = sprintf("_#%d", serial);
  else
    proto_str = "";
  end
  if (fuma == 1)
    order_str = "_FUMA";
  else
    order_str = "_ACN";
  end
  fprintf(file, 'declare version "1.0%s%s";\n', order_str, proto_str);
  fprintf(file, 'declare author "Fernando Lopez-Lezcano";\n');
  fprintf(file, 'declare license "GPL";\n');
  fprintf(file, 'declare copyright "(c) Fernando Lopez-Lezcano 2016-18";\n\n');

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

  cnames = cellstr(['c1'; 'c2'; 'c3'; 'c4'; 'c5'; 'c6'; 'c7'; 'c8']);

  %% write capsule equalization FIR filter coefficients
  printf("writing capsule fir filters...\n");
  for b = 1:size(CFIR,1)
    bf_filter = reshape(CFIR(b, :), 1, []);
    fprintf(file, [char(cnames(b)) "_fir = "]);
    write_faust_vector(file, bf_filter);
    fprintf(file, ';\n\n');
  end
  
  %% write static A to B matrix rows
  printf("writing static A to B matrix...\n");
  if (fuma == 1)
    %% FUMA weights applied to WXYZSTUV
    scl = sqrt(2)/2;
    weights = [scl, 1, 1, 1, 1, 1, 1, 1];
  else
    %% SN3D weights applied to WXYZSTUV
    scl = sqrt(3)/2;
    weights = [1, 1, 1, 1, scl, scl, scl, scl];
  end
  
  for a = 1:size(A2B,1)
    for b = 1:size(FIR, 1)
      fprintf(file, ["a" sprintf("%d", a) char(bnames(b)) " = "]);
      write_faust_vector(file, weights(b) * A2B(a, b));
      fprintf(file, ';\n');
    end
  end
  fprintf(file, '\n');
  
  %% write FIR filter coefficients
  printf("writing B format fir filters...\n");
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
      printf("octasphear 2nd order...\n");
      %% add second order horizontal
      if (mean(mean(abs(A2B(:,[5,6])))) > 0)
	printf("octasphear full 2nd order...\n");
	%% full second order encoder
	%%
	%% expander for second order components
	%%
	%% from the guitarfx project:
	%% http://q-lang.sourceforge.net/examples.html#Faust
	%%
	fprintf(file, '    exp_group(x) = vgroup("[2]2nd Order Expander", x);\n');
	fprintf(file, '    threshold = exp_group(nentry(\"[0]Exp Threshold (dB)\", -45, -96, 10, 0.1) : smooth(tau2pole(t)));\n');
	%% add a display of the W derived level that triggers the expander
	fprintf(file, '    exp_control = hbargraph("[1]Exp Control [unit:dB]",-96,0);\n');
	fprintf(file, '    exp_hpf_freq = exp_group(nentry(\"[2]Exp HPF (Hz)\", 300, 60, 600, 0.1) : smooth(tau2pole(t)));\n');
	fprintf(file, '    ratio = exp_group(nentry(\"[3]Exp Ratio\", 2, 1, 20, 0.1));\n');
	fprintf(file, '    knee = exp_group(nentry(\"[4]Exp Knee\", 3, 0, 20, 0.1));\n');
	fprintf(file, '    attack = exp_group(hslider(\"[5]Exp Attack\", 0.001, 0, 1, 0.001) : max(1/SR));\n');
	fprintf(file, '    release = exp_group(hslider(\"[6]Exp Release\", 0.1, 0, 10, 0.01) : max(1/SR));\n');
	
	fprintf(file, '    t = 0.1;\n');
	fprintf(file, '    g = exp(-1/(SR*t));\n');
	fprintf(file, '    env = abs : *(1-g) : + ~ *(g);\n');
	fprintf(file, '    rms = sqr : *(1-g) : + ~ *(g) : sqrt;\n');
	fprintf(file, '    sqr(x) = x*x;\n');

	fprintf(file, '    env2(x) = max(x, env(x));\n');
	fprintf(file, '    expand(env) = level*(1 - r)\n');
	fprintf(file, '    with {\n');
	fprintf(file, '        level = env : h ~ _ : linear2db : (threshold+knee-_) : max(0)\n');
	fprintf(file, '        with {\n');
	fprintf(file, '            h(x,y) = f*x+(1-f)*y with { f = (x<y)*ga+(x>=y)*gr; };\n');
	fprintf(file, '            ga = exp(-1/(SR*attack));\n');
	fprintf(file, '            gr = exp(-1/(SR*release));\n');
	fprintf(file, '        };\n');
	fprintf(file, '        p = level/(knee+eps) : max(0) : min(1) with { eps = 0.001; };\n');
	fprintf(file, '        r = 1-p+p*ratio;\n');
	fprintf(file, '    };\n');
	fprintf(file, '    expand_gain(x) = env2(x : highpass(4, exp_hpf_freq)) : expand : exp_control : db2linear;\n');
	fprintf(file, '\n');

	%% (R)STUV
	if (create_r == 1)
	  r_str = " r,";
	else
	  r_str = "";
	end
	if (fuma == 1)
	  %% define FUMA order (WXYZRSTUV)
	  out_str = sprintf("w*gain, x*gain, y*gain, z*gain,%s s*gain*w_exp, t*gain*w_exp, u*gain*w_exp, v*gain*w_exp", r_str);
	else
	  %% define ACN order (WYZXVTRSU)
	  out_str = sprintf("w*gain, y*gain, z*gain, x*gain, v*gain*w_exp, t*gain*w_exp,%s s*gain*w_exp, u*gain*w_exp", r_str);
	end
	fprintf(file, 'process = _,_,_,_,_,_,_,_ : hpf, hpf, hpf, hpf, hpf, hpf, hpf, hpf : (%s(c1_fir)), (%s(c2_fir)), (%s(c3_fir)), (%s(c4_fir)), (%s(c5_fir)), (%s(c6_fir)), (%s(c7_fir)), (%s(c8_fir)) <: %s \n', firname, firname, firname, firname, firname, firname, firname, firname, out_str);
      else
	% UV
	fprintf(file, 'process = _,_,_,_,_,_,_,_ <: w*gain, x*gain, y*gain, z*gain, u*gain, v*gain \n');
      end
    else
      %% first order only, fuma only for now
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
      if (mean(mean(abs(A2B(:,[5,6])))) > 0)
	%% R is always zero for this array
	if (create_r == 1)
	  fprintf(file, sprintf('     r = 0.0 ;\n', firname));
	end
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
  if (size(A2B,2) > 4)
    %% add expander reading W as control signal
    fprintf(file, '    w_exp = expand_gain(w) ;\n');
  end
  %% global gain, should be in dB
  fprintf(file, '    gain = hslider("[0]Gain (dB)",0,-12,6,0.01) : db2linear : smooth(tau2pole(0.1));\n');
  %% low frequency high pass filter, four pole
  fprintf(file, '    hpf_freq = hslider("[1]HPF Freq (Hz)", 30, 10, 300, 0.1) : smooth(tau2pole(0.1));\n');
  fprintf(file, '    hpf = highpass(4, hpf_freq);\n');
  %% end of parameters
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
