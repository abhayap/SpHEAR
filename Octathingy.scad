//
// Octathingy, Second Order Ambisonics Microphone
//
// based on:
// "A second-order soundfield microphone with improved polar pattern shape"
// by Eric Benjamin, Audio Engineering Society Convention Paper 8728, 
// October 2012, San Francisco

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


////
//// model parameters

// dimensions of the electret microphone capsule
capsule_radius = 5;
capsule_height = 4.5;

// distance between face of capsule and center of array
mic_radius = 14;

// dimensions of capsule holder connection legs
leg_width = 4;
leg_thick = 2.5;

// width of the ridge that connects to the mount
ridge_width = 2;
ridge_length = 2;

// wall thickness of capsule holder
wall = 1;

// dimensions of microphone holder
mount_radius = 4.5;

// height of mount
mount_height = 4;

// type of octathingy
// 0 -> regular octathingy (equilateral triangles in the square antiprism)
// 1 -> tetrahedral compatible octathingy (same elevation angle as the tetrahedral mic)
tetra_compat = 0;

//// end of model parameters
////
//// rendering control

// what to render:
// 0 -> ready to print
//   set = 0 -> one capsule, set = 1 -> four capsules
// 1 -> the whole microhone with eight capsules
rendermic = 1;
renderset = 0;

// what type of connection to use between capsule holders:
// 0 -> original cylindrical angled legs
// 1 -> interlocking horizontal legs
// 2 -> interlocking vertical legs
connect = 1;

// adjustment for the radius of the capsule
//   measured inside diameter of a trial print was around 7.5 to 8.2 
//   instead of 10, capsule diameter was 9.99)
fudge = 0.15;

// adjustment for fit of slots in connection legs and mount
fit = 0.1;

// number of facets for rendering cylinders
facets = 64;

//// end of rendering control
////

// define the elevation angle of the upper and lower rings
//
// http://eusebeia.dyndns.org/4d/antiprism4
//
// The Cartesian coordinates of the square antiprism, 
// centered on the origin and having edge length 2, are:
//
//    (0, ±√2, 1/∜2)
//    (±√2, 0, 1/∜2)
//    (±1, ±1, −1/∜2)
//
// the elevation angle for the two rings of 4 is:
//
// 1/2*∜2 = 0.420448207627 (z for edge length = 1)
// atan(1/(2*∜2) / 0.707) = 30.7358671024
elev_angle =  tetra_compat == 0 ? atan(1 / (2 * sqrt(sqrt(2))) * sqrt(2)) : atan(sqrt(1/2));

// calculate half angle between vertices in the square antiprism
// these angles define the length of the connecting legs
//
// z coordinate of antiprism vertices
vert_z = sqrt(2) * tan(elev_angle) / 2;
// vector length (same for all antiprism vertices)
vert_n = norm([-0.5, -0.5, vert_z]);
// half angle between adjacent vertices in either the upper or lower rings
vert_angle_h = acos(([-0.5, -0.5, vert_z] / vert_n) * ([0.5, -0.5, vert_z] / vert_n)) / 2;
// half angle between adjacent vertices in the upper and lower rings
vert_angle_v = acos(([0.0, -1 / sqrt(2), -vert_z] / vert_n) * ([0.5, -0.5, vert_z] / vert_n)) / 2;

// angles of the connection legs and adjacent capsule holders
leg_angles = tetra_compat == 0 ?
    [
        [-63, vert_angle_h], 
        [63, vert_angle_h],
        [-141, vert_angle_v],
        [141, vert_angle_v]
    ] :
    [
        [-60.5, vert_angle_h], 
        [60.5, vert_angle_h],
        [-144.5, vert_angle_v],
        [144.5, vert_angle_v]
    ];

// microphone holder geometry
capsule_sep_min = (mic_radius - capsule_height) * cos(elev_angle) - (capsule_radius + wall) * sin(elev_angle);
capsule_sep_max = mic_radius * cos(elev_angle) - (capsule_radius + wall) * sin(elev_angle);
capsule_bottom = mic_radius * sin(elev_angle) + (capsule_radius + wall) * cos(elev_angle);
mount_slot_depth = ridge_length * sin(elev_angle);

////////
// microphone capsule holder

// azimuth: horizontal orientation of the capsule
// elevation: vertical orientation of the capsule
// mounts: vectors containing the angle of the mount and the angle to the adjacent capsule
// twist: rotate the whole capsule to match mounting legs

module capsule (azimuth, elevation, mounts, twist, ridge, ridge_fit = 0.0, solid = 0) {
    rotate([0, 0, azimuth]) {
        rotate([0, (90 - elevation), 0]) {
            translate([0, 0, (rendermic == 0 && solid == 0) ? 0 : mic_radius - capsule_height]) {
                difference () {
                    union () {
                        // main capsule holder
                        cylinder(r = capsule_radius + wall, h = capsule_height, $fn = facets);    
                        // the mounting legs
                        for (angles = mounts) {
                            rotate([0, 0, angles[0] + twist]) {
                                // connect with cylindrical beams, very pretty
                                leg_length = mic_radius * sin(angles[1]) - (capsule_radius + wall) * cos(angles[1]) + wall;
                                if (connect == 0) {
                                    translate([capsule_radius - wall, 0, capsule_height - wall]) {
                                        rotate([0, 180 - (90 - angles[1]), 0]) {
                                            cylinder(d = leg_width, h = leg_length - 0.1, center = false, $fn = facets);
                                        }
                                    }
                                }
                                // connect with horizontal legs
                                if (connect == 1) {
                                    leg_length = (mic_radius - capsule_height + leg_thick) * tan(angles[1]) - capsule_radius;
                                    slot_depth = leg_thick * cos(90 - 2 * angles[1]) + fit;
                                    translate([capsule_radius + leg_length + fudge, - leg_width / 3, 0]) {
                                        rotate([0, -90, 0]) {
                                            difference() {
                                                // thickness, width
                                                cube([leg_thick, leg_width, leg_length]);
                                                // cut slot in connector
                                                translate([0, leg_width / 3 - (fit / 2), 0]) {
                                                    cube([leg_thick, leg_width / 3 + fit, slot_depth]);
                                                }
                                            }
                                        }
                                    }
                                }
                                // connect with vertical legs
                                if (connect == 2) {
                                    leg_length = (mic_radius * tan(angles[1]) - capsule_radius) * tan(90 - angles[1]); 
                                    slot_depth = leg_thick * (cos (90 - 2 * angles[1]) + tan(90 - 2 * angles[1])) + fit;
                                    translate([capsule_radius + fudge, - leg_width / 3, - leg_length + capsule_height]) {
                                        difference() {
                                            // thickness, width
                                            cube([leg_thick, leg_width, leg_length]);
                                            // cut slot in connector
                                            translate([0, leg_width / 3 - (fit / 2), 0]) {
                                                cube([leg_thick, leg_width / 3 + fit, slot_depth]);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        // add ridges for microphone mount
                        if (ridge == 1) {
                            rotate([0, 0, twist]) {
                                translate([capsule_radius + fudge, - wall , 0]) {
                                    difference() {
                                        cube([ridge_length, ridge_width, capsule_height], center = false);
                                        //rotate([0, 90 - elev_angle, 0]) {
                                        //  cube([ridge_length, ridge_width, capsule_height], center = false);
                                        //}
                                    }
                                }
                            }
                        }
                    }
                    // make the hole for the capsule
                    if (solid != 1) {
                        translate ([0, 0, -2]) {
                            cylinder(r = capsule_radius + fudge, h = capsule_height + 2, $fn = facets);
			}
                    }
                    // remove any extra connecting beam material from the face of the holder
                    if (connect == 0) {
                        translate ([0, 0, capsule_height]) {
                            cylinder(r = capsule_radius + wall * 2, h = 2, $fn = facets);
                        }
                    }
                }
            }
        }
    }
}

// microphone mount
//
// angles: angles for mount slots
// wall: thickness of cylinder wall
// separation: height of mount with respect of the microphone assembly

module mount (angles, wall, separation) {
    translate([0, 0, -(separation + 0.1)]) {
        difference() {
            union() {
                // grips for the capsule holder ridge
                for (rot = angles) {
                    rotate([0, 0, rot]) {
                        translate([-capsule_sep_max, -(ridge_width - fit / 2), -mount_height]) {
                            cube([capsule_sep_max, ridge_width * 2 - fit, mount_height]);
                            rotate([0, -elev_angle, 0]) {
                                cube([capsule_sep_max, ridge_width * 2 - fit, mount_height * cos(elev_angle)]);
                            }
                        }
                    }
                }
                translate([0, 0, -mount_height]) {
                    cylinder(r = mount_radius + wall, h = mount_height, $fn = facets);
                }
            }
            // make the hole for the mount (* 2 to cut the ridge as well)
            translate([0, 0, -mount_height]) {
                cylinder(r = mount_radius, h = mount_height * 2, $fn = facets);
            }
            // cut the outside of the sloped ridge
            translate([0, 0, -mount_height]) {
                difference() {
                    cylinder(r = capsule_sep_max + mount_height * 2, h = mount_height * 2, $fn = facets);
                    cylinder(r = capsule_sep_max, h = mount_height * 2, $fn = facets);
                }
            }
            // and cut a slot for the ridges in the wall of the cylinder
            for (rot = angles) {
                rotate([0, 0, rot]) {
                    translate([-capsule_sep_max * 2, -ridge_width + 4 * fit, -mount_slot_depth]) {
                        cube([capsule_sep_max * 2, ridge_width + 2 * fit, mount_height * 2]);
                    }
                }
            }
        }
    }
}

// render a complete microphone
if (rendermic == 1) {
    for (az = [45, 135, -45, -135]) {
        capsule(az, elev_angle, leg_angles, 180, 0);
        capsule(az + 45, -elev_angle, leg_angles, 0, 1);
    }
    // the mount
    mount([0, 90, -90, 180], 1, capsule_bottom);
}

// print all the parts separately
part_sep = capsule_radius * 4;
if (rendermic == 0) {
    twist_top = -90;
    twist_bottom = 100;
    if (connect == 1) {
        // part numbering is from right to left (negative x-axis translations -> positive)
        
        /////////////// top row /////////////////
        // part 1
        translate([-part_sep, part_sep]) { capsule(0, 90, leg_angles, twist_top, 0); }
        // part 2
        translate([0, part_sep, 0]) { capsule(0, 90, leg_angles, twist_top, 0); }
        // part 3
        translate([part_sep, part_sep]) { capsule(0, 90, leg_angles, twist_top, 0); }
        // part 4
        translate([2*part_sep, part_sep]) { capsule(0, 90, leg_angles, twist_top, 0); }
        
        /////////////// bottom row /////////////////
        // part 1
        translate([-part_sep, 0, 0]) { capsule(0, 90, leg_angles, twist_bottom, 1); }
        // part 2
        translate([0, 0, 0]) { capsule(0, 90, leg_angles, twist_bottom, 1); }
        // part 3
        translate([part_sep, 0, 0]) { capsule(0, 90, leg_angles, twist_bottom, 1); }
        // part 4
        translate([2*part_sep, 0]) { capsule(0, 90, leg_angles, twist_bottom, 1); }
        
        // ridges to connect all parts
        translate([-part_sep + wall, part_sep / 2 - wall, 0]) {
            cube([part_sep * 3, wall, wall / 2]);
        }
        for (d = [-part_sep, 0, part_sep, 2*part_sep]) {
            translate([wall + d, capsule_radius, 0]) {
                cube([wall, part_sep - capsule_radius * 2, wall / 2]);
            }
        }
    
    }
}