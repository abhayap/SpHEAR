//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// TinySpHEAR, First Order (B-format) Ambisonics Microphone
// Common files for H2N add-on array
// 
// Copyright 2016-2017, Fernando Lopez-Lezcano, All Rights Reserved
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

include <SpHEAR_common.scad>;
include <SpHEAR_windscreen.scad>;
include <TinySpHEAR_common.scad>;
include <TinySpHEAR_mount_pcb.scad>;

// http://dkprojects.net/openscad-threads/
// used for the threads of the mini-xlm connectors
include <threads.scad>;

// outline of H2N front
// include<h2n/H2N_front_outline.scad>;
// outline of H2N top
// include<h2n/H2N_top_up_outline.scad>;

facets = 128;

// dimensions of the EM200 electret microphone capsule (measured 14.59 max)
capsule_radius = 14.6 / 2;
capsule_height = 4.75;
mic_radius = 11;

// dimensions of the EM182 electret microphone capsule (measured 10mm)
//capsule_radius = 10.0 / 2;
//capsule_height = 4.5;
//mic_radius = 9.2;

// adjust the depth of slots in mount
mic_to_mount_fit = -0.4;

// make triangular legs have the height of the capsule
connect = 1;
leg_thick = capsule_height;

// dimensions of H2R recorder

// width and depth at middle of ring
h2n_width = 62.00;
h2n_depth = 42.66;

h2n_width_up = 57.0;

// h2n_column_height = 40;
// h2n_column_height = 25.3;
h2n_column_height = 23.2;
transition_height = 30;

// measured = 11.50, should be 13.1 -> ratio = 

h2n_side_band = 1.5;
h2n_side_band_w = 13.4;
// h2n_width_m: tried taking out 0.5mm from the original measurement of 63.0, but 
// it is too much and the "Menu" button stops working, 0.25mm seems fine
h2n_width_m = 63.0 - 0.25;
h2n_depth_m = 36.4;

h2n_band_height = 6.0;

// base band width
h2n_band_wall = 1.6;

// wall for the stalk
h2n_stalk_wall = 1.0;

// walls for the columns
h2n_col_wall = 2 * wall;

// tilt for the columnds
h2n_col_tilt = 4.0;

// radius of mount stalk
h2n_mount_radius = mount_radius;

// fit for connector from column to bridge
h2n_mount_fit = 0.04;

// bridge dimensions
h2n_bridge_base_height = 7.0;
h2n_bridge_stalk_height = 45.0;

// bridge funnel and stalk dimensions
h2n_bridge_array_height = 51;
h2n_bridge_cylinder_height = 30;

// thread pedestal
h2n_thread_pedestal = 0.5;

// bridge base dimensions
h2n_bridge_circle = 24.00;
h2n_bridge_band_w = 13.25;
h2n_bridge_band_h = 3.30; // 26.5 - h2n_column_height;

// we need to make the dial cover slightly elliptical
h2n_bridge_circle_max = 26.5;
h2n_bridge_circle_ratio = h2n_bridge_circle_max / h2n_bridge_circle;

// mini-xlr connector parameters
h2n_xlr_thread_diam = 10.0;
h2n_xlr_thread_pitch = 0.75;
h2n_xlr_thread_height = 6.0;
h2n_xlr_thread_depth = 0.614 * h2n_xlr_thread_pitch;
h2n_xlr_height = 30;
h2n_xlr_shoulder = 1.25;
h2n_xlr_stalk_height = 40.0;


module tube(or, ir, h) {
    difference() {
        cylinder(r = or, h = h, $fn = facets);
        cylinder(r = ir, h = h, $fn = facets);
    }
}

// main support ring

module h2n_ring(width, depth, radius, height, tilt, slot_w, slot_d, band_wall, wall, col_rad, col_wall) {
    // main support ring
    difference() {
        conical_rounded_box(height, width / 2 + band_wall, depth / 2 +  band_wall, radius - thin_mint, band_wall, height * tan(tilt));
        for (m = [0, 1]) mirror([m, 0, 0]) {
            translate([-(width / 2 + col_rad - col_wall), 0, 0]) {
                tilted_cylinder(col_rad, height + thin_mint, height * tan(tilt));
            }
        }
    }
    // inner band
    difference() {
        conical_rounded_box(height, width / 2 + wall - h2n_side_band, depth / 2 + wall, radius - thin_mint, wall, height * tan(tilt));
        for (m = [0, 1]) mirror([m, 0, 0]) {
            // cut slots on the sides
            translate([-width / 2 - wall / 2, -h2n_side_band_w / 2, 0]) {
                cube([width / 2, h2n_side_band_w, height + thin_mint]);
            }
        }
    }
    // add TinySpHEAR "branding"
    translate([0, -(h2n_depth_m / 2 + band_wall - 0.55 * wall), h2n_band_height / 2]) scale(0.5) {
        rotate([90 - h2n_col_tilt, 0, 0]) {
            linear_extrude(height = wall, center = "true") {
                text("TinySpHEAR", size = 8.0, spacing = 1.1, halign = "center", valign = "center", font = "Liberation Sans");
            }
        }
    }
}

// side columns

module tilted_cylinder(radius, height, offset) {
    hull() {
        cylinder(r = radius, h = thin_mint, $fn = facets);
        translate([offset, 0, height]) {
            cylinder(r = radius, h = thin_mint, $fn = facets);
        }
    }
}

module tilted_rounded_box(height, width, depth, radius, wall, offset) {
    difference() {
        hull() {
            rounded_block(thin_mint, width, depth, radius);
            translate([offset, 0, height]) {
                rounded_block(thin_mint, width, depth, radius);
            }
        }
        hull() {
            rounded_block_relative(thin_mint, width, depth, radius, -wall);
            translate([offset, 0, height]) {
                rounded_block_relative(thin_mint, width, depth, radius, -wall);
            }
        }
    }
}

module conical_rounded_box(height, width, depth, radius, wall, inset) {
    difference() {
        hull() {
            rounded_block(thin_mint, width, depth, radius);
            translate([0, 0, height]) {
                rounded_block_relative(thin_mint, width, depth, radius, -inset);
            }
        }
        hull() {
            rounded_block_relative(thin_mint, width, depth, radius, -wall);
            translate([0, 0, height]) {
                rounded_block_relative(thin_mint, width, depth, radius, -(wall + inset));
            }
        }
    }
}

module tilted_cube(width, depth, height, offset) {
    hull() {
        cube([width, depth, thin_mint]);
        translate([offset, 0, height]) {
            cube([width, depth, thin_mint]);
        }
    }
}

module tilted_half_rounded_box(height, width, depth, radius, wall, offset, e = 0.1) {
    difference() {
        tilted_rounded_box(height, width, depth, radius, wall, offset);
        translate([0, -(depth + e), 0]) {
            tilted_cube(width + e, (depth + e) * 2, height, offset);
        }
    }
}

module half_rounded_box(height, width, depth, radius, wall, e = 0.1) {
    difference() {
        rounded_box(height, width , depth, radius, wall);
        translate([0, -(depth + e), 0]) {
            cube([width + e, 2 * (depth + e), height]);
        }
    }
}

module h2n_column_core(height, ring_height, tilt, transition, radius, col_wall, wall, offset) {
    hull() {
        // angled column
        difference() {
            tilted_cylinder(radius + col_wall + offset, height, height * tan(tilt));
            translate([0, -(radius + col_wall + offset), 0]) {
                tilted_cube((radius + col_wall) * 2, (radius + col_wall) * 2, height, height * tan(tilt));
            }
        }
        // side sleeves
        // we should derive the geometry for the aligment magic below...
        side_fit = 0.5;
        translate([(radius + col_wall) / 2 + 2 * wall - side_fit, 0, 0]) {
            difference() {
                tilted_half_rounded_box(height, 3.8 + offset, h2n_side_band_w / 2 + wall + offset * 1.1,
                    2.0, wall, height * tan(tilt));
                translate([col_wall / 2 + wall - radius * 3 / 2 - side_fit, 0, 0]) {
                    tilted_cylinder(radius, height, height * tan(tilt));
                }
            }
        }
    }
}

module h2n_column(height, ring_height, tilt, transition, radius, col_wall, wall, screw_mount) {
    difference() {
        union() {
            // side tubes for cables
            difference() {
                h2n_column_core(height, ring_height, tilt, transition, radius, col_wall, wall, 0);
                // hollow out the cylinder
                translate([0, 0, screw_mount]) tilted_cylinder(radius, height, height * tan(tilt));
                // and shave the inside for the screw mount side
                if (screw_mount > 0) {
                    translate([0, -radius, 0]) {
                        tilted_cube(wall * 2, radius * 2, height, height * tan(tilt));
                    }
                }
                // this fine adjustment determines how much the side walls "hug" the H2N
                width_fit = 0.2;
                translate([radius + 2 * wall - width_fit, 0, 0]) {
                    tilted_half_rounded_box(height + thin_mint, 3.8, h2n_side_band_w / 2, 1.5, 4 * wall, height * tan(tilt));
                }
                // trim side of tubes with a vertical plane
                translate([-(radius * 2 + col_wall) + col_wall / 2, -(radius + col_wall), 0]) {
                    cube([col_wall * 2, (radius + col_wall) * 2, 30]);
                }
            }
           // add a thicker wall at the bottom of the side trim
            difference() {
                translate([-(radius), -(radius + col_wall), 0]) {
                    cube([wall, (radius + col_wall) * 2, height]);
                }
                difference() {
                    tilted_cylinder(radius * 4, height, height * tan(tilt));
                    tilted_cylinder(radius + col_wall, height, height * tan(tilt));
                }
            }
        }
        // holes for screws that attach to the columns
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        if (screw_mount > 0) {
            translate([-2 * radius, 0, screw_mount * 3/4]) {
                rotate([0, 90, 0]) {
                    cylinder(r = (1.6 + 0.1)/2, h = 4 * radius, $fn = facets);
                }
                rotate([0, 90, 0]) {
                    cylinder(r = 3.25/2, h = 1.75 * radius, $fn = facets);
                }
            }
        }
    }
    // connector to bridge
    translate([height * tan(tilt), 0, height]) {
        connector_height = 5.0;
        difference() {
            union() {
                difference() {
                    union() {
                        cylinder(r = radius + wall - h2n_mount_fit, h = connector_height, $fn = facets);
                        h2n_column_core(h2n_bridge_band_h, ring_height, 0, transition, radius, col_wall, wall, -(wall + h2n_mount_fit));
                    }
                    cylinder(r = radius, h = connector_height, $fn = facets);
                    translate([1.5, -(radius + wall) * 2, 0]) {
                        cube([radius + wall, (radius + wall) * 4, connector_height]);
                    }
                }
                // add anchor for retaining screw
                difference() {
                    translate([-radius, 0, radius]) {
                        sphere(r = radius * 2/3, $fn = facets);
                    }
                    // and clip out the rest of the sphere
                    difference() {
                        cylinder(r = 2 * radius + wall, h = height);
                        cylinder(r = radius + wall - h2n_mount_fit, h = height);
                    }
                    translate([0, 0, connector_height]) {
                        cylinder(r = radius + wall, h = connector_height);
                    }
                }
            }
            // make hole for screw
            // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
            translate([-(radius + 2 * wall), 0, radius]) {
                rotate([0, 90, 0]) {
                    cylinder(r = 0.7, h = radius + wall, $fn = facets);
                }
            }
        }
    }
}

module h2n_columns(width, height, ring_height, tilt, transition, radius, col_wall, wall) {
    for (m = [0, 1]) mirror([m, 0, 0]) {
        screw_mount = height * 3/4 * (1 - m);
        translate([-(width / 2 + col_wall - wall / 2), 0, 0]) {
            h2n_column(height, ring_height, tilt, transition, radius, col_wall, wall, screw_mount);
        }
    }
}

// old version of columns

module h2n_columns_old(width, height, ring_height, tilt, transition, radius, col_wall, wall) {
    // side tubes for cables
    slot_height = 25.0;
    for (m = [0, 1]) mirror([m, 0, 0]) {
        translate([-(width / 2 + radius - col_wall), 0, 0]) {
            difference() {
                // angled column
                tilted_cylinder(radius + col_wall, height, height * tan(tilt));
                tilted_cylinder(radius, height, height * tan(tilt));
                // slots in the columns for cables
                translate([radius - col_wall - ring_height * tan(tilt), - radius * 2, -ring_height]) {
                    rotate([0, tilt, 0]) {
                        cube([5.0, radius * 4, slot_height]);
                        translate([radius + col_wall, radius - col_wall, slot_height]) {
                            rotate([0, 90, 90]) {
                                cylinder(r = radius + col_wall, h = 15.0, $fn = facets);
                            }
                        }
                    }
                }
                // trim side of tubes with a vertical plane
                translate([-(radius * 2 + col_wall) + col_wall / 2, -(radius + col_wall), 0]) {
                    cube([col_wall * 2, (radius + col_wall) * 2, 30]);
                }
            }
            // add a thicker wall at the bottom of the side trim
            difference() {
                translate([-(radius), -(radius + col_wall), 0]) {
                    cube([wall, (radius + col_wall) * 2, height]);
                }
                difference() {
                    tilted_cylinder(radius * 4, height, height * tan(tilt));
                    tilted_cylinder(radius + col_wall, height, height * tan(tilt));
                }
            }
        }
        // connector to bridge
        translate([-(width / 2 + radius - col_wall - height * tan(tilt)), 0, height]) {
            connector_height = 5.0;
            difference() {
                tube(radius + wall - h2n_mount_fit, radius, connector_height);
                translate([0, -(radius + wall), connector_height / 2]) {
                    cube([radius + wall, (radius + wall) * 2, connector_height / 2]);
                }
            }
        }
        // side sleeves
        sleeve_height = slot_height;
        // XXX sleeve_height = slot_height - mount_radius - col_wall;
        for (m = [0, 1]) mirror([m, 0, 0]) {
            // we should derive the geometry for the aligment magic below...
            side_fit = 1.05;
            translate([-(width / 2 - (radius + col_wall) / 2 + wall - side_fit), 0, 0]) {
                difference() {
                    tilted_half_rounded_box(sleeve_height, 3.8, h2n_side_band_w / 2 + wall, 2.0, wall, sleeve_height * tan(tilt));
                    translate([col_wall / 2 + wall - radius * 3 / 2 - side_fit, 0, 0]) {
                        tilted_cylinder(radius, height, height * tan(tilt));
                    }
                }
            }
        }
    }
}

// bridge that connects to capsule array

module semi_cylinder(r, h, e = thin_mint) {
    difference() {
        cylinder(h, r, r, $fn = facets);
        translate ([-r*2, -r, 0])
            cube([2*(r+e), 2*(r+e), h]);
    }
}

module quarter_sphere(r, e = thin_mint) {
    difference() {
        sphere(r, $fn = facets);
        translate([-(r+e), -(r+e), -(r+e)])
            cube([2*(r+e), 2*(r+e), r+e]);
        translate([-(r+e), -(r+e), -e])
            cube([r, 2*(r+e), (r+e)]);
    }
}

module cylcube(width, depth, height, wall) {
    difference() {
        semi_cylinder(r = depth, h = height);
        semi_cylinder(r = depth - wall, h = height);
    }
    translate([-(width + depth / 2), -depth, 0]) {
        difference() {
            cube([(width + depth / 2), depth * 2, height]);
            translate([0, wall, 0]) {
                cube([(width + depth), (depth - wall) * 2, height]);
            }
        }
    }
}

// old version of the bridge

module h2n_bridge_old(width, base_height, stalk_height, radius, col_wall, wall) {
    // capsule array mount with the right orientation (left front top = #1)
    rotate([0, 0, -90]) translate([0, 0, base_height + stalk_height]) {
        tetra_capsule_array_mount([-45, 135]);
    }
    // stalk
    translate([0, 0, base_height]) {
        difference() {
            tube(radius + wall, radius, stalk_height);
            // remove stalk segment that is inside the bridge
            translate([width / 2, 0, -1.0]) {
                rotate([0, -90, 0]) {
                    semi_cylinder(r = radius + col_wall, h = width);
                }
            }
        }
        // add marker for "back of microphone" orientation
        rotate([0, 0, 0]) {
            translate([0, radius + wall - wall * 2 / 3, stalk_height - radius]) {
                difference() {
                    sphere(r = radius / 3, $fn = 32);
                    translate([0, -radius + radius / 2, 0]) {
                        cube([radius, radius, radius], center = true);
                    }
                }
            }
        }
    }
    // top of bridge
    translate([width / 2, 0, base_height]) {
        rotate([0, -90, 0]) {
            difference() {
                // curvy ceiling
                semi_cylinder(r = radius + col_wall, h = width);
                semi_cylinder(r = radius + col_wall - wall, h = width);
                // make a hole for the cables
                translate([0, 0, width / 2]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = radius, h = 10, $fn = facets);
                    }
                }
            }
        }
    }
    // caps at ends
    for (m = [0, 1]) mirror([m, 0, 0]) {
        translate([width / 2, 0, base_height]) {
            difference() {
                quarter_sphere(r = radius + col_wall);
                quarter_sphere(r = radius + col_wall - wall);
            }
        }
    }
    // base of bridge
    translate([0, 0, 0]) {
        for (m = [0, 1]) mirror([m, 0, 0]) {
            translate([width / 2, 0, 0]) {
                cylcube(width / 2, radius + col_wall, base_height, wall);
            }
        }
    }
    // reinforcement beams at the base
    translate([-col_wall / 2, -(radius + wall), 0]) {
        cube([col_wall, (radius + wall) * 2, col_wall]);
    }
    for (m = [0, 1]) mirror([m, 0, 0]) {
        translate([-width / 2 + radius + wall, -(radius + wall), 0]) {
            cube([col_wall, (radius + wall) * 2, col_wall]);
        }
    }
}

// base plate for upper band cover

module h2n_center_cover_no_ws(width, base_height, radius, wall, offset) {
    bot_step = h2n_bridge_band_h;
    difference() {
        union() {
            for (m = [0, 1]) mirror([m, 0, 0]) {
                // core of bridge
                translate([width/2, -thin_mint / 2, 0]) {
                    cylcube(width / 2 + offset, radius + offset + 2 * wall, bot_step, wall);
                }
                // we should derive the geometry for the aligment magic below...
                side_fit = 1.05;
                corner_radius = 2.0;
                tilted_half_rounded_box(bot_step, width / 2 + offset - wall / 2, h2n_side_band_w / 2 + offset + wall,
                    corner_radius, wall, 0);
            }
        }
        // clear the inside
        // outer frame
        rounded_block(bot_step + thin_mint, width / 2 + offset - 1.5 * wall, h2n_side_band_w / 2 + offset, 2);
        // inner frame
        translate([-(width + offset) / 2, -(radius + wall + offset), 0]) {
            cube([width + offset, (radius + wall + offset) * 2, bot_step + thin_mint]);
        }
    }
}

module h2n_center_cover(width, base_height, radius, wall, offset) {
    bot_step = h2n_bridge_band_h;
    difference() {
        union() {
            for (m = [0, 1]) mirror([m, 0, 0]) {
                // core of bridge
                translate([width/2, -thin_mint / 2, 0]) {
                    cylcube(width / 2 + offset, radius + offset + 2 * wall, bot_step, wall);
                }
                // we should derive the geometry for the aligment magic below...
                side_fit = 1.05;
                corner_radius = 2.0;
                tilted_half_rounded_box(bot_step, width / 2 + offset - wall / 2, h2n_side_band_w / 2 + offset + wall,
                    corner_radius, wall, 0);
            }
        }
        // clear the inside
        // outer frame
        rounded_block(bot_step + thin_mint, width / 2 + offset - 1.5 * wall, h2n_side_band_w / 2 + offset, 2);
        // inner frame
        translate([-(width + offset) / 2, -(radius + wall + offset), 0]) {
            cube([width + offset, (radius + wall + offset) * 2, bot_step + thin_mint]);
        }
    }
}

// base plate for upper center dial cover

module h2n_center_dial_cover(radius, wall, offset) {
    scale([h2n_bridge_circle_ratio, 1, 1]) {
        tube(radius + wall + offset, radius + offset, h2n_bridge_band_h);
    }
}

// the core of the bridge, a solid offset-able version

module h2n_bridge_core_no_ws(width, base_height, radius, col_wall, wall, offset) {
    hull() {
        // top of bridge
        translate([width / 2, 0, base_height]) {
            rotate([0, -90, 0]) {
                // curvy ceiling
                semi_cylinder(r = radius + offset + col_wall, h = width + offset);
            }
        }
        // spherical caps at ends
        for (m = [0, 1]) mirror([m, 0, 0]) {
            translate([width / 2, 0, base_height]) {
                quarter_sphere(r = radius + offset + col_wall);
            }
        }
        // bottom plate
        h2n_center_cover(width, base_height, radius, wall, offset);
    }
    // add cover for center dial
    hull() {
        cylinder(r = mount_radius + offset, h = base_height + radius, $fn = facets);
        h2n_center_dial_cover(h2n_bridge_circle / 2, wall, offset);
    }
}

module h2n_bridge_core(width, base_height, radius, col_wall, wall, thread_radius, thread_height, offset) {
    difference() {
        hull() {
            // top of bridge
            translate([width / 2, 0, base_height]) {
                rotate([0, -90, 0]) {
                    // curvy ceiling
                    semi_cylinder(r = radius + offset + col_wall, h = width + offset);
                }
            }
            // spherical caps at ends
            for (m = [0, 1]) mirror([m, 0, 0]) {
                translate([width / 2, 0, base_height]) {
                    quarter_sphere(r = radius + offset + col_wall);
                }
            }
            // bottom plate
            h2n_center_cover(width, base_height, radius, wall, offset);
            // cover for center dial
            h2n_center_dial_cover(h2n_bridge_circle / 2, wall, offset);
            // base of windscreen mounting thread
            if (thread_radius > 0) {
                translate([0, 0, base_height + radius + col_wall + offset]) {
                    cylinder(r = thread_radius + windscreen_thread_depth + offset, h = wall, $fn = facets);
                }
            }
        }
        // make hole for cables
        translate([0, 0, base_height + radius + col_wall]) {
            cylinder(r = thread_radius - windscreen_thread_depth - wall, h = wall + thin_mint, $fn = facets);
        }
    }
    if (thread_radius > 0 && offset == 0) {
        // pedestal for thread
        translate([0, 0, base_height + radius + col_wall + offset + h2n_thread_pedestal]) {
            difference() {
                cylinder(r = thread_radius + windscreen_thread_depth + offset, h = wall, $fn = facets);
                cylinder(r = thread_radius - windscreen_thread_depth - wall, h = wall, $fn = facets);
            }
        }
        // thread
        translate([0, 0, base_height + radius + col_wall + wall + h2n_thread_pedestal]) {
            difference() {
                metric_thread(diameter = thread_radius * 2, pitch = windscreen_thread_pitch,
                    length = thread_height, angle = windscreen_thread_angle, internal = false);
                cylinder(r = thread_radius - wall - windscreen_thread_depth, h = thread_height + thin_mint, $fn = facets);
            }
        }
    }
}

// the bridge that holds the capsule array

module h2n_bridge_no_ws(width, base_height, stalk_height, radius, col_wall, stalk_wall, wall) {
    // capsule array mount with the right orientation (left front top = #1)0
    rotate([0, 0, -90]) translate([0, 0, base_height + stalk_height]) {
        tetra_capsule_array_mount([-45, 135], mount_radius, stalk_wall);
    }
    difference() {
        union() {
            h2n_bridge_core(width, base_height, radius, col_wall, wall, 0);
            // stalk
            translate([0, 0, base_height]) {
                difference() {
                    tube(radius + stalk_wall, radius, stalk_height);
                    // remove stalk segment that is inside the bridge
                    translate([width / 2, 0, -1.0]) {
                        rotate([0, -90, 0]) {
                            semi_cylinder(r = radius + stalk_wall, h = width);
                        }
                    }
                }
                // add marker for "back of microphone" orientation
                rotate([0, 0, 0]) {
                    translate([0, radius + stalk_wall - stalk_wall * 2 / 3, stalk_height - (radius + stalk_wall)]) {
                        difference() {
                            sphere(r = (radius + stalk_wall) / 3, $fn = 64);
                            translate([0, -(radius + stalk_wall) + (radius + stalk_wall) / 2, 0]) {
                                cube([radius + stalk_wall, radius + stalk_wall, radius + stalk_wall], center = true);
                            }
                        }
                    }
                }
            }
            // small supports for the screws that attach to the columns
            // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
            for (m = [0, 1]) mirror([m, 0, 0]) {
                translate([-(width / 2 + radius + 2 * wall), 0, radius]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
        }
        h2n_bridge_core(width, base_height, radius, col_wall, wall, -wall);
        // make a hole in the bridge for the cables
        cylinder(r = radius, h = base_height + radius + 2 * wall, $fn = facets);
        // cut a window for the XY and MS leds
        translate([0, h2n_bridge_circle_max, 0]) {
            rotate([90, 0, 0]) cylinder(r = 2.0, h = h2n_bridge_circle_max * 2, $fn = facets);
        }
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        translate([-(width + 3 * radius + 2 * wall) / 2, 0, radius]) {
            rotate([0, 90, 0]) {
                cylinder(r = (1.6 + 0.1)/2, h = width + 4 * radius, $fn = facets);
            }
        }
    }
}

// bridge with thread for windscreen mount

module h2n_bridge(width, base_height, stalk_height, radius, col_wall, stalk_wall, wall, thread_radius, thread_height) {
    translate([0, 0, base_height + radius + col_wall + thread_height + h2n_thread_pedestal]) {
        // capsule array mount
        rotate([0, 0, -90]) translate([0, 0, h2n_bridge_array_height]) {
            tetra_capsule_array_mount([-45, 135], mount_radius, wall);
        }
        // cylindrical stalk
        translate([0, 0, h2n_bridge_array_height - h2n_bridge_cylinder_height]) {
            difference() {
                cylinder(r = mount_radius + wall, h = h2n_bridge_cylinder_height, $fn = facets);
                cylinder(r = mount_radius, h = h2n_bridge_cylinder_height, $fn = facets);
            }
        }
        // conical funnel to bridge
        fun_height = h2n_bridge_array_height - h2n_bridge_cylinder_height;
        difference() {
            cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth, r2 = mount_radius + wall,
                    h = fun_height, $fn = facets);
            cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth - wall, r2 = mount_radius,
                    h = fun_height, $fn = facets);
        }
    }
    difference() {
        union() {
            h2n_bridge_core(width, base_height, radius, col_wall, wall, thread_radius, thread_height, 0);
            // small supports for the screws that attach to the columns
            // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
            for (m = [0, 1]) mirror([m, 0, 0]) {
                translate([-(width / 2 + radius + 2 * wall), 0, radius]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
        }
        h2n_bridge_core(width, base_height, radius, col_wall, wall, thread_radius, thread_height, -wall);
        // cut a window for the XY and MS leds
        translate([0, h2n_bridge_circle_max, 0]) {
            rotate([90, 0, 0]) cylinder(r = 2.0, h = h2n_bridge_circle_max * 2, $fn = facets);
        }
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        translate([-(width + 3 * radius + 2 * wall) / 2, 0, radius]) {
            rotate([0, 90, 0]) {
                cylinder(r = (1.6 + 0.1)/2, h = width + 4 * radius, $fn = facets);
            }
        }
    }
}


// a bridge with detachable stalk and capsule array (attaches with an 8 pin mini-xlr connector)

module h2n_mini_xlr_thread(diam, pitch, height) {
    metric_thread(diameter = diam, pitch = pitch, length = height, internal = true);
}

// bridge and threaded housing for female mini-xlr connector

module h2n_bridge_connector(width, base_height, radius, col_wall, stalk_wall, wall) {
    difference() {
        union() {
            h2n_bridge_core(width, base_height, radius, col_wall, wall, 0);
            // connector
            translate([0, 0, base_height]) {
                difference() {
                    cylinder(r = h2n_xlr_thread_diam/2 + stalk_wall, h = h2n_xlr_height, $fn = facets);
                    // remove the thread
                    translate([0, 0, h2n_xlr_height - h2n_xlr_thread_height - h2n_xlr_shoulder]) {
                        rotate([0, 0, 45]) {
                            h2n_mini_xlr_thread(h2n_xlr_thread_diam, h2n_xlr_thread_pitch, h2n_xlr_thread_height);
                        }
                    }
                    // remove excess above the thread
                    translate([0, 0, h2n_xlr_height - h2n_xlr_shoulder]) {
                        cylinder(r = h2n_xlr_thread_diam/2 + h2n_xlr_thread_depth, h = h2n_xlr_shoulder, $fn = facets);
                    }
                    // make hole below the thread
                    cylinder(r = h2n_xlr_thread_diam/2, h = h2n_xlr_height - h2n_xlr_thread_height - h2n_xlr_shoulder,
                             $fn = facets);
                    // remove stalk segment that is inside the bridge
                    translate([width / 2, 0, -1.0]) {
                        rotate([0, -90, 0]) {
                            semi_cylinder(r = h2n_xlr_thread_diam/2 + stalk_wall, h = width);
                        }
                    }
                }
            }
            // small supports for the screws that attach to the columns
            // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
            for (m = [0, 1]) mirror([m, 0, 0]) {
                translate([-(width / 2 + radius + 2 * wall), 0, radius]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
            // add ridge for connector (stops the inner core of the connector from being pushed down)
            h_fit = 0.95;
            translate([0, 0, h2n_xlr_height - h2n_xlr_thread_height - h2n_xlr_shoulder + 5 - h_fit]) {
                tube(h2n_xlr_thread_diam/2 + stalk_wall, h2n_xlr_thread_diam/2 - 1.0, 5);
                translate([0, 0, -1.0]) {
                    difference() {
                        cylinder(r = h2n_xlr_thread_diam/2, h = 1.0, $fn = facets);
                        cylinder(r2 = h2n_xlr_thread_diam/2 - 1.0, r1 = h2n_xlr_thread_diam/2, h = 1.0, $fn = facets);
                    }
                }
            }
        }
        h2n_bridge_core(width, base_height, radius, col_wall, wall, -wall);
        // make a hole in the bridge for the cables
        cylinder(r = h2n_xlr_thread_diam/2, h = base_height + radius + 2 * wall, $fn = facets);
        // cut a window for the XY and MS leds
        translate([0, h2n_bridge_circle_max, 0]) {
            rotate([90, 0, 0]) cylinder(r = 2.0, h = h2n_bridge_circle_max * 2, $fn = facets);
        }
        // holes for screws that attach to the columns
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        translate([-(width + 3 * radius + 2 * wall) / 2, 0, radius]) {
            rotate([0, 90, 0]) {
                cylinder(r = (1.6 + 0.1)/2, h = width + 4 * radius, $fn = facets);
            }
        }
    }
}

// threaded housing for male mini-xlr connector

module h2n_connector_to_stalk(width, height, thread_height, thread_diam, thread_pitch, shoulder, stalk_wall) {
    difference() {
        cylinder(r = thread_diam/2 + stalk_wall, h = height, $fn = facets);
        // remove the thread
        translate([0, 0, shoulder]) {
            rotate([0, 0, 90]) {
                h2n_mini_xlr_thread(thread_diam, thread_pitch, thread_height);
            }
        }
        // remove excess above the thread
        translate([0, 0, shoulder + thread_height]) {
            cylinder(r = thread_diam/2, h = height, $fn = facets);
        }
        // make hole below the thread
        cylinder(r = thread_diam/2, h = shoulder, $fn = facets);
    }
    // add ridge for connector (stops the inner core of the connector from being pushed down)
    translate([0, 0, h2n_xlr_thread_height - h2n_xlr_shoulder + 1.0]) {
        tube(h2n_xlr_thread_diam/2 + stalk_wall, h2n_xlr_thread_diam/2 - 1.0, 5);
        translate([0, 0, -1.0]) {
            difference() {
                cylinder(r = h2n_xlr_thread_diam/2, h = 1.0, $fn = facets);
                cylinder(r2 = h2n_xlr_thread_diam/2 - 1.0, r1 = h2n_xlr_thread_diam/2, h = 1.0, $fn = facets);
            }
        }
    }
}

// stalk and capsule array mount (clips on mini-xlr housing, rotates to orient capsule array)

module h2n_stalk_to_array_mount(width, stalk_height, stalk_wall) {
    // conical stalk to the capsule array mount
    difference() {
        cylinder(r1 = h2n_xlr_thread_diam/2 + stalk_wall, r2 = mount_radius + stalk_wall, h = stalk_height, $fn = facets);
        cylinder(r1 = h2n_xlr_thread_diam/2, r2 = mount_radius, h = stalk_height, $fn = facets);
        // avoid overhang for printing
        trans = 1.0;
        difference() {
            cylinder(r2 = h2n_xlr_thread_diam/2 + stalk_wall * 2, r1 = h2n_xlr_thread_diam/2 + stalk_wall * 4, h = trans, $fn = facets);
            cylinder(r2 = h2n_xlr_thread_diam/2 + stalk_wall, r1 = h2n_xlr_thread_diam/2, h = trans, $fn = facets);
        }
    }
    // press fit connector to stalk mini-xlr connector
    translate([0, 0, -3]) {
        tube(h2n_xlr_thread_diam/2, h2n_xlr_thread_diam/2 - wall, 6.0);
    }
    // capsule array mount with the right orientation (left front top = #1)0
    rotate([0, 0, -90]) translate([0, 0, stalk_height]) {
        tetra_capsule_array_mount([-45, 135], mount_radius, stalk_wall);
    }
}

// components for a wind screen cage

module h2n_wind_screen_old(width) {
    *for (m = [0, 1]) mirror([m, 0, 0]) {
        translate([width/2, 0, 0]) {
            cube([2, 2, 90]);
        }
    }
    for (m = [0, 1]) mirror([0, m, 0]) {
        translate([0, 10, 0]) {
            rotate([0, 90, 90]) {
                half_rounded_box(2, 130, h2n_width_m/2 + mount_radius + h2n_col_wall, 25, 2);
            }
        }
    }
    translate([0, 0, 100]) {
        rounded_box(2, h2n_width_m/2 + mount_radius + h2n_col_wall, 30, 25, 2);
    }
}

// wind screen support modules

module h2n_wind_screen_vertical_ring(diameter, thickness, collar_height) {
    radius = diameter / 2;
    w = thickness;
    // vertical main ring with four slots and half collar
    difference() {
        union() {
            translate([-w, 0, w/2]) {
                rotate([0, 90, 0]) {
                    tube(radius, radius - w, w);
                    // side locks
                    for (r = [0, 1]) rotate([0, 0, 90 * r]) {
                        for (m = [0, 1]) mirror([0, m, 0]) {
                            translate([-w*1.5, radius - 2*w, 0]) {
                                cube([w*3, w*1.5, w]);
                            }
                        }
                    }
                }
            }
        }
        // cut slots for vertical rings
        tube(radius + w, radius - w, w);
        translate([0, -w/2, w/2]) {
            rotate([0, 90, 90]) {
                tube(radius + w, radius - w, w);
            }
        }
        // remove lower cylinder
        translate([0, 0, -radius]) {
            cylinder(r = h2n_mount_radius + h2n_col_wall, h = 3 * w, $fn = facets);
        }
    }
    // cylindrical attachment to mount
    difference() {
        union() {
            translate([0, 0, -(radius + 5)]) {
                tube(h2n_mount_radius + h2n_col_wall, h2n_mount_radius + wall, collar_height);
            }
            // mount for bottom screws
            for (m = [0, 1]) mirror([0, m, 0]) translate([-w, h2n_mount_radius + 2 * wall + 2.0, -(radius)]) {
                minkowski() {
                    rotate([0, 90, 0]) {
                        cylinder(r = 2.0, h = w, $fn = facets);
                    }
                    translate([0, -2, -2]) {
                        cube([w, 1.5 * w, 4]);
                    }
                }
            }
        }
        // remove half the tube
        translate([0, -2 * (h2n_mount_radius + h2n_col_wall), -(radius + collar_height / 2)]) {
            cube([h2n_mount_radius + h2n_col_wall, 4 * (h2n_mount_radius + h2n_col_wall), collar_height]);
        }
        // make holes for screws
        for (m = [0, 1]) mirror([0, m, 0]) translate([-w, h2n_mount_radius + 2 * wall + 2.0, -(radius)]) {
            rotate([0, 90, 0]) {
                cylinder(r = 1.0, h = w, $fn = facets);
            }
        }
        // remove inside mounts
        translate([0, 0, -(radius + 5)]) {
            cylinder(r = h2n_mount_radius + wall, h = collar_height, $fn = facets);
        }
    }
}

module h2n_wind_screen_horizontal_ring(diameter, thickness) {
    radius = diameter / 2;
    w = thickness;
    // horizontal ring with two slots
    difference() {
        union() {
            tube(radius, radius - w, w);
            // side lock supports
            rotate([0, 0, 90]) {
               for (m = [0, 1]) mirror([0, m, 0]) {
                    translate([-w*1.5, radius - 2*w, 0]) {
                        cube([w*3, w*1.5, w]);
                    }
                }
            }
            // stops to assemble into vertical ring
            for (m = [0, 1]) mirror([0, m, 0]) translate([-2*w, radius - w, w]) {
                cube([w, w, w]);
            }
        }
        // cut slot for vertical secondary ring
        translate([0, -w/2, w/2]) {
            rotate([0, 90, 90]) {
                tube(radius + w, radius - w, w);
            }
        }
        // make into an arc (1/2 of the ring)
        translate([0, -diameter/2, 0]) {
            cube([diameter, diameter, w]);
        }
   }
}

module h2n_wind_screen_vertical_aux_ring(diameter, thickness) {
    radius = diameter / 2;
    w = thickness;
    difference() {
        union() {
            translate([0, -w/2, w/2]) {
                rotate([0, 90, 90]) {
                    tube(radius, radius - w, w);
                }
            }
            // stop to assemble into vertical ring
            rotate([90, 0, 0]) translate([-2*w, radius - w/2, w/2]) {
                cube([w, w, w]);
            }
        }
        // remove lower cylinder
        translate([0, 0, -radius]) {
            cylinder(r = h2n_mount_radius + h2n_col_wall, h = 3 * w, $fn = facets);
        }
        // make into an arc (1/2 of the ring)
        rotate([0, 90, 90]) translate([-(diameter/2 + w/2), -diameter, -w]) {
            cube([diameter, diameter, 2*w]);
        }
    }
}

// lower windscreen with threaded mount

module h2n_lower_windscreen(sides, height, radius, wradius, beam_radius, conn_radius, pin_height, connectors = true) {
    ang = 360 / sides;
    // connector to upper frame
    for (r = [1:360/sides:360]) rotate([0, 0, r]) {
        translate([wradius, -beam_radius/2, height - pin_height + 1]) {
            render() {
                difference() {
                    sphere(r = conn_radius, $fn = facets);
                    translate([-2 * conn_radius, -2 * conn_radius, (conn_radius - beam_radius) / 2]) {
                        cube([4 * conn_radius, 4 * conn_radius, 4 * conn_radius]);
                    }
                }
                // pin
                cylinder(r = beam_radius - fit, h = pin_height, $fn = facets);
            }
        }
    }
    // beams to threaded mount
    rotate([0, 0, ang/2]) {
        sphear_windscreen_inset_frame(sides, height - 4, wradius, 
            radius, beam_radius, 1.66, 1.2);
    }
    // threaded mount
    sphear_windscreen_round_mount(windscreen_thread_height, windscreen_thread_radius, windscreen_thread_radius + 4 * wall, 2 * wall);
}

////
//// Render components specific to the H2N design

// render full windscreen with threaded mount

module render_h2n_windscreen(zoffset) {
    sides = 12;
    ang = 360 / sides;
    translate([0, 0, zoffset]) {
        h2n_lower_windscreen(sides, height, radius, beam_radius, conn_radius, pin_height, connectors = true)
        // dome at top
        translate([0, 0, windscreen_height / 2+ windscreen_height]) {
            sphear_windscreen_dome(sides,  box_corner_radius + 4 * beam_radius, beam_radius);
        }
        // spiral wireframe
        translate([0, 0, windscreen_height / 2]) {
            sphear_windscreen_frame(sides, box_corner_radius + 4 * beam_radius, windscreen_height, beam_radius, 45);
        }
        // crossing reinforcements
        // first mid crossing
        translate([0, 0, windscreen_height / 2 + windscreen_height/3]) {
            sphear_windscreen_frame_reinforcements(sides, box_corner_radius + 4 * beam_radius, beam_radius, ang/2, 0);
        }
        // second mid crossing
        translate([0, 0, windscreen_height / 2 + windscreen_height*2/3]) {
            sphear_windscreen_frame_reinforcements(sides, box_corner_radius + 4 * beam_radius, beam_radius, 0, 0);
        }
        // to dome
        translate([0, 0, windscreen_height / 2 + windscreen_height]) {
            sphear_windscreen_frame_reinforcements(sides, box_corner_radius + 4 * beam_radius, beam_radius, ang/2, 0);
        }
        // to threaded mount (these are tilted slightly and inset a little bit)
        translate([0, 0, windscreen_height / 2]) {
            sphear_windscreen_frame_reinforcements(sides, box_corner_radius + 4 * beam_radius - 0.15, beam_radius, 0, 10);
        }
        // beams to threaded mount
        rotate([0, 0, ang/2]) {
            sphear_windscreen_inset_frame(sides, windscreen_height/2, box_corner_radius + 4 * beam_radius, 
                windscreen_thread_radius + 2 * wall, 
                beam_radius, 1.66, 1.2);
        }
        // threaded mount
        rotate([0, 0, 90]) {
            sphear_windscreen_round_mount(windscreen_thread_height, windscreen_thread_radius, 2 * wall);
        }
    }
}

//

module render_h2n_lower_windscreen(zoffset) {
    translate([0, 0, zoffset]) {
        h2n_lower_windscreen(12, windscreen_lower_height, windscreen_thread_radius + 2 * wall, windscreen_radius,
                windscreen_beam_radius, windscreen_conn_radius, windscreen_pin_height, connectors = true);
    }
}
