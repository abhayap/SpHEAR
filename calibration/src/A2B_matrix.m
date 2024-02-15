%% -*- mode: octave -*-
%%
%% Copyright 2007, Aaron Heller, All Rights Reserved
%% heller@ai.sri.com
%%
%% Octathingy first and second order code:
%% Copyright 2017, Fernando Lopez-Lezcano
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

function [A2B pv max_err] = A2B_matrix(Y, X, v_z_factor)
  % fit 4x4 matrix to measured mic data
  %
  % Y is the n x m matrix of measurements (’observations’),
  % n is number of measurement directions
  % m is number of microphones
  % X is the n x 3 matrix of are the direction cosines of the
  % measurment directions (’predictor variables’)
  % pv is the matrix of unknowns to be estimated
  % so Y = X pv
  if (nargin < 2 )
    X = measurement_dirs_z0(Y);
  end
  X1 = [ ones(size(Y,1), 1) X ];
  pv = X1 \ Y;
  max_err = max (Y - (X1 * pv));
  %% fill in Z projections if needed
  if(sum((X1(:,4))==0) > 0)
    pv = fill_v_z( pv );
  end
  if (size(Y, 2) > 4)
    ipv = pinv(pv');
    if (size(pv, 1) > 6)
      %% W X Y Z S T U V
      A2B = ([1 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 0; 0 0 0 1 0 0 0 0;
	      0 0 0 0 1 0 0 0; 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 1] * ipv)';
    else
      %% W X Y Z U V
      A2BI = ([1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1] * ipv)';
      %% fill in S/T components with zeros
      A2B(:,[1,2,3,4]) = A2BI(:,[1,2,3,4]);
      A2B(:,[5,6]) = zeros(8, 2);
      A2B(:,[7,8]) = A2BI(:,[5,6]);
    end
  else
    %% W X Y Z
    A2B = ([1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] \ pv)';
  end
end

function X = measurement_dirs_z0(Y)
  n = size(Y, 1);
  if (nargin < 1)
    n = 8;
  end
  x_range = 0 : 2*pi/n : 2*pi*(n-1)/n;
  if (size(Y, 2) > 4)
    %% add second order horizontal components
    u_range = [(0 : 4*pi/n : 2*pi*(n-1)/n) (0 : 4*pi/n : 2*pi*(n-1)/n)];
    X = [ cos(x_range)' sin(x_range)' zeros(n,1) cos(u_range)' sin(u_range)' ];
  else
    X = [ cos(x_range)' sin(x_range)' zeros(n,1) ];
  end
end

function pv = fill_v_z (pv, signs, elevation)
  if (nargin < 2)
    if (size(pv, 2) <= 4)
      %% tetrahedral
      signs = [ +1 -1 -1 +1 ];
    else
      %% sphear octathingy
      signs = [ +1 -1 +1 -1 +1 -1 +1 -1];
    end
  end;
  if (nargin < 3)
    z_factor = sqrt(2)/2;
  else
    z_factor = tan(elevation);
  end;
  for i = 1:size(pv, 2)
    pv(4,i) = signs(i) * sqrt( pv(2,i)^2 + pv(3,i)^2 ) * z_factor;
  end;
end
