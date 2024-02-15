//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// Common Modules and Variables
//
// Copyright 2015-2019, Fernando Lopez-Lezcano, All Rights Reserved
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

include <CCRMA_logo.scad>;

////
//// default model parameters
////

// microphone capsule array
//
// dimensions of the electret microphone capsule
// (specified in each master scad file)
// capsule_radius
// capsule_height

// distance between the face of a capsule and the center of array
// (specified in each master scad file)
// mic_radius

// wall thickness of the capsule holder
wall = 1.0;

// height and width of capsule stop ring
capsule_ring_h = 0.4;
capsule_ring_w = 0.5;

// dimensions of the capsule holder connection legs
// a width of 4mm is too thin, 5mm prints better
leg_width = 5;
leg_thick = 1.75;

// width of the ridge that connects to the mount
ridge_width = 2.0;
ridge_slot_width = 2.0;
// depth of the connector mount ridge
ridge_depth = 3.0;
// add to the thickness of ridges
ridge_wfit = 0.1;
ridge_hfit = 3;

// microphone mount
//
mount_radius = 3.5;
mount_wall = 0.75;

// lip that mounts flares into main body box
mount_lip = 10.0;

// height and eccentricity of top connector
mount_top_height = 10.0;
mount_top_eccentricity = 1.3;

// height of mount
mount_height = 40;

// microphone stand mount
//
// diameter of existing shielded wires (x 4)
mic_wire_diam = 1.5;
mic_wire_fit = 0.8;
mic_wire_hole_radius = 3.0;
mic_wire_hole_offset = 5;

// standard microphone stand
// measured diameter = 13.5, inside diameter of sleeve = 13.79 (
mic_mount_radius = 13.50 / 2;
// add this to inside diameter
mic_mount_fit = 0.2;
mic_mount_slot_height = 11.5;
mic_mount_slot_width = 4.25;
mic_mount_slot_radius = 6.25  / 2;
mic_mount_wall = 1.5;
mic_mount_height = 20.0 + mic_wire_hole_offset + mic_wire_hole_radius + 2 * mic_mount_wall;

// dimensions of 12 pin male bottom connector
//
// Amphenol T 3635 002
// 12 pin DIN male to cable, gold plated contacts
//
// inner diameter of connector core
conn_core_diam = 13.00 + 0.2;
// outer diameter of connector core sleeve
conn_core_o_diam = 17.00;
// inner diameter of connector core sleeve
conn_core_s_diam = 15.00;

// from top of connector to sleeve
conn_core_sleeve = 13.00;
// from top of connector to holes
conn_core_holes_h = 6.00;
// between holes
conn_core_holes_w = 9.20;
// hole diameter
conn_core_holes_d = 1.95 + 0.2;
// screw head diameter
conn_core_screw_d = 2.75 + 0.5;
// sleeve overlap
conn_core_overlap = 3.00;

// robotic arm interface

// this separation between pillars comes from original arm Widow XL gripper
// (it could be something else now)
grip_sep = 25.4 * 1.5 / 2;
grip_width = 15.0;
grip_depth = 5.0;

//// end of model parameters
////
//// rendering control

// what type of connection to use between capsule holders:
// 0 -> original cylindrical angled legs
// 1 -> interlocking horizontal legs with triangular top (only works with small radius)
// 2 -> interlocking horizontal legs
// 3 -> interlocking vertical legs
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
fudge = 0.12;

// adjustment for fit of slots in connection legs and mount
// 0.1: initial setting
// 0.1 ->0.15: Ultimaker 2 + Extended plus APL (2016.06.17)
// 0.15->0.10 (2017.01.21)
// Octathingy_common builds -> 0.1, TinySpHEAR_common builds -> 0.15
fit = 0.15;

// number of facets for rendering cylinders (64 for coarse rendering)
facets = 128;
// render capsule holders with better resolution
cfacets = 128;
// "a wafer-thin mint..."
// something to use when we need tiny 3d slivers
thin_mint = 0.001;

//////// Printed circuit board parameters

// size of Zapnspark printed circuit board
// kicad length = 79.375
// measured length = 79.20 (2016.08.25)
pcb_length = pcb_version == 2 ? 72.39 : 79.20;
// kicad width = 19.050
// measured width = 18.82 (2016.08.25)
// v2 (kicad) 15.24 (measured) 15.34
pcb_width = pcb_version == 2 ? 15.34 : 18.85;
// ultimaker spec thickness = 1.61
// measured thickness = 1.56 (w/ copper)
pcb_thickness = pcb_version == 2 ? 1.68 + 0.02 : 1.58;

// tolerance to add to length and width of pcb
//
// measured 3d print width = 18.70 (with pcb_fit = 0.3)
// actual printed = 18.70 - 0.3 = 16.97
// total correction = 18.85 - 16.97 = 1.88
//
pcb_fit = 0.4;

// tolerance add to thickness of pcb
//
// printed with pcb_tfit = 0.15 -> 1.58 + 0.15 = 1.73 (ideal printed)
// measured print channel = 1.63 : 0.1 thinner (ultimaker 2 plus, 2016.08.24)
// measured pcb thickness = 1.58 (othermill)
//
pcb_tfit = 0.15;

// we leave part of the pcb exposed on the bottom of the body so that we
// can solder the wires that connect the microphone with the
// preamplifier, same at the top of the pcb to solder the wires
// to the capsules
pcb_low_exp = 12.0;
pcb_hi_exp = 8.0;

// mount height
pcb_mount_height = pcb_length - pcb_low_exp - pcb_hi_exp;

// lip fit for flares
lip_fit = 0.15;

// clearance from the bottom and top of pcb's to the start of the flare,
// this adds space for the protuding molex pins on which we solder
pcb_low_clear = pcb_version == 2 ? 12.0 : 15.0;
pcb_hi_clear = pcb_version == 2 ? 12.0 : 15.0;

// depth of slot into which the printed circuit board fits
pcb_slot_depth = 1.0;

// diameter of four conductor cable
cable_diam = 9.5;

// XXX back and front clearance of pcb (components and leads)
// XXX this is different for the Octathingy
pcb_front = pcb_version == 2 ? 2.50 : 3.00;
pcb_back = pcb_version == 2 ? 1.70 : 1.80;

// shared windscreen parameters
windscreen_height = 60;
windscreen_w = 4.0;
beam_radius = 1.3;
windscreen_thread_height = pcb_version == 2 ? 8.0 : 10.0;
windscreen_thread_pitch = 2.0;
windscreen_thread_angle = 30;
windscreen_thread_depth = cos(windscreen_thread_angle) * windscreen_thread_pitch * 5/8 + 0.5;
windscreen_thread_fit = 3 * fit;

////////
// microphone capsule holder

// mounts: vectors containing the angle of the mount and the angle to the adjacent capsule
// twist: rotate the whole capsule to match mounting legs
// ridge: add 0, 1 or 2 ridges for attaching the structure to the mount
// ridge_wfit: tune the fit, used for carving slots in mount
// ridge_hfit: adjust height of ridges when carving out the capsule rests
// solid: make the capsule holder solid, used in the mount code to carve the capsule rests

module capsule (mounts, twist, ridge, ridge_wfit = 0.0, ridge_hfit = 0.0, solid = 0) {
    capsule_h = capsule_height + capsule_ring_h;
    difference () {
        union () {
            // main capsule holder
            cylinder(r = capsule_radius + wall, h = capsule_h, $fn = cfacets);
            // the mounting legs
            for (angles = mounts) {
                rotate([0, 0, angles[0] + twist]) {
                    // disable rendering of the connection legs if the array radius is too
                    // small and components of adyacent capsule holders touch each other
                    //
                    leg_height = leg_thick;
                    // make sure capsule holders do not touch
                    render_legs = ((mic_radius - capsule_height) / tan(angles[1])) - capsule_radius - wall -
                        // and make sure connection leg does not touch adyacent capsule holder
                        (angles[1] > 45 ? leg_height * tan(2 * angles[1] - 90) + 2 * fit : 0.0);
                    //
                    // connect with cylindrical beams, very pretty, not printable
                    if (connect == 0 && render_legs >= 0) {
                        leg_length = mic_radius * cos(angles[1]) - capsule_radius * sin(angles[1]);
                        translate([capsule_radius - wall, 0, capsule_height - wall]) {
                            rotate([0, 180 - angles[1], 0]) {
                                cylinder(d = leg_width, h = leg_length - 0.3, center = false, $fn = facets);
                            }
                        }
                    }
                    // connect with horizontal legs with triangular top (the best by far)
                    if (connect == 1 && render_legs >= 0) {
                        leg_length = capsule_radius + wall + capsule_height * tan(angles[1]) - fit;
                        leg_w = (solid != 0)? leg_width + fit : leg_width;
                        slot_radius = (mic_radius - capsule_height) / tan(angles[1]);
                        translate([0, 2 * (- leg_w / 3), 0]) {
                            difference() {
                                cube([leg_length, leg_w + leg_w / 3, capsule_height]);
                                // cut slots that lock with adyacent leg
                                if (solid == 0) {
                                    for (offset = [1, 3]) {
                                        translate([slot_radius - 1 * fit, leg_w / offset - fit / 2, 0]) {
                                            rotate([0, 90 - angles[1] * 2, 0]) translate([0, 0, - capsule_height])
                                            cube([leg_length, leg_w / 3 + fit, capsule_height * 2]);
                                        }
                                    }
                                }
                                // shave triangular slice of fingers, starts at edge of capsule holder
                                translate([capsule_radius + wall, 0, leg_height]) {
                                    rotate([0, 90 - angles[1], 0]) {
                                        cube([leg_length, leg_w + leg_w / 3, capsule_height]);
                                    }
                                }
                                // and remove the rest when the leg height is less than the capsule height
                                translate([0, - 2 * (- leg_w / 3), leg_height]) {
                                    difference() {
                                        cylinder(r = capsule_radius + leg_length, h = capsule_height, $fn = facets);
                                        cylinder(r = capsule_radius + wall, h = capsule_height, $fn = facets);
                                    }
                                }
                            }
                        }
                    }
                    // connect with horizontal legs with triangular top (testing for octathingy)
                    if (connect == 4 && render_legs >= 0) {
                        leg_h = leg_height * angles[3];
                        // legs are not long enough for long ones in octathingy... add 1.0
                        leg_length = capsule_radius + wall + capsule_height * tan(angles[1] + angles[2]) - fit + 1.0;
                        leg_w = (solid != 0)? leg_width + fit : leg_width;
                        slot_radius = (mic_radius - capsule_height) / tan(angles[1] + angles[2]);
                        translate([0, 2 * (- leg_w / 3), 0]) {
                            difference() {
                                cube([leg_length, leg_w + leg_w / 3, capsule_height]);
                                // cut slots that lock with adyacent leg
                                if (solid == 0) {
                                    for (offset = [1, 3]) {
                                        translate([slot_radius - 1 * fit, leg_w / offset - fit / 2, 0]) {
                                            rotate([0, 90 - (angles[1] + angles[2]) * 2, 0]) translate([0, 0, - capsule_height])
                                            cube([leg_length, leg_w / 3 + fit, capsule_height * 2]);
                                        }
                                    }
                                }
                                // shave triangular slice of fingers, starts at edge of capsule holder
                                translate([capsule_radius + wall, 0, leg_h]) {
                                    rotate([0, 90 - (angles[1] + angles[2]), 0]) {
                                        cube([leg_length, leg_w + leg_w / 3, capsule_height]);
                                    }
                                }
                                // and remove the rest when the leg height is less than the capsule height
                                translate([0, - 2 * (- leg_w / 3), leg_h]) {
                                    difference() {
                                        cylinder(r = capsule_radius + leg_length, h = capsule_height, $fn = facets);
                                        cylinder(r = capsule_radius + wall, h = capsule_height, $fn = facets);
                                    }
                                }
                            }
                        }
                    }
                    // connect with horizontal legs
                    if (connect == 2 && render_legs >= 0) {
                        leg_length = (mic_radius - capsule_height + leg_thick) * tan(90 - angles[1]);
                        slot_depth = leg_thick / cos(90 - 2 * angles[1]);
                        slot_xtra_depth = (angles[1] < 45) ? (leg_thick * tan(90 - 2 * angles[1])) : 0.0;
                        translate([0, - leg_width / 3, 0]) {
                            difference() {
                                cube([leg_length, leg_width, leg_thick]);
                                // cut slot in connector
                                translate([leg_length - slot_depth - slot_xtra_depth - fit, leg_width / 3 - (fit / 2), 0]) {
                                    cube([slot_depth + slot_xtra_depth + fit, leg_width / 3 + fit, leg_thick]);
                                }
                            }
                        }
                    }
                    // connect with vertical legs
                    if (connect == 3 && render_legs >= 0) {
                        // fix this 0.2 == (2 * fudge?)
                        leg_length = (mic_radius * tan(90 - angles[1]) - capsule_radius) * tan(angles[1]) - 0.2;
                        slot_depth = leg_thick * cos (90 - (2 * angles[1]));
                        translate([capsule_radius - leg_thick / 2 + fudge, - leg_width / 3,
                                   - leg_length + capsule_height]) {
                            difference() {
                                // the connection
                                difference() {
                                    cube([leg_thick + leg_thick / 2, leg_width, leg_length]);
                                    translate([-leg_thick + wall - fudge, 0, - capsule_height + fudge]) {
                                        cube([leg_thick, leg_width, leg_length]);
                                    }
                                }
                                // cut slot in connector
                                translate([0, leg_width / 3 - (fit / 2), 0]) {
                                    cube([leg_thick + leg_thick / 2, leg_width / 3 + fit, slot_depth]);
                                }
                            }
                        }
                    }
                }
            }
            // add ridges for microphone mount
            ridge_length = (mic_radius - capsule_height) / tan(elev_angle) - (capsule_radius + wall);
            if (ridge == 2) {
                rotate([0, 0, twist]) {
                    translate([capsule_radius + wall - ridge_length / 2, (ridge_width + ridge_wfit) / 2, 0]) {
                        cube([ridge_length * 3 / 2, ridge_width + ridge_wfit, capsule_h + ridge_hfit], center = false);
                    }
                    translate([capsule_radius + wall - ridge_length / 2, - (ridge_width + ridge_wfit) * 3 / 2, 0]) {
                        cube([ridge_length * 3 / 2, ridge_width + ridge_wfit, capsule_h + ridge_hfit], center = false);
                    }
                }
            }
            if (ridge == 1) {
                rotate([0, 0, twist]) {
                    difference() {
                        translate([capsule_radius + wall / 2, - (ridge_width + ridge_wfit) / 2, 0]) {
                            cube([ridge_depth + wall / 2, ridge_width + ridge_wfit, capsule_h + ridge_hfit], center = false);
                        }
                        translate([capsule_radius + wall + ridge_length, - (ridge_width + ridge_wfit) / 2, 0]) {
                            rotate([0, elev_angle, 0]) {
                                cube([ridge_depth, ridge_width + ridge_wfit, capsule_h * 2], center = false);
                            }
                        }
                    }
                }
            }
        }
        if (solid != 1) {
            // make the hole for the capsule
            translate ([0, 0, capsule_ring_h]) {
                cylinder(r = capsule_radius + fudge, h = capsule_h + thin_mint, $fn = cfacets);
            }
            if (connect == 3) {
                // cut vertical leg overhang below capsule
                translate ([0, 0, -capsule_h]) {
                    cylinder(r = capsule_radius + fudge, h = capsule_h, $fn = cfacets);
                }
            }
            if (connect != 3) {
                // leave ridge at bottom for horizontal legs only
                cylinder(r = capsule_radius + fudge - capsule_ring_w, h = capsule_h + thin_mint, $fn = cfacets);
            }
        }
        // remove any extra connecting beam material from the face of the holder
        if (connect == 0) {
            translate ([0, 0, capsule_h]) {
                cylinder(r = capsule_radius + wall * 2, h = 2, $fn = cfacets);
            }
        }
    }
}

//// shared modules for zapnspark printed circuit board

// one printed circuit board

module pcb(length, width, thick) {
    translate([-width/2, 0, 0]) {
        cube([width, thick, length]);
    }
}

// one printed circuit board with space in the front and back for components

module pcb_clear(length, width, thick, slot_depth, front, back) {
    translate([0, - (thick + front)]) {
        pcb(length, width, thick);
        // clear space in the front
        translate([- (width/2 - slot_depth), thick, 0]) {
            cube([width - 2 * slot_depth, front, length]);
        }
        // clear space in the back
        translate([- (width/2 - slot_depth), - back, 0]) {
            cube([width - 2 * slot_depth, back, length]);
        }
    }
}

//// shared modules for mount

// rectangular block with rounded corners

module rounded_block(height, width, depth, radius) {
    dw = width - radius;
    dd = depth - radius;
    minkowski() {
        translate([-dw, -dd, 0]) {
            cube([dw * 2, dd * 2, height / 2]);
        }
        cylinder(r = radius, h = height / 2, $fn = facets);
    }
}

// rectangular inset block with rounded corners

module rounded_block_relative(height, ref_width, ref_depth, ref_corner, radius_inc) {
    corner = ref_corner * ((ref_width + radius_inc) / ref_width);
    rounded_block(height, ref_width + radius_inc, ref_depth + radius_inc, corner);
}

// box with rounded corners

module rounded_box(height, width, depth, radius, wall) {
    iradius = radius * ((width - wall) / width);
    difference() {
        rounded_block(height, width, depth, radius);
        rounded_block(height, width - wall, depth - wall, iradius);
    }
}

//// shared modules for shock mount

// eyelet for connecting the external ring to the stand mount

module shock_mount_ring(outside_radius, inside_radius, thickness) {
    difference() {
        union() {
            cylinder(r = outside_radius, h = thickness, $fn = facets);
            translate([0, -outside_radius, 0]) {
                cube([outside_radius, outside_radius, thickness]);
            }
        }
        cylinder(r = inside_radius, h = thickness, $fn = facets);
    }
}

// one eyelet for connection to shock mount or permanent mount

module mount_stand_eyelet(outside_radius, inside_radius, thickness) {
    translate([0, thickness/2, 0]) rotate([90, 0, 0])
    difference() {
        cylinder(r = outside_radius, h = thickness, $fn = facets);
        cylinder(r = inside_radius, h = thickness, $fn = facets);
    }
}

// connector to shock mount or permanent mount (upper part)

module mount_connector_top(height, o_radius, i_radius, offset) {
    // eyelets
    o_rad = 8;
    i_rad = 3;
    thk = 4;
    // screw head and nut dimensions
    head_thick = 3.0;
    head_diam = 9.2;
    nut_radius = 12/2;
    // offset
    h_offset = offset;
    difference() {
        hull() {
            for (m = [0, 1]) mirror([0, m, 0]) {
                translate([0, thk * 3/2, height + o_rad + h_offset]) {
                   mount_stand_eyelet(o_rad, i_rad, thk);
                }
            }
            translate([0, 0, height]) {
                difference() {
                    cylinder(r = o_radius, h = thin_mint, $fn = facets);
                }
            }
        }
        // make hole for screw
        translate([0, mic_mount_radius * 2, height + h_offset + o_rad]) {
            rotate([90, 0, 0]) cylinder(r = i_rad, h = mic_mount_radius * 4, $fn = facets);
        }
        // clear the space between eyelets
        translate([-o_rad * 2, -thk/2, height + h_offset/2]) {
            cube([o_rad * 4, thk, o_rad * 4]);
        }
        // hollow top
        translate([0, 0, height]) {
            scale([1.0, 1.0, 1.2]) sphere(r = i_radius, $fn = facets);
        }
        // recessed hexagonal screw head on one side
        translate([0, -3/2*thk, height + h_offset + o_rad]) {
            rotate([90, 30, 0]) cylinder(h = head_thick, r = head_diam / 2, $fn = 6);
        }
        // recessed nut head on the other side
        translate([0, 3/2*thk + thk, height + h_offset + o_rad]) {
            rotate([90, 30, 0]) cylinder(h = head_thick, r = nut_radius + 0.2, $fn = facets);
        }
    }
}

// mount to quik release stand

module quik_release_stand_adapter(height, wall, stand_wall) {
    difference() {
        union() {
            // main mount cylinder
            difference() {
                cylinder(r = mic_mount_radius + mic_mount_fit + stand_wall, 
                        h = height, $fn = facets);
                // make the hole for the mount (* 1.5 to cut the ridge as well)
                cylinder(r = mic_mount_radius + mic_mount_fit, h = height, $fn = facets);
            }
        }
        // slot for fitting into microphone stand
        translate([mic_mount_radius - stand_wall / 2, - mic_mount_slot_width / 2, 0]) {
            cube([2 * stand_wall, mic_mount_slot_width, mic_mount_slot_height]);
        }
        // eyelet for microphone stand
        translate([mic_mount_radius - stand_wall / 2, 0,  mic_mount_slot_height]) {
            rotate([0, 90, 0]) {
                cylinder(r = mic_mount_slot_radius, h = 2 * stand_wall, $fn = facets);
            }
        }
    }
}

// connector to quik release microphone stand

module shock_mount_stand(height, wall, stand_wall) {
    // connection to microphone
    mount_connector_top(height, mic_mount_radius + mount_wall + wall + mic_mount_fit, mic_mount_radius + mic_mount_fit, 20.0);
    // connection to stand
    quik_release_stand_adapter(height, wall, stand_wall);
}

// thread for stand mount
//
// 5/8-27 for US mic stands
// 3/8-16 for European

module stand_mount_thread(length, band, wall, diameter = 5/8, threads_per_inch = 27, wall = 2.0, fit = 0.1) {
    diam = diameter * 25.4;
    pitch = (1.0/threads_per_inch)*25.4;
    difference() {
        cylinder(r = (diam / 2) + wall, h = length + band, $fn = facets);
        translate([0, 0, length]) {
            cylinder(r = (diam / 2), h = band, $fn = facets);
        }
        metric_thread (diameter = diam + fit, pitch = pitch, length = length + thin_mint, internal = true);
    }
}

// connector to threaded microphone stand

module shock_mount_threaded_stand(height, wall, stand_wall) {
    // connection to stand
    diam = 5/8 * 25.4;
    thread_length = 15.0;
    stand_mount_thread(thread_length, height - thread_length, wall);
    // connection to microphone
    mount_connector_top(height, diam/2 + wall, diam/2, 23.0);
}

//
// new version of tetra shock mount
//

module tetra_shock_mount_band(band_height, radius, corner, gap) {
    difference() {
        rounded_block_relative(band_height, radius + gap, radius + gap, corner, 3 * wall);
        rounded_block(band_height, radius + gap, radius + gap, corner);
    }
}

// tetra shock mount internal ring

module tetra_shock_mount_internal_ring(height, radius, band_height, corner, gap) {
    difference() {
        // four sided ring
        union() {
            tetra_shock_mount_band(band_height, radius, corner, gap);
            // ridge so that rubber bands stay in the shock mount
            tetra_shock_mount_band(wall, radius, corner, gap + wall);
        }
        // slots inside body so that the ring clears the lower screws
        for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
            translate([radius + gap + 2.5, -2.0, 0]) cube([2.0, 4.0, band_height]);
        }
        // channels in body for upper rubber band
        for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
            rotate([90, 0, 0]) translate([radius + 8.75, 2 * wall + 0.2, 0])
                cylinder(r = 1.0, h = height, center = true, $fn = facets);
        }
    }
    // 8 columns for mounting rubber bands
    for (r = [0, 90, 180, 270]) rotate([0, 0, r]) {
        for (m = [0, 1]) mirror([m, 0, 0]) {
            translate([radius + 4.0 + gap, radius*1/3, 0]) {
                rotate([0, 0, 0]) {
                    difference() {
                        // columns
                        union() {
                            translate([3, 0, 0]) rotate([0, 0, 45]) scale([1.2, 0.85, 1.0]) 
                                cylinder(r = 3, h = height, $fn = facets);
                            // connect column to body
                            translate([-2, -2, 0])
                                cube([4, 3, band_height]);
                            // connect columns together so they cannot bend
                            translate([2, -7, 0])
                                cube([wall, 6, height]);
                        }
                        // lower slots for rubber bands
                        rotate([0, 0, 45]) translate([2.5, radius/2, 2.0]) scale([1.0, 1.0, 2.2]) rotate([90, 0, 0]) {
                            cylinder(r = 1.1, h = radius * 2, $fn = facets);
                        }
                        // upper slots for rubber bands
                        rotate([0, 0, 45]) translate([2.5, radius/2, height - 2.0]) scale([1.0, 1.0, 2.2]) rotate([90, 0, 0]) {
                            cylinder(r = 1.1, h = radius * 2, $fn = facets);
                        }
                    }
                }
            }
        }
    }
}

// tetra shock mount external ring

module tetra_shock_mount_external_ring(height, radius, corner, gap) {
    // main ring
    difference() {
        rounded_block_relative(height, radius, radius, corner, gap);
        rounded_block_relative(height, radius, radius, corner, gap - ring_wall);
    }
    for (rot = [0, 90, 180, 270]) {
        // anchors for rubber bands
        rotate([0, 0, rot + 45]) {
            translate([radius + gap + 2.25 * ring_wall, -5, 0]) {
                minkowski() {
                    cube([4 - 2, 10, ring_ext_height]);
                    cylinder(r = 1.5, h = thin_mint, $fn = facets);
                }
            }
            translate([radius + gap + ring_wall - 2, -2, 0]) {
                cube([9, 4, ring_ext_height]);
            }
        }
    }
    // reinforcement
    intersection() {
        difference() {
            rounded_block_relative(height * 2, radius, radius, corner, gap);
            rounded_block_relative(height * 2, radius, radius, corner, gap - ring_wall);
        }
        //rotate([0, 0, 22.5]) rounded_octagon_wall(ring_ext_height * 2, 2 * radius - ring_wall, ring_wall);
        translate([radius + gap - ring_wall/2, 0, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = 2 * radius, r2 = ring_wall/2 + 1, h = ring_ext_height * 2, $fn = 4);
        }
    }
    // connection to hub
    translate([radius + gap, -2, 0]) {
        cube([10, 4, ring_ext_height * 2]);
    }
    // rotating mount
    o_rad = 8;
    i_rad = 3;
    rotate([0, 90, -90]) {
        translate([-o_rad, radius + gap + o_rad + 8, -2]) {
            shock_mount_ring(o_rad, i_rad, ring_wall);
        }
    }
}

// shock mount to test rig

// model WidowXL
//
// sliding block
arm_l = 10.2 + 0.38;
arm_w = 21.5 + 0.38;
arm_d = 17.6 + 0.1;
// x profile
arm_profile_s = 10.25;
arm_b_prof = 4.25;
// connection socket
arm_s_h = 20.0;

module arm_gripper_block () {
    difference() {
        // body
        translate([-(4 * wall)/2, -2 * wall, 0]) {
            cube([arm_l + 4 * wall, arm_w + 4 * wall, arm_d + arm_s_h]);
        }
        // carve out corners for better fit
        translate([0.2, 0.2, 0]) cylinder(r = 0.4, h = arm_d + arm_s_h, $fn = facets);
        translate([arm_l, 0.2, 0]) cylinder(r = 0.4, h = arm_d + arm_s_h, $fn = facets);
        translate([arm_l, arm_w, 0]) cylinder(r = 0.4, h = arm_d + arm_s_h, $fn = facets);
        translate([0.2, arm_w, 0]) cylinder(r = 0.4, h = arm_d + arm_s_h, $fn = facets);
        // arm gripper block
        union() {
            cube([arm_l, arm_w, arm_d + arm_s_h]);
            translate([-arm_l/2, arm_w/2 - arm_profile_s/2, arm_d - arm_b_prof - arm_profile_s - 10]) {
                cube([20, arm_profile_s, arm_profile_s + 10]);
            }
            // screw holes
            translate([-10 + arm_l/2, 3.15, arm_d - 9.7]) rotate([0, 90, 0]) {
                cylinder(r = 1.94/2, h = 20.0, $fn = facets);
            }
            translate([-10 + arm_l/2, arm_w - 3.15, arm_d - 9.7]) rotate([0, 90, 0]) {
                cylinder(r = 1.94/2, h = 20.0, $fn = facets);
            }
        }
    }
    // add ceiling to body and screw hole
    difference() {
        translate([-(4 * wall)/2, -2 * wall, arm_d]) {
            cube([arm_l + 4 * wall, arm_w + 4 * wall, 3 * wall]);
        }
        translate([arm_l/2, arm_w/2, 0]) cylinder(r = 3.1/2, h = 30, $fn = facets);
    }
}

module tetra_arm_mount(pillar_h, height, radius, band_height, corner, gap) {
    difference() {
        // four sided ring
        union() {
            tetra_shock_mount_band(band_height, radius, corner, gap);
            // ridge so that rubber bands stay in the shock mount
            *tetra_shock_mount_band(wall, radius, corner, gap + wall);
        }
        // slots inside body so that the ring clears the lower screws
        for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
            translate([radius + gap + 2.5, -2.0, 0]) cube([2.0, 4.0, band_height]);
        }
        // channels in body for upper rubber band
        *for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
            rotate([90, 0, 0]) translate([radius + 8.75, 2 * wall + 0.2, 0])
                cylinder(r = 1.0, h = height, center = true, $fn = facets);
        }
    }
    // pillars for arm grips
    sphear_arm_mount_pillars(radius, pillar_h, grip_sep, grip_width, grip_depth);
}

// mount pillars that plug into robotic arm sockets

module sphear_arm_mount_pillars(radius, height, grip_sep, grip_width, grip_depth) {
    // pillars for arm grips
    m_r = 1.0;
    for (m = [0, 1]) mirror([m, 0, 0]) translate([radius + 3 * wall + m_r, - grip_width/2 + m_r, 0]) {
        minkowski() {
            cube([grip_depth - 2*m_r, grip_width - 2*m_r, height]);
            cylinder(r = m_r, h = thin_mint, $fn = 32);
        }
    }
    // transition
    tran_h = 30.0;
    for (m = [0, 1]) mirror([m, 0, 0]) {
        hull() {
            translate([radius + 3 * wall + m_r, -grip_width/2 + m_r, height]) {
                minkowski() {
                    cube([grip_depth - 2 * m_r, grip_width - 2 * m_r, thin_mint]);
                    cylinder(r = m_r, h = thin_mint, $fn = 32);
                }
            }
            translate([grip_sep - wall + m_r, -(arm_w + 2 * fit + 2 * wall)/2 + m_r, height + tran_h]) {
                minkowski() {
                    cube([arm_l - 2 * fit + 2 * wall - 2 * m_r, arm_w - 2 * fit + 2 * wall - 2 * m_r, thin_mint]);
                    cylinder(r = m_r, h = thin_mint, $fn = 32);
                }
            }
        }
    }
    // grip pillar, plugs into slots
    for (m = [0, 1]) mirror([m, 0, 0]) {
        translate([grip_sep + m_r, -(arm_w + 2 * fit)/2 + m_r, height + tran_h]) {
            minkowski() {
                cube([arm_l - 2 * fit - 2 * m_r, arm_w - 2 * fit - 2 * m_r, 20 - 3.0]);
                cylinder(r = m_r, h = thin_mint, $fn = 32);
            }
        }
    }
}
