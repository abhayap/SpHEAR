//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// TinySpHEAR, Tiny Spherical Harmonics Ear, 
// First Order (B-format) Ambisonics Microphone
//
// Copyright 2015-2016, Fernando Lopez-Lezcano, All Rights Reserved
// nando@ccrma.stanford.edu
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
// 3d Models released under the Creative Commons license as follows:
//   Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// http://creativecommons.org/licenses/by-nc-sa/4.0/

include <TinySpHEAR_common.scad>;

////
//// model parameters

// dimensions of the electret microphone capsule
capsule_radius = 5;
capsule_height = 4.5;

// distance between the face of a capsule and the center of array
//
// for a 10mm capsule: with vertical legs -> 10.5mm min radius
//                     with horizontal legs -> 10mm min radius
mic_radius = 9.6;

// dimensions of the capsule holder connection legs
// a width of 4mm is too thin, 5mm prints better
leg_width = 5;
leg_thick = 1.75;

// wall thickness of the capsule holder
wall = 1;

// width of the ridge that connects to the mount
//   measured: ridge = 2.20mm, slot = 2.0 .. 2.35mm
ridge_width = 2.0;
ridge_slot_width = 2.0;
// add to the thickness of ridges
ridge_wfit = 0.1;
ridge_hfit = 3;

// dimensions of microphone mount
mount_radius = 3.5;
mount_wall = 0.75;

// height and eccentricity of top connector
mount_top_height = 15.0;
mount_top_eccentricity = 1.3;

// height of mount
mount_height = 40;

// microphone stand mount
//
// diameter of existing shielded wires (x 4)
mic_wire_diam = 1.5;
mic_wire_hole_radius = 3.0;
mic_wire_hole_offset = 5;

// standard microphone stand
// measured diameter = 13.5, inside diameter of sleeve = 13.79 (
mic_mount_radius = 13.50 / 2;
// add this to inside diameter
mic_mount_fit = 0.1;
mic_mount_slot_height = 11.5;
mic_mount_slot_width = 4.25;
mic_mount_slot_radius = 6.25  / 2;
mic_mount_wall = 1.5;
mic_mount_height = 35.0 + mic_wire_hole_offset + mic_wire_hole_radius + 2 * mic_mount_wall;

//// end of model parameters
////
//// rendering control

// what to render:
// 0 -> ready to print
//   set = 0 -> one capsule, set = 1 -> four capsules
// 1 -> the whole microhone with four capsules
rendermic = 1;
renderset = 0;

// what type of connection to use between capsule holders:
// 0 -> original cylindrical angled legs
// 1 -> interlocking horizontal legs
// 2 -> interlocking vertical legs
connect = 1;

// how many mount ridges to create
// 0 -> no ridges
// 1 -> 1 ridge
// 2 -> 2 ridges
ridges = 1;

//// end of rendering control
////

// adjustment for the inner radius of the capsule holder
//   measured inside diameter of a trial print was around 7.5 to 8.2 
//   instead of 10, capsule diameter was 9.99)
fudge = 0.08;

// adjustment for fit of slots in connection legs and mount
// 0.1: initial setting
// 0.1 ->0.2: Ultimaker 2 + Extended plus APL (2016.06.10)
fit = 0.15;

// number of facets for rendering cylinders
facets = 64;
// render capsule holders with better resolution
cfacets = 128;

// render a complete microphone

if (rendermic == 1) {
    // all four capsules
    capsule(45, elev_angle, leg_angles_top, 60, 0, 0.0, 0.0, 0);
    capsule(-135, elev_angle, leg_angles_top, 60, 0, 0.0, 0.0, 0);
    capsule(-45, -elev_angle, leg_angles_bot, 0, 1, 0.0, 0.0, 0);
    capsule(135, -elev_angle, leg_angles_bot, 0, 1, 0.0, 0.0, 0);
    // the mount
    mount([-45, 135], mount_wall, mic_mount_wall, mic_mount_height + mount_top_height + mount_height + capsule_bottom);
}

// print all the parts separately

if (rendermic == 0) {
    if (connect == 1) {
        part_rot = 90;
        part_height = 0;
        part_sep = capsule_radius * 2.5;
        // #3
        *translate([part_sep, -part_sep, part_height]) { capsule(0, part_rot, leg_angles_top, 60, 0); }
        if (renderset != 0) {
            // #4
            translate([part_sep, part_sep, part_height]) { capsule(0, part_rot, leg_angles_top, 60, 0); }
            // #2
            *translate([-part_sep, part_sep, part_height]) { capsule(0, part_rot, leg_angles_bot, -90, 1); }
            // #1
            *translate([-part_sep, -part_sep, part_height]) { capsule(0, part_rot, leg_angles_bot, 90, 1); }
            // mount body
            *translate([0, 0, 0]) { mount([-45, 135], mount_wall, mic_mount_wall, 0); }
            // add connecting ridges to make it all one part
            *difference() {
                for (rot_a = [-45, 45]) {
                    rotate([0, 0, rot_a]) {
                        translate([-wall / 2, -part_sep, 0]) {
                            cube([wall, part_sep * 2, wall / 2]);
                        }
                    }
                }
                // remove them in the inside of the mount
                *cylinder(r = mount_radius + wall / 2, h = wall / 2);
            }
        }
    } else {
        // connect == 2
        part_rot = -90;
        part_height = capsule_height;
        part_sep = capsule_radius * 2;
        // #3
        translate([part_sep, -part_sep, part_height]) { capsule(0, part_rot, leg_angles_top, 0, 0); }
        if (renderset != 0) {
            // #4
            translate([part_sep, part_sep, part_height]) { capsule(0, part_rot, leg_angles_top, 0, 0); }
            // #2
            translate([-part_sep, part_sep, part_height]) { capsule(0, part_rot, leg_angles_bot, -90, 1); }
            // #1
            translate([-part_sep, -part_sep, part_height]) { capsule(0, part_rot, leg_angles_bot, 90, 1); }
            // stand mount
            *translate([0, 0, 0]) {
                mount_to_stand([-45, 135], mount_wall, mic_mount_wall, 0);
            }
            // add connecting ridges to make it all one part
            difference() {
                for (rot_a = [-45, 45]) {
                    rotate([0, 0, rot_a]) {
                        translate([-wall / 2, -part_sep * 0.85, 0]) {
                            cube([wall, part_sep * 1.75, wall / 2]);
                        }
                    }
                }
                // remove them in the inside of the mount
                *cylinder(r = mic_mount_radius + mount_wall / 2, h = wall / 2);
            }
        }
    }
}

