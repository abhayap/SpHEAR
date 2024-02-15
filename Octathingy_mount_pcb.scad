////
// Spherical Harmonics Ear Project (*SpHEAR)
//
// OctaSpHEAR or Octathingy, Second Order Ambisonics Microphone
//
// based on:
// "A second-order soundfield microphone with improved polar pattern shape"
// by Eric Benjamin, Audio Engineering Society Convention Paper 8728, 
// October 2012, San Francisco
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

// d-sub connector
include <db25.scad>;

////
//// rendering control
////

// render version 2 printed circuit board and parts
render_pcb = false;

////
//// default model parameters
////

// capsule array mount, height of flare and stalk
flare_height = 50;
stalk_height = 60;

// calculated minimum "radius" of microphone box
box_radius = pcb_front + (pcb_thickness + pcb_tfit) + pcb_back + 2 * wall;

// calculated main body corner radius
mount_corner = box_radius - pcb_width / 2 + pcb_slot_depth + 4.0;

// body parameters
radial_pcb_offset = pcb_version == 2 ? 15.0 : 17.0;
octa_pcb_mount_height = pcb_length - pcb_low_exp - pcb_hi_exp;
octa_pcb_wall = (pcb_version == 2 ? 4.75 : 5) * wall;
// windscreen thread offset
octa_pcb_thread_offset = (pcb_version == 2 ? -1.82 : 0.0);
octa_pcb_radius = radial_pcb_offset + pcb_width/2 + octa_pcb_wall;

// shock mount parameters
//

internal_ring_height = 55.0;
external_ring_height = 10.0;
rubber_band_angle = 45;
main_radius_inc = (internal_ring_height / 2) / tan(rubber_band_angle);

// gap between internal ring and microphone body
internal_ring_gap = 1.0;

// connector that joins the two internal rings
connector_w = 10.0;
connector_d = 2.0;

// wall thickness and height of shock mount rings
ring_wall = 4 * wall;
ring_ext_height = 6;

// gap between external ring and support arm
ring_arm_gap = 16;


// the main body that holds the phantom power interfaces

// one printed circuit board with space in the back and front

module one_pcb_slot (height, pcb_w, pcb_l, pcb_t, pcb_offset, slot_d, front, back, test = false) {
    render() translate([-(pcb_w/2 + 0.5), 0, 0]) {
        // printed circuit board with space for solder and components
        cube([pcb_w, pcb_t, pcb_l]);
        // open space in back and front
        // tune front and back by hand
        translate([slot_d, -2.0, 0]) cube([pcb_w - (2.0 * slot_d), 15, pcb_l]);
        // make top and bottom entry channels
        translate([slot_d, pcb_t/2, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = pcb_t * 1.1, r2 = 0, h = 8.0, $fn = 4);
        }
        translate([pcb_w - slot_d, pcb_t/2, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = pcb_t * 1.1, r2 = 0, h = 8.0, $fn = 4);
        }
        translate([slot_d, pcb_t/2, height - 8.0]) {
            rotate([0, 0, 45]) cylinder(r2 = pcb_t * 1.1, r1 = 0, h = 8.0, $fn = 4);
        }
        translate([pcb_w - slot_d, pcb_t/2, height - 8.0]) {
            rotate([0, 0, 45]) cylinder(r2 = pcb_t * 1.1, r1 = 0, h = 8.0, $fn = 4);
        }
    }
}

// the printed circuit board and parts (for testing fit inside body of microphone)

module one_pcb_parts (height, pcb_w, pcb_l, pcb_t, pcb_offset, slot_d, front, back) {
    //render() translate([-(pcb_w/2 + wall), -(back + wall), 0]) {
    render() translate([-(pcb_w/2 + 0.5), 0, 0]) {
        // printed circuit board
        translate([0, 0, pcb_offset]) cube([pcb_w, pcb_t, pcb_l]);
        // small electrolytic capacitors (pcb_version == 2)
        // https://www.mouser.com/datasheet/2/293/e-umw-1219455.pdf
        cap_diam = 8.0;
        // should be 5, but transistors are a bit taller;
        cap_len = 6.0;
        translate([pcb_w/2, cap_len + pcb_t, 6]) {
            rotate([90, 0, 0]) cylinder(r = (cap_diam/2), h = cap_len, $fn = facets);
        }
        // film capacitors
        cap_h = 12;
        cap_w = 9;
        cap_t = 5.5;
        translate([pcb_w/2 - cap_w/2, pcb_t, 10]) {
            cube([cap_w, cap_t, cap_h]);
        }
    }
}

// octagonal body

module rounded_octagon(height, radius) {
    intersection() {
        cylinder(r = radius, h = height, $fn = 8);
        cylinder(r = radius - wall, h = height + thin_mint, $fn = facets);
    }
}

module rounded_octagon_wall(height, radius, wall) {
    difference() {
        rounded_octagon(height, radius);
        rounded_octagon(height + thin_mint, radius - wall);
    }
}

// twist angle to optimize space usage inside body
octa_pcb_twist = pcb_version == 2 ? 13.5 : 16;
// tilt angle to clear upper flare thread
octa_pcb_tilt = pcb_version == 2 ? -0.7 : 0.0;

module octa_mount_body(height, radius, lower_lip, upper_lip, clear) {
    // rotate pcb assembly so it does not interfere with the screws
    offset_angle = -octa_pcb_twist;
    // rotate individual pcb's to better use the internal space of the body
    twist_angle = octa_pcb_twist;
    difference() {
        union() {
            difference() {
                union() {
                    // main body
                    rounded_octagon_wall(height, radius, 2 * wall);
                    difference() {
                        // fill the inside of the body
                        translate([0, 0, -1]) rounded_octagon(height * 2/3, radius);
                        // remove everything else
                        union() {
                            translate([0, 0, -1]) for (r = [0:360/8:360]) rotate([0, octa_pcb_tilt, r + offset_angle]) {
                                translate([radial_pcb_offset, 0, 0]) {
                                    rotate([0, 0, 180 + twist_angle]) {
                                        one_pcb_slot(height * 2/3, pcb_width + pcb_fit, pcb_length, pcb_thickness + pcb_tfit, -10,
                                            pcb_slot_depth, pcb_front, pcb_back);
                                    }
                                }
                            }
                            // make center hole
                            cylinder(r = 6.0, h = height, $fn = facets);
                        }
                    }
                    translate([0, 0, -1]) for (r = [0:360/8:360]) rotate([0, octa_pcb_tilt, r + offset_angle]) {
                        translate([radial_pcb_offset, 0, 0]) {
                            rotate([0, 0, 180 + twist_angle]) {
                                // add wall that connects core with outer shell
                                translate([-(pcb_width/2 + 2 * wall), -(wall + pcb_back), 0]) {
                                    cube([pcb_width + 2 * wall, wall, height * 2/3]);
                                }
                                if (render_pcb) {
                                    // add components if we are testing for fit
                                    one_pcb_parts(height * 2/3, pcb_width + pcb_fit, pcb_length, pcb_thickness + pcb_tfit, -10,
                                        pcb_slot_depth, pcb_front, pcb_back);
                                }
                           }
                        }
                    }
                }
                // clip inside of body below body (we need this because of pcb tilt)
                translate([0, 0, -2.0]) rounded_octagon(2.0, radius);
                // upper lip for flare to microphone
                translate([0, 0, height - upper_lip]) {
                    rounded_octagon_wall(upper_lip, radius, wall + lip_fit);
                }
                // lower lip for flare to cable or connector
                translate([0, 0, 0]) {
                    rounded_octagon_wall(upper_lip, radius, wall + lip_fit);
                }
            }
            // add backplates for upper lip screws
            for (r = [45, 135, 225, 315]) {
                rotate([0, 0, r]) translate([-(radius - 3 * wall), -2.5, 0]) {
                    cube([2, 5, height]);
                }
            }
        }
        // make eight holes in the the body for screws that hold both flares
        // (number 0 size, 1/4" long = thread diameter: 1.6mm, head diameter: 2.75)
        difference() {
            for (z = [lower_lip/2, height - upper_lip/2]) {
                for (r = [45, 135, 225, 315]) {
                    rotate([0, 0, r]) translate([-(radius + 2 * wall), 0, z]) {
                        rotate([0, 90, 0]) {
                            cylinder(r = 0.7, h = radius + wall, $fn = facets);
                        }
                    }
                }
            }
            cylinder(r = radius/2, h = height);
        }
    }
}

// stalk from flare to capsule array mount (for version 1 microphone)

module octa_mount_stalk(height, lip, transition, radius, top_radius, stalk_height, dot) {
    translate([0, 0, height + transition]) {
        translate ([0, 0, -10.0]) difference() {
            cylinder(r = top_radius, h = stalk_height + 10.0, $fn = facets);
            cylinder(r = top_radius - wall, h = stalk_height + 10.0, $fn = facets);
        }
        // close stalk and add holes for cables
        translate([0, 0, stalk_height - top_radius - wall]) {
            difference() {
                cylinder(r = top_radius - wall, h = top_radius + wall, $fn = facets);
                translate([0, 0, 0]) {
                    sphere(r = top_radius - wall, $fn = facets);
                }
                wire_diam = mic_wire_diam + mic_wire_fit;
                for (r = [0, 90, 180, 270]) rotate([0, 0, r]) {
                    for (t = [0, 1]) {
                        rotate([0, 0, 45 * t]) translate([top_radius - wire_diam - t * wire_diam * 2/3, 0, wall]) {
                            cylinder(r = wire_diam / 2, h = top_radius * 2, $fn = facets);
                        }
                    }
                }
                translate([0, 0, wall]) cylinder(r = wire_diam, h = top_radius * 2, $fn = facets);
            }
        }
        // add flange for coupling into flare
        difference() {
            cylinder(r2 = top_radius, r1 = top_radius + wall, h = 10.0, $fn = facets);
            cylinder(r2 = top_radius - wall, r1 = top_radius, h = 10.0, $fn = facets);
        }
        translate([top_radius, 0, -10.0]) {
            // add key to stalk so orientation is always correct
            difference() {
                cylinder(r = 0.4, h = 10.0, $fn = facets);
            }
        }
    }
}

// flare from body to capsule array stalk

module octa_mount_flare(height, lip, transition, radius, top_radius, stalk_height, dot) {
    // transition from bottom box to windscreen mounting thread
    transition_to_threads = 5;
    // bottom box
    difference() {
        union() {
            rounded_octagon_wall(height - windscreen_thread_height, radius, 2 * wall);
            // small pedestals for the screws that attach the flare to the body
            // (number 0 size, 1/4" long = thread diameter: 1.6mm, head diameter: 2.75)
            for (r = [45, 135, 225, 315]) rotate([0, 0, r]) {
                translate([radius - wall - 1.75, 0, lip/2]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
            // indicator of "front" of microphone
            rotate([0, 0, 180 + 22.5]) translate([radius - 2, 0, 0]) {
                cylinder(r = 1.0, h = lip/3, $fn = facets);
            }
            // stops for shock mount
            for (r = [0, 90, 180, 270]) rotate([0, 0, r - 22.5]) {
                translate([radius - 3.4, 0, 0]) scale([2.0, 1.0, 1.0]) {
                    difference() {
                        // cylinder(r = 2.0, h = lip + transition_to_threads, $fn = facets);
                        cylinder(r = 2.0, h = 5.0, $fn = facets);
                        translate([-2, -2.0, 0]) cube([2.0, 4.0, lip + transition_to_threads]);
                    }
                }
            }
        }
        // flange to mount on body
        rounded_octagon_wall(lip + 1.00, radius - wall, wall);
        // and make a smooth transition to avoid overhangs
        translate([0, 0, lip + 1.00]) {
            hull() {
                rounded_octagon_wall(thin_mint, radius - wall, wall);
                translate([0, 0, 1.0]) {
                    rounded_octagon_wall(thin_mint, radius - 2 * wall, wall);
                }
            }
        }
        // holes for screws that attach the flare to the body
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        for (r = [45, 135, 225, 315]) rotate([0, 0, r]) {
            translate([radius/2, 0, lip/2]) {
                rotate([0, 90, 0]) {
                    cylinder(r = (1.6 + 0.1)/2, h = radius, $fn = facets);
                }
            }
        }
    }
    // windscreen mounting threads
    translate([0, 0, height - windscreen_thread_height]) difference() {
        metric_thread(diameter = windscreen_thread_radius * 2, pitch = windscreen_thread_pitch,
            length = windscreen_thread_height, angle = windscreen_thread_angle, internal = false);
        cylinder(r = windscreen_thread_radius - wall - windscreen_thread_depth, h = windscreen_thread_height + thin_mint, $fn = facets);
        // clip thread tips
        difference() {
            cylinder(r = windscreen_thread_radius + wall, h = windscreen_thread_height + thin_mint, $fn = facets);
            cylinder(r = windscreen_thread_radius - windscreen_thread_depth * 0.3, h = windscreen_thread_height + thin_mint, $fn = facets);
        }
    }
    // flare to stalk
    translate([0, 0, height - 1.5]) {
        difference() {
            cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth,
                r2 = top_radius + wall + fit, h = transition + 1.5, $fn = facets);
            cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth - wall,
                r2 = top_radius + fit, h = transition + 1.5, $fn = facets);
        }
    }
    // socket for stalk
    s_length = 10.0;
    translate([0, 0, height + transition - s_length]) {
        difference() {
            cylinder(r = top_radius + wall + fit, h = s_length, $fn = facets);
            cylinder(r = top_radius + fit, h = s_length, $fn = facets);
            // add key slot for orientation
            translate([top_radius, 0, -1]) {
                cylinder(r = 0.4, h = s_length + 2, $fn = facets);
            }
        }
    }
    // internal flare for stalk
    translate([0, 0, height - 1.5]) {
        difference() {
            cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth,
                r2 = top_radius + wall + fit, h = transition + 1.5 - s_length, $fn = facets);
            cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth - wall,
                r2 = top_radius + fit, h = transition + 1.5 - s_length, $fn = facets);
        }
    }
}

// flare from the body to a dual cable housing

module octa_mount_flare_dual(height, lip, transition, xradius, yradius, corner, top_radius, stalk_height) {
    // hack to get it to render, fix problem in rounded_block when radius is equal to corner...
    delta = 0.001;
    difference() {
        union() {
            // bottom rounded box
            difference() {
                rounded_block(height, xradius, yradius, corner);
                rounded_block_relative(height, xradius, yradius, corner, -(2 * wall));
                // flange to mount on body
                rounded_block_relative(lip + 1.00, xradius, yradius, corner, - (wall));
                // and make a smooth transition to avoid overhangs
                translate([0, 0, lip + 1.00]) {
                    hull() {
                        rounded_block_relative(thin_mint, xradius, yradius, corner, - wall);
                        translate([0, 0, 1.0]) {
                            rounded_block_relative(thin_mint, xradius, yradius, corner, - 2 * wall);
                        }
                    }
                }
            }
            // flare to rounded section
            translate([0, 0, height]) {
                difference() {
                    hull() {
                        rounded_block(thin_mint, xradius, yradius, corner);
                        translate([0, 0, transition]) {
                            rounded_block(thin_mint, top_radius + wall / 2, top_radius * 2 + wall / 2, top_radius - delta);
                        }
                    }
                    hull() {
                        rounded_block_relative(thin_mint, xradius, yradius, corner, - 2 * wall);
                        translate([0, -top_radius, transition]) {
                            cube([thin_mint, (top_radius) * 2, thin_mint]);
                        }
                    }
                }
            }
            // corner box cable stalk
            translate([0, 0, height + transition]) {
                rounded_block(stalk_height, top_radius + wall  / 2, top_radius * 2 + wall / 2, top_radius - delta);
            }
        }
        // holes for the cables
        for (offset = [top_radius - wall/2, -(top_radius - wall/2)]) {
            translate([0, offset, 0]){
                cylinder(r = top_radius - wall, h = height + transition + stalk_height, $fn = facets);
            }
        }
    }
}

// flare from the body to a dual conector housing

// bottom connector holder

module tetra_mount_connector_holder(height, radius, inside_radius, sleeve_height, sleeve_radius) {
    difference() {
        union() {
            cylinder(r = radius, h = height, $fn = facets);
            // add seats for screw heads
            for (m = [-1, 1]) translate([m * conn_core_holes_w / 2, radius / 2, conn_core_holes_h]) {
                rotate([90, 0, 0]) {
                    scale([1, 1, 1]) cylinder(r = conn_core_screw_d / 2, h = radius * 1.43, $fn = facets);
                }
            }
        }
        cylinder(r = inside_radius, h = height, $fn = facets);
        // transition from thin wall to thick wall at the bottom of connector
        *cylinder(r1 = radius - wall, r2 = inside_radius, h = 2.0, $fn = facets);
        // holes for connector core screws
        for (m = [-1, 1]) translate([m * conn_core_holes_w / 2, - radius / 3, conn_core_holes_h]) {
            rotate([90, 0, 0]) {
                cylinder(r = conn_core_holes_d / 2, h = radius, $fn = facets);
            }
        }
        // substract cutout for screw heads
        for (m = [-1, 1]) translate([m * conn_core_holes_w / 2, - radius + 1.5, conn_core_holes_h]) {
            rotate([90, 0, 0]) {
                cylinder(r = conn_core_screw_d / 2, h = 2.0, $fn = facets);
            }
        }
    }
    // thinner cylinder sits inside connector sleeve
    translate([0, 0, height]) {
        difference() {
            cylinder(r = sleeve_radius, h = sleeve_height, $fn = facets);
            cylinder(r = inside_radius, h = sleeve_height, $fn = facets);
        }
    }
}

// flare to dual cable connectors

module octa_mount_flare_connector(height, lip, transition, radius, top_xradius, top_yradius) {
    // hack to get it to render, fix problem in rounded_block when radius is equal to corner...
    delta = 0.001;
    // bottom rounded box
    difference() {
        union() {
            rounded_octagon_wall(height, radius, 2 * wall);
            // small pedestals for the screws that attach the flare to the body
            // (number 0 size, 1/4" long = thread diameter: 1.6mm, head diameter: 2.75)
            for (r = [45, 135, 225, 315]) rotate([0, 0, r]) {
                translate([radius - wall - 1.75, 0, lip/2]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
        }
        // flange to mount on body
        rounded_octagon_wall(lip + 1.00, radius - wall, wall);
        // and make a smooth transition to avoid overhangs
        translate([0, 0, lip + 1.00]) {
            hull() {
                rounded_octagon_wall(thin_mint, radius - wall, wall);
                translate([0, 0, 1.0]) {
                    rounded_octagon_wall(thin_mint, radius - 2 * wall, wall);
                }
            }
        }
        // holes for screws that attach the flare to the body
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        for (r = [45, 135, 225, 315]) rotate([0, 0, r]) {
            translate([radius/2, 0, lip/2]) {
                rotate([0, 90, 0]) {
                    cylinder(r = (1.6 + 0.1)/2, h = radius, $fn = facets);
                }
            }
        }
    }
    // flare to rounded section
    translate([0, 0, height]) {
        difference() {
            hull() {
                rounded_octagon(thin_mint, radius);
                translate([0, 0, transition]) {
                    rounded_block(thin_mint, top_xradius, top_yradius, top_xradius - delta);
                }
            }
            hull() {
                rounded_octagon(thin_mint, radius - 2 * wall);
                translate([0, -top_xradius, transition]) {
                    cube([thin_mint, (top_xradius) * 2, thin_mint]);
                }
            }
        }
    }
}

// flare to d-sub 25 pin connector

module octa_mount_flare_dsub(height, lip, transition, radius, top_xradius, top_yradius) {
    // bottom octagonal box
    difference() {
        union() {
            rounded_octagon_wall(height, radius, 2 * wall);
            // small pedestals for the screws that attach the flare to the body
            // (number 0 size, 1/4" long = thread diameter: 1.6mm, head diameter: 2.75)
            for (r = [45, 135, 225, 315]) rotate([0, 0, r]) {
                translate([radius - wall - 1.75, 0, lip/2]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
        }
        // flange to mount on body
        rounded_octagon_wall(lip + 1.00, radius - wall, wall);
        // and make a smooth transition to avoid overhangs
        translate([0, 0, lip + 1.00]) {
            hull() {
                rounded_octagon_wall(thin_mint, radius - wall, wall);
                translate([0, 0, 1.0]) {
                    rounded_octagon_wall(thin_mint, radius - 2 * wall, wall);
                }
            }
        }
        // holes for screws that attach the flare to the body
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        for (r = [45, 135, 225, 315]) rotate([0, 0, r]) {
            translate([radius/2, 0, lip/2]) {
                rotate([0, 90, 0]) {
                    cylinder(r = (1.6 + 0.1)/2, h = radius, $fn = facets);
                }
            }
        }
    }
    // flare to db25 connector mounting plate
    expand = pcb_version == 2 ? 1 : 3;
    // height of connector
    guard_height = 9.525;
    // thickness of db25 plate
    db25_t = 3 * wall;
    translate([0, 0, height]) {
        minkr = 2.0;
        difference() {
            hull() {
                rounded_octagon(thin_mint, radius);
                rotate([0, 0, -22.5]) translate([0, 0, transition - 5.0]) {
                    minkowski() {
                        db25_plate(th = thin_mint, border = expand);
                        cylinder(r = minkr, h = thin_mint, $fn = facets);
                    }
                }
            }
            hull() {
                rounded_octagon(thin_mint, radius - 2 * wall);
                rotate([0, 0, -22.5]) translate([0, 0, transition - 5.0]) {
                    minkowski() {
                        db25_plate(th = thin_mint, border = expand - 2 * wall);
                        cylinder(r = minkr, h = thin_mint, $fn = facets);
                    }
                }
            }
        }
        // db25 mounting plate
        rotate([0, 0, -22.5]) translate([0, 0, transition]) {
            difference() {
                db25_plate(th = db25_t, border = expand);
                db25_cutout(th = db25_t);
            }
            // connector border
            translate([0, 0, -5.0]) difference() {
                overhang = 3.0;
                minkowski() {
                    db25_plate(th = 5.0 + db25_t + overhang, border = expand);
                    cylinder(r = minkr, h = thin_mint, $fn = facets);
                }
                db25_plate(th = 5.0 + db25_t + overhang + thin_mint, border = expand);
            }
        }
        // for testing
        *rotate([0, 0, -22.5]) translate([0, 0, 40]) db25_plate(th = 1.0, border = 1.0);
    }
}

module octa_mount_stand(height, lip, transition, radius, top_xradius, top_yradius) {
    // flare to db25 connector mounting plate
    expand = 3;
    // height of connector
    guard_height = 9.525;
    // thickness of db25 plate
    db25_t = 3 * wall;
    translate([0, 0, height]) {
        minkr = 2.0;
        // db25 mounting plate
        rotate([0, 0, -22.5]) translate([0, 0, transition]) {
            // add guard wall around connector
            difference() {
                minkowski() {
                    db25_plate(th = guard_height + db25_t, border = 1.8 * expand);
                    cylinder(r = minkr, h = thin_mint, $fn = facets);
                }
                db25_plate(th = guard_height + db25_t + thin_mint, border = 1.8 * expand);
            }
        }
        // ring and connector
        translate([0, 0, height]) {
            o_rad = 8;
            i_rad = 3;
            rotate([0, 90, -22.5]) {
                // connector
                translate([-guard_height, 13, 0]) cube([guard_height, 10, o_rad/2]);
                translate([-guard_height, 9, o_rad/4]) rotate([0, 90, 0]) {
                    difference() {
                        cylinder(r = o_rad, h = guard_height, $fn = facets);
                        translate([-10, -16, 0]) cube([20, 20, 10]);
                    }
                }
                // ring
                translate([-o_rad, 30, 0]) {
                    shock_mount_ring(o_rad, i_rad, ring_wall);
                }
            }
        }
    }
}

// top conical section that plugs into capsule array (version 1 microphone)

module octa_capsule_array_mount(angles) {
    difference() {
        union() {
            difference() {
                cylinder(h = mount_top_height, r1 = mount_radius + wall, r2 = mount_radius_capsule + 0.9, $fn = facets);
                cylinder(h = mount_top_height, r1 = mount_radius, r2 = mount_radius_capsule - 2 * wall * wall, $fn = facets);
            }
            // second set of optional "leaves" to get a better mount
            *difference() {
                cylinder(h = mount_top_height, r1 = mount_radius + wall, r2 = mount_radius_capsule * 0.8, $fn = facets);
                cylinder(h = mount_top_height, r1 = mount_radius, r2 = mount_radius_capsule * 0.8 - 1.2 * wall, $fn = facets);
            }
        }
        // indentations that match the four lower capsule holders
        // add ridge height adjustment
        translate([0, 0, mount_top_height + (mic_radius - capsule_height) + capsule_height * cos(90 - elev_angle) - 2]) {
            for (az = angles) {
                rotate([0, 180 - elev_angle, az + 45]) {
                    translate([0, 0, mic_radius - capsule_height]) {
                        capsule(leg_angles, 0, 1, ridge_wfit, ridge_hfit, 1);
                    }
                }
            }
        }
        // indentations at the top to open up the array a bit
        translate([0, 0, mount_top_height + mount_radius_capsule / 8]) {
            for (rot = [45, 135, -135, -45]) {
                translate([0, 0, 0]) {
                    rotate([0, 90, rot]) {
                        scale([0.5, 0.5, 1.3]) linear_extrude(height = mount_radius_capsule, scale = 2.8) {
                            minkowski() {
                                polygon(points = [[0, mount_radius_capsule * 0.2], [0, - mount_radius_capsule * 0.2],
                                                  [mount_radius_capsule, 0]]);
                                circle(r = 2.4, $fn = facets);
                            }
                        }
                    }
                }
            }
        }
    }
}

//
// shock mount components
//

// shock mount band that attaches snugly to microphone body

module octa_shock_mount_band(band_height, radius, delta_radius) {
    rotate([0, 0, 22.5]) {
        // inner octagon, hugs the body
        difference() {
            rounded_octagon_wall(band_height, radius + 3 * wall, 2 * wall);
            rotate([0, 0, -22.5 + 90]) translate([-40, -(1.273 * radius)/2, 0]) {
                cube([80, 1.273 * radius, band_height + thin_mint]);
            }
            // space for screw heads
            slot_w = 4.0;
            slot_d = 1.5;
            for (r = [0, 180]) rotate([0, 0, r - 45])
            translate([radius - slot_d/2, -slot_w/2, 0]) cube([slot_d, slot_w, band_height]);
        }
        // the outer octagon
        rounded_octagon_wall(band_height, radius + delta_radius, 2 * wall);
    }
    // joins inner and outer octagons
    for (m = [0, 1]) mirror([m, 0, 0]) {
        translate([radius, -10, 0]) {
            cube([delta_radius - 4 * wall, 20, band_height]);
        }
    }
}

// shock mount internal ring

module octa_shock_mount_internal_ring(height, radius, band_height, corner) {
    delta_radius = pcb_version == 2 ? 7.5 : 6;
    // octagonal band
    octa_shock_mount_band(band_height, radius, delta_radius);
    // 8 columns for mounting rubber bands
    for (r = [0, 90, 180, 270]) rotate([0, 0, r]) {
        for (m = [0, 1]) mirror([m, 0, 0]) {
            translate([radius + (pcb_version == 2 ? 3.5 : 2.25), radius/2 - 2, 0]) {
                rotate([0, 0, 0]) {
                    difference() {
                        // columns
                        union() {
                            translate([3, 0, 0]) rotate([0, 0, 45]) scale([1.4, 0.8, 1.0]) 
                                cylinder(r = 3, h = height, $fn = facets);
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
        // walls between columns so that they cannot bend
        rotate([0, 0, 45]) translate([radius + (pcb_version == 2 ? 2.7 : 2.25) * wall, -14, 0]) {
            cube([wall, 28, height]);
        }
    }
}

// shock mount sleeve, slips over microphone body and has hooks for the elastic bands

module elastic_band_hook (slot_r = 1.1) {
    hook_l = 6.0;
    translate([slot_r, hook_l/2, 0]) {
        rotate([90, 0, 0]) scale([1, 2.2, 1]) cylinder(r = slot_r, h = hook_l, $fn = facets);
    }
}

module octa_shock_mount_sleeve(radius, height, hooks = true, logo = true) {
    // gap between body and sleeve
    gap = internal_ring_gap + 0;
    difference() {
        // fit gap for slide tubes
        sgap = 0.2;
        stop_ro = 2.0 + 2 * wall + sgap;
        union() {
            // sleeve
            rotate([0, 0, 22.5]) rounded_octagon_wall(height, radius + 2 * wall + gap, 2 * wall);
            // tubes for stops
            for (r = [0, 90, 180, 270]) {
                rotate([0, 0, r + 45]) {
                    translate([radius - 2 * wall + gap, 0, 0]) {
                        difference() {
                            scale([1, 1.4, 1]) cylinder(r = stop_ro, h = height, $fn = facets);
                            translate([-2 * stop_ro, -2 * stop_ro, 0]) {
                                cube([2 * stop_ro, 4 * stop_ro, height]);
                            }
                        }
                    }
                }
            }
            // pillars for elastic band hooks
            if (hooks) {
                for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
                    pill_r = 2.5;
                    translate([radius + stop_ro + gap - 2 * wall, 0, 0]) {
                        difference() {
                            scale([2, 1, 1]) cylinder(r = pill_r, h = height, $fn = facets);
                            translate([-7 * wall, -pill_r, 0]) cube([6 * wall, pill_r * 2, height]);
                        }
                    }
                }
            }
            // add ccrma logo
            if (logo) {
                rotate([0, 0, 90]) {
                    translate([0, -(radius - (pcb_version == 2 ? gap + 1.4 : gap + 1.5) + 2 * wall),
                    height / 2]) {
                        rotate([90, 270, 0]) {
                            logo_scale = 1 / (pcb_version == 2 ? 3.0 : 2.4);
                            scale([logo_scale, logo_scale, 1.0]) {
                                ccrma_logo(1.65);
                            }
                        }
                    }
                }
            }
        }
        // slots for stops and screws
        for (r = [0, 90, 180, 270]) {
            // stops
            stop_r = 2.0 + sgap;
            rotate([0, 0, r + 45]) {
                translate([radius - 2 * wall + gap, 0, 0]) {
                    // there is a little bit of play between the wd assembly and the top
                    ws_play = 0.4;
                    cylinder(r = stop_r, h = height - 10.0 - ws_play, $fn = facets);
                }
            }
            // screws
            screw_h = 1.3;
            rotate([0, 0, r + 22.5]) {
                translate([radius - 1.5 * wall + gap, -3.5/2, 0]) {
                    cube([screw_h + sgap, 3.5, height - 8]);
                }
            }
        }
        // slot for front mark
        translate([radius - 2 * wall, 0, 0]) cylinder(r = 1.5, h = height, $fn = facets);
        // shave channel for logo
        translate([radius - 2 * wall, -10/2, 0]) cube([wall/3, 10, height]);
        // upper elastic band hooks
        for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
            translate([radius + stop_ro + gap - 2*wall, 0, height - 1.6]) {
                elastic_band_hook();
            }
        }
        // lower elastic band hooks
        for (r = [0, 90, 180, 270]) rotate([0, 0, r + 45]) {
            translate([radius + stop_ro + gap - 2*wall, 0, 1.6]) {
                rotate([180, 0, 0]) elastic_band_hook();
            }
        }
    }
}

// shock mount external ring

module octa_shock_mount_external_ring_old(height, radius, corner) {
    // main ring
    rotate([0, 0, 22.5]) rounded_octagon_wall(ring_ext_height, radius, ring_wall);
    for (rot = [0, 90, 180, 270]) {
        // anchors for rubber bands
        rotate([0, 0, rot + 45]) {
            translate([radius * cos(22.5) + ring_wall + 0.75, -6, 0]) {
                minkowski() {
                    cube([4 - 2, 12, ring_ext_height]);
                    cylinder(r = 1.5, h = thin_mint, $fn = facets);
                }
            }
            translate([radius * cos(22.5), -2, 0]) {
                cube([7, 4, ring_ext_height]);
            }
        }
    }
    // connection to hub
    translate([radius * cos(22.5), -2, 0]) {
        cube([10, 4, ring_ext_height * 2]);
    }
    // reinforce connection to ring
    intersection() {
        translate([radius * cos(22.5), 0, 0]) {
            difference() {
                cylinder(r = 6, h = ring_ext_height * 2, $fn = 4);
                translate([-10, -5, 0]) {
                    cube([10, 10, ring_ext_height * 2]);
                }
            }
        }
        translate([radius + ring_wall - 7, 0, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = radius * 1.5, r2 = ring_wall/2 + 1, h = ring_ext_height * 2, $fn = 4);
        }
    }
    // reinforcement
    intersection() {
        rotate([0, 0, 22.5]) rounded_octagon_wall(ring_ext_height * 2, radius, ring_wall);
        translate([radius - 6.5, 0, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = radius * 1.5, r2 = ring_wall/2 + 1, h = ring_ext_height * 2, $fn = 4);
        }
    }
    // rotating mount
    o_rad = 8;
    i_rad = 3;
    rotate([0, 90, -90]) {
        translate([-o_rad, radius * cos(22.5) + o_rad + ring_wall * 2, -2]) {
            shock_mount_ring(o_rad, i_rad, ring_wall);
        }
    }
}

module octa_shock_mount_external_ring(height, radius, corner) {
    // main ring
    rotate([0, 0, 22.5]) rounded_octagon_wall(ring_ext_height, radius, ring_wall);
    for (m = [0, 1]) mirror([0, m, 0]) {
        for (rot = [0, 90, 180, 270]) {
            // anchors for rubber bands
            rotate([0, 0, rot + 20]) {
                translate([radius * cos(22.5) + ring_wall + 2.0, -5, 0]) {
                    minkowski() {
                        cube([4 - 3, 6, ring_ext_height]);
                        cylinder(r = 1.0, h = thin_mint, $fn = facets);
                    }
                }
                translate([radius * cos(22.5), -2, 0]) {
                    cube([7, 4, ring_ext_height]);
                }
            }
        }
    }
    // connection to hub
    translate([radius * cos(22.5), -2, 0]) {
        cube([10, 4, ring_ext_height * 2]);
    }
    // reinforce connection to ring
    intersection() {
        translate([radius * cos(22.5), 0, 0]) {
            difference() {
                cylinder(r = 6, h = ring_ext_height * 2, $fn = 4);
                translate([-10, -5, 0]) {
                    cube([10, 10, ring_ext_height * 2]);
                }
            }
        }
        translate([radius + ring_wall - 7, 0, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = radius * 1.5, r2 = ring_wall/2 + 1, h = ring_ext_height * 2, $fn = 4);
        }
    }
    // reinforcement
    intersection() {
        rotate([0, 0, 22.5]) rounded_octagon_wall(ring_ext_height * 2, radius, ring_wall);
        translate([radius - 6.5, 0, 0]) {
            rotate([0, 0, 45]) cylinder(r1 = radius * 1.5, r2 = ring_wall/2 + 1, h = ring_ext_height * 2, $fn = 4);
        }
    }
    // rotating mount
    o_rad = 8;
    i_rad = 3;
    rotate([0, 90, -90]) {
        translate([-o_rad, radius * cos(22.5) + o_rad + ring_wall * 2, -2]) {
            shock_mount_ring(o_rad, i_rad, ring_wall);
        }
    }
}


// stand mount with quick clip connector

module octa_quik_release_stand_mount(band_height, radius) {
    vertical_offset = 18;
    mount_offset = 3.0;
    // octagonal band
    octa_shock_mount_band(band_height, radius, pcb_version == 2 ? 7.5 : 6);
    difference() {
        hull() {
            // attachment "plate"
            translate([radius, -10, 0]) {
                cube([2, 20, band_height]);
            }
            // quik release adapter tube
            translate([(radius + mic_mount_radius + mic_mount_wall + 6.0 + mount_offset) * cos(22.5), 0,
                    vertical_offset]) {
                cylinder(r = mic_mount_radius + mic_mount_fit + mic_mount_wall, h = band_height - vertical_offset, $fn = facets);
            }
        }
        // cutout for the center hole and side hole of the adapter
        translate([(radius + mic_mount_radius + mic_mount_wall + 6.0 + mount_offset) * cos(22.5), 0,
                vertical_offset + thin_mint]) {
            cylinder(r = mic_mount_radius + mic_mount_fit, h = mic_mount_height, $fn = facets);
        }
    }
    translate([(radius + mic_mount_radius + mic_mount_wall + 6.0 + mount_offset) * cos(22.5), 0,
            mic_mount_height + vertical_offset + thin_mint]) {
        rotate([0, 180, 180]) quik_release_stand_adapter(mic_mount_height, mount_wall, mic_mount_wall);
    }
}

// octathingy arm mount for robotic arm

module octa_arm_mount(band_height, radius, height) {
    vertical_offset = 18;
    mount_offset = 3.0;
    // octagonal band
    octa_shock_mount_band(band_height, radius, pcb_version == 2 ? 7.5 : 6);
    // pillars for arm grips
    sphear_arm_mount_pillars(radius, height - 50.0, grip_sep, grip_width);
}

module octa_arm_mount_pillars(band_height, radius, height, grip_width, grip_depth) {
    vertical_offset = 18;
    mount_offset = 3.0;
    // pillars for arm grips
    sphear_arm_mount_pillars(radius, height - 60.0, grip_sep, grip_width, grip_depth);
}

////
//// render all the different parts
////

// microphone body: stalk from capsule flare to capsule array (for microphone version 1)
//
module render_octa_capsule_stalk(z_offset) {
    translate([0, 0, z_offset]) {
        octa_mount_stalk(pcb_hi_clear + pcb_hi_exp, mount_lip, flare_height, octa_pcb_radius, mount_radius + wall, stalk_height, 1);
        translate([0, 0, pcb_hi_clear + pcb_hi_exp + flare_height + stalk_height]) {
            octa_capsule_array_mount([45, 135, -45, -135]);
        }
    }
}

// microphone body: flare to capsule array (slips into PCB holder body)
//
module render_octa_capsule_flare(z_offset) {
    translate([0, 0, z_offset]) {
        octa_mount_flare(pcb_hi_clear + pcb_hi_exp, mount_lip, flare_height, octa_pcb_radius, mount_radius + wall, stalk_height, 1);
    }
}

// microphone body: main body, holds printed circuit boards
//

module render_octa_pcb_mount(z_offset, showint) {
    translate([0, 0, z_offset]) {
        octa_mount_body(octa_pcb_mount_height, octa_pcb_radius, mount_lip, mount_lip, 0);
        // add ccrma logo
        rotate([0, 0, -90 + 22.5]) {
            translate([0, -(octa_pcb_radius - (pcb_version == 2 ? 3.4 : 3.7)), octa_pcb_mount_height / 2]) {
                rotate([90, 270, 0]) {
                    logo_scale = 1 / (pcb_version == 2 ? 3.0 : 2.4);
                    scale([logo_scale, logo_scale, 1.0]) {
                        ccrma_logo(1.65);
                    }
                }
            }
        }
    }
}

// microphone body: flare to microphone cable (slips into PCB holder body)
//
module render_octa_cable_flare(z_offset, flip) {
    translate([0, 0, z_offset]) {
        octa_mount_flare_dual(pcb_low_clear + pcb_low_exp, mount_lip, 20, box_radius + wall, box_radius * 2 - wall, 
                              mount_corner, cable_diam / 2 + wall, 10, 0);
    }
}

// microphone body: flare to dual cable connectors (slips into PCB holder body)
//
module render_octa_connector_flare(z_offset, flip) {
    conn_offset = 2.0;
    conn_wall = conn_core_o_diam / 2 - conn_core_diam / 2;
    translate([0, 0, z_offset]) {
        difference() {
            union() {
                octa_mount_flare_connector(pcb_low_clear + pcb_low_exp, mount_lip, 20,
                            octa_pcb_radius,
                            conn_core_o_diam / 2, conn_core_o_diam + conn_offset);
                for (m = [0, 1]) mirror([0, m, 0]) translate([0, conn_core_o_diam / 2 + conn_offset, pcb_low_clear + pcb_low_exp + 20]) {
                    // add two connectors
                    rotate([0, 0, -90]) {
                        tetra_mount_connector_holder(conn_core_sleeve, conn_core_o_diam / 2, conn_core_diam / 2,
                            conn_core_overlap, conn_core_s_diam / 2);
                    }
                    // add wall in between the two connectors
                    translate([- 2 * wall, - (conn_core_o_diam / 2 + conn_offset), 0]) {
                        cube([4 * wall, conn_offset + wall, 10]);
                    }
                }
            }
            // redo the hole in the connector holder so that it drills into the top of the flare
            for (m = [0, 1]) mirror([0, m, 0]) translate([0, conn_core_o_diam / 2 + conn_offset, 0]) {
                cylinder(r = conn_core_diam / 2, h = 100, $fn = facets);
            }
        }
    }
}

// microphone body: flare to db25 connector (slips into PCB holder body)
//
module render_octa_mount_dsub_flare(z_offset, flip) {
    updown = 0;
    if (flip) {
        updown = 180;
    }
    rotate([0, updown, 90]) {
        conn_offset = 2.0;
        translate([0, 0, z_offset - mount_lip]) {
            octa_mount_flare_dsub(pcb_low_clear + pcb_low_exp - (pcb_version == 2 ? 13 : 0), mount_lip,
                                pcb_version == 2 ? 33 : 20, octa_pcb_radius,
                                conn_core_o_diam / 2, conn_core_o_diam + conn_offset);
        }
    }
}

// microphone body: render all parts with a vertical separation
//
module render_octa_body(z_offset, spread, showint) {
    rotate([0, 180, 0]) {
        render_octa_mount_dsub_flare(pcb_version == 2 ? 10 : 0, 0);
    }
    lippy = spread - mount_lip;
    render_octa_pcb_mount(lippy, showint);
    render_octa_capsule_flare(octa_pcb_mount_height + 2 * lippy);
}

// microphone: render the full assembly with vertical separation between components
//
module render_octa_microphone(z_offset, spread) {
    render_octa_body(z_offset, spread);
    lippy = spread - mount_lip;
    render_octa_capsule_array(z_offset + octa_pcb_mount_height + mount_top_height +
            flare_height + stalk_height + pcb_hi_clear + pcb_hi_exp + 2 * lippy + spread + mic_radius);
    render_octa_capsule_stalk(z_offset + (pcb_version == 2 ? 43.2 : 49.2) - 10.0);
}

// microphone: render the full assembly with vertical separation between components
//             cut out half of the assembly so that we can see the inside
//

module render_octa_microphone_cutout(z_offset, spread) {
    difference() {
        render_octa_microphone(z_offset, spread);
        // a cube that blots out 1/4 of the microphone
        rotate([0, 0, 90]) {
            translate([0, 0, -50]) {
                cube([50, 100, 650]);
            }
        }
    }
}

// shock mount: microphone clip on stand mount
//

module render_octa_shock_mount_stand(z_offset) {
    translate([z_offset]) {
        shock_mount_stand(mic_mount_height, mount_wall, mic_mount_wall);
    }
}

// shock mount: external ring
//

module render_octa_shock_mount_external_ring_old(z_offset) {
    translate([0, 0, z_offset]) {
        shock_mount_external_ring(external_ring_height, box_radius + wall, box_radius * 2 - wall, mount_corner, main_radius_inc, 0);
    }
}

module render_octa_shock_mount_external_ring(z_offset) {
    translate([0, 0, z_offset]) {
        octa_shock_mount_external_ring(external_ring_height, octa_pcb_radius + internal_ring_gap + main_radius_inc + 5.25, 20);
    }
}

// shock mount: bottom internal ring
//

module render_octa_shock_mount_internal_ring_bot(z_offset) {
    translate([0, 0, z_offset]) {
        shock_mount_internal_ring(external_ring_height, box_radius + wall, box_radius * 2 - wall, mount_corner, internal_ring_gap, 1);
    }
}

module render_octa_shock_mount_internal_ring_bot(z_offset) {
    translate([0, 0, z_offset]) {
        shock_mount_internal_ring(external_ring_height, A/2 + wall, A/2 + 3, octa_pcb_radius * 2/3, internal_ring_gap, 1);
    }
}

// shock mount: top internal ring
//

module render_octa_shock_mount_internal_ring_top_old(z_offset) {
    translate([0, 0, z_offset]) {
        shock_mount_internal_ring(external_ring_height, box_radius + wall, box_radius * 2 - wall, mount_corner, internal_ring_gap, 0);
    }
}

module render_octa_shock_mount_internal_ring_top(z_offset) {
    translate([0, 0, z_offset]) {
        shock_mount_internal_ring(external_ring_height, A/2 + wall, A/2 + 3, octa_pcb_radius * 2/3, internal_ring_gap, 0);
    }
}

// shock mount: all four internal ring connectors
//

module render_octa_shock_mount_ring_connectors(offset) {
    for (o = [0, 1, 2, 3]) {
        translate([-18, (10 + offset) * o, 0]) {
            shock_mount_connector(internal_ring_height, 4, connector_w, connector_d, 0.1);
        }
    }
}

// shock mount: render all parts
//

module render_octa_shock_mount(z_offset) {
    // internal rings
    translate([0, 0, z_offset + internal_ring_height / 2]) {
        render_octa_shock_mount_internal_ring_top(0);
        rotate([0, 180, 0]) {
            render_octa_shock_mount_internal_ring_bot(internal_ring_height + 2);
        }
        // insert the connecting rods
        for (r = [0, 90, 180, 270]) {
            rotate([0, 0, r]) {
                translate([((r % 180) ? box_radius * 2 : box_radius) + 3 * wall + internal_ring_gap, 0, -1]) {
                    rotate([0, 90, 0]) {
                        translate([-4, -5, 1]) {
                            shock_mount_connector(internal_ring_height, 4, connector_w, connector_d, 0.1);
                        }
                    }
                }
            }
        }
    }
    // external ring
    translate([0, 0, z_offset - external_ring_height / 4]) {
        render_octa_shock_mount_external_ring(0);
    }
    // mount to stand
    translate([box_radius + mount_corner + ring_wall + ring_arm_gap + 8 + ring_wall / 2 + 4, 0, -(mic_mount_height + mic_mount_radius + external_ring_height / 4)]) {
        render_octa_shock_mount_stand(0);
    }
}

