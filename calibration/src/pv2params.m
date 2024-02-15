%%
%% Copyright 2007, Aaron Heller, All Rights Reserved
%% heller@ai.sri.com
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

function pv2params (pv)
  fprintf('mic\t sens\t dir\t fbr\t az\t el\n');
  for i = 1:size(pv,1)
    p = pv(i,1);
    v = pv(i,2:4);
    s = ( p + norm(v) )/ 2;
    d = norm(v) / ( norm(v) + p );
    fbr = (p+norm(v)) / (p-norm(v));
    fbr_sign = sign(fbr);
    fbr_dB = 20 * log10( abs(fbr) );
    o = v / norm(v);
    az_el_rad = [ atan2( o(2), o(1) ) asin( o(3) ) ];
    az_el_deg = 180/pi * az_el_rad;
    fprintf('%5g\t %5g\t %5g\t %5g\t %5g\t %5g\n', ...
	    i, s, d, fbr_dB, az_el_deg(1), az_el_deg(2));
  end
end
