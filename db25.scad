//
// *SpHEAR Project (Spherical Harmonics Ears), 
//
// db25 connector plate
// 
// dimensions found here:
// http://www.interfacebus.com/Connector_D-Sub_Mechanical_Dimensions.html
//
//
// Copyright 2015-2016, Fernando Lopez-Lezcano, All Rights Reserved
// nando@ccrma.stanford.edu
//
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//
// 3d Models released under the Creative Commons license as follows:
//   Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// http://creativecommons.org/licenses/by-nc-sa/4.0/

// size of connector
B = 39.09;
D = 8.48;
// size of cutout
H = 41.53;
J = 10.97;
// distance between mounting screws
C = 47.17;
// mount plate
A = 53.42;
E = 12.93;
// depth of contacts
c_depth = 9.5;

// max size of shell
shell_l = 55.0;
shell_w = 8.2 * 2;

ang = 10;
d_s = 3.4 / 2;

// thickness of plate
t = 1.0;

// mini-xlr diameter
xlr_diam = 0.444 * 2.54;


module db25_plate(width = E, th = t, border = 0) {
    linear_extrude(height = th) {
        polygon([
                [- (A/2 + border), width/2 + border],
                [A/2 + border, width/2 + border],
                [A/2 + border, - (width/2 + border)], 
                [-(A/2 + border), - (width/2 + border)], 
                ]);
    }
}

module db25_box(width = E, height, th = t) {
    linear_extrude(height = th) {
        polygon([
                [- A/2, width/2],
                [A/2, width/2],
                [A/2, - width/2], 
                [-A/2, - width/2], 
                ]);
    }
    // box walls
    *translate([-A/2, -(width/2) - th / 8, 0]) {
        cube([th, width, height + 4]);
    }
    *translate([A/2, -(width/2) - th/2, -6]) {
        cube([th, width, height]);
    }
}

module db25_cutout(th = t) {
    thin_mint = 0.001;
    hull() {
        // corners
        for (coord = [
                [- H/2 + d_s/2, J/2 - d_s/2],
                [H/2 - d_s/2, J/2 - d_s/2],
                [- H/2 + d_s/2 + J * tan(10), - J/2 + d_s/2], 
                [H/2 - d_s/2 - J * tan(10), - J/2 + d_s/2], 
                ]) {
            translate([coord[0], coord[1], -thin_mint]) {
                cylinder(r = d_s, h = th + thin_mint * 2, $fn = facets);
            }
        }
    }
    // holes for screws
    for (hole = [-C/2, C/2]) {
        translate([hole, 0, -thin_mint]) {
            cylinder(r = d_s, h = th + thin_mint * 2, $fn = facets);
        }
    }
}

*difference() {
    db25_plate();
    db25_cutout();
}
