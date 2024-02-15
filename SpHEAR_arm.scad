//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// Customized WidowXL Robotic Arm Components
// 
// Copyright 2018, Fernando Lopez-Lezcano, All Rights Reserved
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

facets = 128;

s5_plate_w = 47.0;
s5_plate_d = 29.0;
s5_plate_t = 5.9 + 4.5;

s5_mount_hole_w = 38.0;
s5_mount_hole_d = 22.0;

// holes for mounting to arm plate
s5_hole_r = 2.7/2;

// center hole for servo plate
s5_center_hole_d = 8.5;

// holes to mount servo to plate
module s5_plate_holes () {
    for (mw = [0, 1]) mirror([mw, 0, 0]) {
        for (md = [0, 1]) mirror([0, md, 0]) {
            translate([s5_mount_hole_w/2, s5_mount_hole_d/2, -1.0]) {
                cylinder(r = s5_hole_r + 0.15, h = 20.0, $fn = facets);
            }
        }
    }
}

// holes to mount adaptor to servo
module s5_servo_holes () {
    translate([0, 0, -0.01]) {
        // center hole for servo
        cylinder(r = 6.5/2, h = 20.0, $fn = facets);
        // holes for mounting servo to plate
        for (m = [0, 1]) mirror([m, 0, 0]) {
            translate([15, -4.5, 0]) {
                cylinder(r = s5_hole_r, h = 20.0, $fn = facets);
                cylinder(r = 5/2, h = 3.25, $fn = facets);
            }
            translate([15, - 4.5 + 17, 0]) {
                cylinder(r = s5_hole_r, h = 20.0, $fn = facets);
                cylinder(r = 5/2, h = 3.25, $fn = facets);
            }
        }
    }
}

// basic mounting plate
module s5_plate () {
    difference() {
        mp_r = 2.0;
        union() {
            translate([-s5_plate_w/2 + mp_r, -s5_plate_d/2 + mp_r, 0]) {
                intersection() {
                    minkowski() {
                        cube([s5_plate_w - 2*mp_r, s5_plate_d - 2*mp_r, s5_plate_t]);
                        cylinder(r = mp_r, h = 0.001, $fn = facets);
                    }
                    // rounded top
                    translate([0, 0, -mp_r]) minkowski() {
                        cube([s5_plate_w - 2*mp_r, s5_plate_d - 2*mp_r, s5_plate_t]);
                        sphere(r = mp_r, $fn = facets);
                    }
                }
            }
            // extended support for plate screws
            for (m = [0, 1]) mirror([m, 0, 0]) translate([15, - 4.5 + 17, 0]) {
                cylinder(r = 7/2, h = 5.5, $fn = facets);
            }
        }
        // hollow out servo space
        s_w = 24.40;
        translate([-s_w/2, -12.50, 5.5/2]) {
            cube([s_w, 40, 10]);
        }
        // and shave top as well
        s_tw = 35.60;
        m_r = 6.0;
        translate([-s_tw/2 + m_r, -12.50 + m_r, 5.5 - 0.2]) {
            minkowski() {
                cube([s_tw - 2*m_r, 40, 10]);
                cylinder(r = m_r, h = 0.001, $fn = facets);
            }
        }
    }
}

// plate that screws into MX28T servo and has sockets to attach
// to microphone mount

module arm_attachment_plate () {
    // 25.0 is separation between sockets
    plate_w = grip_sep * 2 + arm_l + 4 * wall;
    plate_d = arm_w + 4 * wall;
    plate_t = 5.0;
    translate([-plate_w/2, -plate_d/2, 0]) {
        cube([plate_w, plate_d, plate_t]);
    }
}

// holes for MX28T servo
module arm_attachment_holes () {
    // center of servo
    translate([0, 0, -0.01]) cylinder(r = 9.0/2, h = 10.0, $fn = facets);
    // screw holes
    for (r = [45, -45, 135, -135]) rotate([0, 0, r]) {
        translate([8.0, 0, -0.01]) {
            cylinder(r = 2.7/2, h = 10.0, $fn = facets);
        }
        translate([8.0, 0, 3.25]) {
            cylinder(r = 3.9/2, h = 10.0, $fn = facets);
        }
    }
}

// model WidowXL (dimensions of original gripper)

wall = 1.0;

// sliding block (dimensions from WidowXL gripper blocks)
arm_l = 10.2 + 0.38;
arm_w = 21.5 + 0.38;
// x profile
arm_profile_s = 10.25;
arm_b_prof = 4.25;
// connection socket
arm_s_h = 21.0;

// separation between centers of sockets
grip_sep = 25.4 * 1.5 / 2 + arm_l / 2;

// block that can be screwed to existing gripper of stock WidowXL arm
module arm_gripper_block () {
    translate([-arm_l/2, -arm_w/2, 0]) difference() {
        // body
        translate([-(4 * wall)/2, -2 * wall, 0]) {
            cube([arm_l + 4 * wall, arm_w + 4 * wall, arm_s_h]);
        }
        // carve out corners for better fit
        translate([0.2, 0.2, 0]) cylinder(r = 0.4, h = arm_s_h, $fn = facets);
        translate([arm_l, 0.2, 0]) cylinder(r = 0.4, h = arm_s_h, $fn = facets);
        translate([arm_l, arm_w, 0]) cylinder(r = 0.4, h = arm_s_h, $fn = facets);
        translate([0.2, arm_w, 0]) cylinder(r = 0.4, h = arm_s_h, $fn = facets);
        // arm gripper block
        union() {
            cube([arm_l, arm_w, arm_s_h + 0.1]);
            translate([-arm_l/2, arm_w/2 - arm_profile_s/2, - arm_b_prof - arm_profile_s - 10]) {
                cube([20, arm_profile_s, arm_profile_s + 10]);
            }
        }
    }
}

// MX28T servo mounting plate
//
// attaches MX28T servo to arm to act as wrist rotation servo with 360 degree
// of rotation instead of the stock dual AX12A wrist rotation and gripper servos
// with 300 degree rotation limit

*difference() {
    s5_plate();
    s5_plate_holes();
    s5_servo_holes();
}

// microphone mount attachment, screws into MX28T servo and has sockets
// for the microphone mount pillars

difference() {
    union() {
        arm_attachment_plate();
        for (m = [0, 1]) mirror([m, 0, 0]) translate([grip_sep, 0, 5.0]) arm_gripper_block();
    }
    arm_attachment_holes();
}
