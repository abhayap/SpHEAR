//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// TinySpHEAR, First Order (B-format) Ambisonics Microphone
// Mount for four Zapnspark phantom power printed circuit boards
// 
// Copyright 2015-2018, Fernando Lopez-Lezcano, All Rights Reserved
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

////
//// default model parameters
////

// diameter of microphone capsule cable (Mogami 2490)
capsule_cable_diam = 1.7;

// capsule array mount, height of flare and stalk
flare_height = pcb_version == 2 ? 45 : 50;
stalk_height = pcb_version == 2 ? 35 : 40;

// adjust mic array to mount relative height
mic_to_mount_fit = 0.0;

//// screw holes to join the body to the two flares
//
// rotation of holes to avoid pcb slots
screw_rotation = -3.0;

// shock mount parameters
//

// angle in degrees of rubber bands
rubber_band_angle = 40;
// height of external ring
external_ring_height = 6.0;
external_ring_radius = (40.0 / 2) / tan(rubber_band_angle);
// height of internal ring posts
internal_ring_height = 50.0;
//height of internal ring band that slips over microphone body
internal_band_height = 20.0;
// gap between internal ring and microphone body
internal_ring_gap = 2.75;

// connector that joins the two internal rings
connector_w = 10.0;
connector_d = 2.0;

// wall thickness and height of shock mount rings
ring_wall = 4 * wall;
ring_ext_height = 6;

// gap between external ring and support arm
ring_arm_gap = 20;


// all four printed circuit boards

module tetra_pcb_clear(length, width, thick, slot_depth, front, back, side, twist) {
    for (rot = [0, 90, 180, 270]) {
        rotate([0, 0, rot + twist]) translate([-side, 0, 0]) {
            pcb_clear(pcb_length + pcb_fit, pcb_width + pcb_fit, pcb_thickness + pcb_tfit, slot_depth, front, back);
        }
    }
}

// the main body of the microphone mount

module tetra_mount_body(height, radius, corner, lower_lip, upper_lip, screw_rotation, clear) {
    // lateral offset of pcb's
    side = 1.4;
    // twist of pcbs inside body
    twist = 0;
    // twist of each pcb
    pcb_twist = 0;
    difference() {
        rounded_block(height, radius, radius, corner);
        union() {
            // hollow out the inside with slots for pcbs
            tetra_pcb_clear(pcb_length, pcb_width, pcb_thickness, pcb_slot_depth, pcb_front, pcb_back, side, twist);
            // trim square angles
            cylinder(r = pcb_front, h = height, $fn = facets);
            // remove slots from inside body
            slot_len = 30;
            translate([0, 0, slot_len]) {
                difference() {
                    rounded_block_relative(height, radius, radius, corner, - (2 * wall));
                    // add columns for upper screw holes
                    col_w = 3.5;
                    for (r = [45, 135, 225, 315]) rotate([0, 0, r])
                    translate([radius - col_w*2/3, -col_w/2, 0]) {
                        cube([col_w, col_w, height]);
                    }
                }
            }
            // upper lip for flare to microphone
            translate([0, 0, height - upper_lip]) {
                difference() {
                    rounded_block(upper_lip, radius, radius, corner);
                    rounded_block_relative(upper_lip, radius, radius, corner, -(wall + lip_fit));
                }
            }
            // lower lip for flare to cable
            translate([0, 0, 0]) {
                difference() {
                    rounded_block(lower_lip, radius, radius, corner);
                    rounded_block_relative(lower_lip, radius, radius, corner, -(wall + lip_fit));
                }
            }
            // make eight holes in the the body for screws that hold both flares
            // (number 0 size, 1/4" long = thread diameter: 1.6mm, head diameter: 2.75)
            for (z = [lower_lip/2, height - upper_lip/2]) {
                for (r = [45, 135, 225, 315]) {
                    rotate([0, 0, r + screw_rotation])
                    translate([-(radius + 2 * wall), 0, z]) {
                        rotate([0, 90, 0]) {
                            cylinder(r = 0.7, h = radius + wall, $fn = facets);
                        }
                    }
                }
            }
        }
    }
    // add parts for clearance check
    if (clear == 1) {
        for (rot = [0, 180, 270]) {
        //for (rot = [0]) {
            rotate([0, 0, rot + twist]) {
                translate([-(pcb_front + pcb_thickness), -pcb_width/2 + side, -pcb_low_exp]) {
                    // twist the assembly in place
                    rotate([0, 0, pcb_twist]) {
                        // PCBs
                        cube([pcb_thickness, pcb_width, pcb_length]);
                        // small electrolytic capacitors (pcb_version == 2)
                        // https://www.mouser.com/datasheet/2/293/e-umw-1219455.pdf
                        cap_diam = 8.0;
                        // should be 5, but transistors are a bit taller;
                        cap_len = 6.5;
                        translate([pcb_thickness + 0.15, pcb_width/2, 6]) {
                            rotate([0, 90, 0]) cylinder(r = (cap_diam/2), h = cap_len, $fn = facets);
                        }
                        // film capacitors
                        cap_h = 12;
                        cap_w = 9;
                        cap_t = 5.5;
                        translate([pcb_thickness + 0.15, pcb_width/2 - cap_w/2, 10]) {
                            cube([cap_t, cap_w, cap_h]);
                        }
                    }
                }
            }
        }
        // big electrolytic capacitors (pcb_version == 1)
        cap_diam = 10.2;
        *for (rot = [0, 180, 270]) {
            rotate([0, 0, rot + twist]) {
                translate([-pcb_front + cap_diam/2, side, 0]) {
                    cylinder(r = (cap_diam/2), h = 20, $fn = facets);
                }
            }
        }
    }
}

// flares from the body to the microphone stalk and cable

module tetra_mount_flare(height, lip, transition, bot_radius, bot_corner, top_radius, screw_rotation, windscreen, shock_mount) {
    // bottom rounded box
    difference() {
        union() {
            rounded_block(height, bot_radius, bot_radius, bot_corner);
            if (windscreen) {
                // add thread for attaching windscreen
                translate([0, 0, lip]) {
                    metric_thread(diameter = windscreen_thread_radius * 2, pitch = windscreen_thread_pitch,
                        length = windscreen_thread_height, angle = windscreen_thread_angle, internal = false);
                }
                cylinder(r2 = box_corner_radius + 1.5, r1 = box_radius + 0.5, h = lip , $fn = facets);
                // index for back of microphone
                translate([-bot_radius, 0, 0]) {
                    cylinder(r = 1.0, h = height, $fn = facets);
                }
                // stops for shock mount
                for (r = [0, 90, 180, 270]) rotate([0, 0, r]) {
                    translate([bot_radius, 0, 0]) scale([2.0, 1.0, 1.0]) cylinder(r = 2.0, h = lip, $fn = facets);
                }
            }
            // small supports for the screws that attach the flare to the body
            // (number 0 size, 1/4" long = thread diameter: 1.6mm, head diameter: 2.75)
            for (r = [45, 135, 225, 315]) rotate([0, 0, r + screw_rotation]) {
                translate([bot_radius + wall/3, 0, lip/2]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = 1.5, h = 2 * wall, $fn = facets);
                    }
                }
            }
        }
        rounded_block_relative(height, bot_radius, bot_radius, bot_corner, -(2 * wall));
        // cut flange to mount on body
        rounded_block_relative(lip + 1.00, bot_radius, bot_radius, bot_corner, - (wall));
        // holes for screws that attach the flare to the body
        // Number 0 Size, 1/4" Long = thread diameter: 1.6mm, head diameter: 2.75
        for (r = [45, 135, 225, 315]) rotate([0, 0, r + screw_rotation]) {
            translate([bot_radius + wall, 0, lip/2]) {
                rotate([0, 90, 0]) {
                    cylinder(r = (1.6 + 0.1)/2, h = bot_radius, $fn = facets);
                }
            }
        }
        // and make a smooth transition to avoid overhangs
        translate([0, 0, lip + 1.00]) {
            hull() {
                rounded_block_relative(thin_mint, bot_radius, bot_radius, bot_corner, - wall);
                translate([0, 0, 1.0]) {
                    rounded_block_relative(thin_mint, bot_radius, bot_radius, bot_corner, - 2 * wall);
                }
            }
        }
    }
    // flare to round section
    translate([0, 0, height]) {
        difference() {
            hull() {
                rounded_block(thin_mint, bot_radius, bot_radius, bot_corner);
                translate([0, 0, transition]) {
                    cylinder(r = top_radius, h = thin_mint, $fn = facets);
                }
            }
            // screw mounted shock mount (test)
            *union() {
                if (shock_mount) {
                    ratio = (transition - windscreen_thread_height) / transition;
                    thread_radius = bot_radius - ((bot_radius - top_radius) * ratio) + 2.0 * wall;
                    hull() {
                        rounded_block(thin_mint, bot_radius, bot_radius, bot_corner);
                        translate([0, 0, transition - windscreen_thread_height]) {
                            cylinder(r = thread_radius, h = thin_mint, $fn = facets);
                        }
                    }
                    translate([0, 0, transition - windscreen_thread_height]) {
                        metric_thread(diameter = thread_radius * 2, pitch = windscreen_thread_pitch,
                            length = windscreen_thread_height, angle = windscreen_thread_angle, internal = false);
                    }
                } else {
                    hull() {
                        rounded_block(thin_mint, bot_radius, bot_radius, bot_corner);
                        translate([0, 0, transition]) {
                            cylinder(r = top_radius, h = thin_mint, $fn = facets);
                        }
                    }
                }
            }
            hull() {
                rounded_block_relative(thin_mint, bot_radius, bot_radius, bot_corner, - wall);
                translate([0, 0, transition]) {
                    cylinder(r = top_radius - wall, h = thin_mint, $fn = facets);
                }
            }
        }
    }
}

// stalk that connects upper flare to capsule array mount

module tetra_mount_array_stalk(height, radius) {
    difference() {
        cylinder(r = radius, h = height, $fn = facets);
        cylinder(r = radius - wall, h = height, $fn = facets);
    }
    // add marker for "back of microphone" orientation
    *rotate([0, 0, 90]) {
        translate([0, radius - wall * 2 / 3, height - radius]) {
            difference() {
                sphere(r = radius / 3, $fn = 32);
                translate([0, -radius + radius / 2, 0]) {
                    cube([radius, radius, radius], center = true);
                }
            }
        }
    }
}

// bottom cable holder

module tetra_mount_cable_holder(height, radius) {
    difference() {
        cylinder(r = radius, h = height, $fn = facets);
        cylinder(r = radius - wall, h = height, $fn = facets);
    }
}

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
        cylinder(r1 = radius - wall, r2 = inside_radius, h = 2.0, $fn = facets);
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

// top conical section that plugs into capsule array

module tilted_cylinder(radius, height, offset) {
    hull() {
        cylinder(r = radius, h = thin_mint, $fn = facets);
        translate([offset, 0, height]) {
            cylinder(r = radius, h = thin_mint, $fn = facets);
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

module tetra_capsule_array_mount_old(angles, mount_radius, mount_wall) {
    difference() {
        union() {
            rotate([0, 0, 45]) {
                wire_offset = wall;
                wire_diam = mic_wire_diam + mic_wire_fit;
                // FIXME: this 1.75 is the former leg_thick value, it should be calculated
                // based on the capsule diameter so that the cable fits in between the capsules
                // sleeve_width = 1.75 + wire_offset + wire_diam * 2 + wall / 2;
                sleeve_width = 3.75 + wire_offset + wire_diam * 2 + wall / 2;
                sleeve_width_max = capsule_radius + wall;
                sleeve_w = (sleeve_width > sleeve_width_max) ? sleeve_width : sleeve_width_max;
                difference() {
                    hull() {
                        cylinder(r = mount_radius + mount_wall, h = thin_mint, $fn = facets);
                        translate([0, 0, mount_top_height]) {
                            rounded_block(thin_mint, sleeve_w, mount_radius_capsule - wall/2, mount_radius*4/5);
                        }
                    }
                    // cavity for printing without support
                    scale([1.0, 1.0, 3.0]) {
                        sphere(r = mount_radius, $fn = facets);
                    }
                    // holes for cables
                    // offset for outer hole
                    hole_offset_l = mount_radius - wire_diam / 2;
                    hole_offset_h = (sleeve_w - wall - wire_diam / 2) - hole_offset_l;
                    for (m = [0, 1]) mirror([m, 0, 0]) {
                        translate([hole_offset_l - wire_diam, 0, 0]) {
                            tilted_cylinder(wire_diam / 2, mount_top_height, hole_offset_h);
                        }
                        translate([hole_offset_l, 0, 0]) {
                            tilted_cylinder(wire_diam / 2, mount_top_height, hole_offset_h);
                        }
                        // shave the inside of the double tube
                        translate([hole_offset_l - wire_diam, - wire_diam / 4, 0]) {
                            tilted_cube(wire_diam, wire_diam/2, mount_top_height, hole_offset_h);
                        }
                    }
                }
            }
        }
        // indentations that match the two lower capsule holders
        // add ridge height adjustment
        translate([0, 0, mount_top_height + (mic_radius - capsule_height) + capsule_height * cos(elev_angle) - mic_to_mount_fit]) {
            rotate([0, (90 + elev_angle), angles[0]]) {
                translate([0, 0, mic_radius - capsule_height]) {
                    capsule(leg_angles_top, 0, 0, 0.0, 0.0, 1);
                }
            }
            rotate([0, (90 + elev_angle), angles[1]]) {
                translate([0, 0, mic_radius - capsule_height]) {
                    capsule(leg_angles_top, 0, 0, 0.0, 0.0, 1);
                }
            }
        }
        // slice top sides of mount
        for (rot = [45, 45 + 180]) {
            translate([0, 0, 0]) {
                rotate([0, 30, rot]) {
                    translate([-mount_radius_capsule, -(mount_radius_capsule), mount_top_height])
                        cube([mount_radius_capsule*2, mount_radius_capsule*2, 10]);
                }
            }
        }
    }
}

module tetra_capsule_array_mount(angles, mount_radius, mount_wall) {
    pedestal = 3.0;
    difference() {
        union() {
            rotate([0, 0, 45]) {
                wire_offset = wall;
                wire_diam = mic_wire_diam + mic_wire_fit;
                difference() {
                    // outer sleeve
                    hull() {
                        for (r = [0, 180]) rotate([0, 0, r]) {
                            for (t = [1, -1]) translate([mount_radius + 2 * wall, (wire_diam/2 + wall/4) * t, mount_top_height - pedestal]) {
                                cylinder(r = wire_diam/2 + wall, h = pedestal, $fn = facets);
                            }
                        }
                        cylinder(r = mount_radius + mount_wall, h = thin_mint, $fn = facets);
                    }
                    // holes for cables in top part of sleeve
                    for (r = [0, 180]) rotate([0, 0, r]) {
                        for (t = [1, -1]) translate([mount_radius + 2 * wall, (wire_diam/2 + wall/4) * t, mount_top_height - pedestal]) {
                            cylinder(r = wire_diam/2, h = pedestal, $fn = facets);
                        }
                    }
                    // holes for cables in bottom part of sleeve
                    for (r = [0, 180]) rotate([0, 0, r]) {
                        for (t = [1, -1]) {
                            hull() {
                                translate([mount_radius - wire_diam/2 - wall, wire_diam/2 * t, 0]) {
                                    cylinder(r = wire_diam/2, h = thin_mint, $fn = facets);
                                }
                                translate([mount_radius + 2 * wall, (wire_diam/2 + wall/4) * t, mount_top_height - pedestal]) {
                                    cylinder(r = wire_diam/2, h = thin_mint, $fn = facets);
                                }
                            }
                        }
                    }
                    // cavity for printing without support
                    scale([1.0, 1.0, 3.0]) {
                        sphere(r = mount_radius, $fn = facets);
                    }
                }
            }
        }
        // indentations that match the two lower capsule holders
        // add ridge height adjustment
        translate([0, 0, mount_top_height + (mic_radius - capsule_height) + capsule_height * cos(elev_angle) - mic_to_mount_fit]) {
            rotate([0, (90 + elev_angle), angles[0]]) {
                translate([0, 0, mic_radius - capsule_height]) {
                    capsule(leg_angles_top, 0, 0, 0.0, 0.0, 1);
                }
            }
            rotate([0, (90 + elev_angle), angles[1]]) {
                translate([0, 0, mic_radius - capsule_height]) {
                    capsule(leg_angles_top, 0, 0, 0.0, 0.0, 1);
                }
            }
        }
        // slice top sides of mount
        for (r = [45, 45 + 180]) rotate([0, 0, r]) {
            translate([mount_radius_capsule, -mount_radius_capsule*1.5, mount_top_height]) {
                rotate([0, 30, 0]) {
                    cube([mount_radius_capsule*3, mount_radius_capsule*3, 10]);
                }
            }
        }
    }
}


////
//// render all the different parts
////

// microphone body: flare to capsule array (slips into PCB holder body)
//

module render_tetra_capsule_flare(z_offset) {
    translate([0, 0, z_offset]) {
        tetra_mount_flare(pcb_hi_clear + pcb_hi_exp, 
                    mount_lip, flare_height, box_radius + wall,  mount_corner, mount_radius + wall, screw_rotation, true);
        translate([0, 0, pcb_hi_clear + pcb_hi_exp + flare_height]) {
            tetra_mount_array_stalk(stalk_height, mount_radius + wall);
        }
        translate([0, 0, pcb_hi_clear + pcb_hi_exp + flare_height + stalk_height]) {
            tetra_capsule_array_mount([-45, 135], mount_radius, wall);
        }
    }
}

// microphone body: main body, holds printed circuit boards
//
tetra_pcb_mount_height = pcb_length - pcb_low_exp - pcb_hi_exp;

module render_tetra_pcb_mount(z_offset, showint) {
    translate([0, 0, z_offset]) {
        tetra_mount_body(tetra_pcb_mount_height, box_radius + wall, mount_corner, mount_lip, mount_lip, screw_rotation, showint);
        // add ccrma logo
        rotate([0, 0, -90]) {
            translate([0, -(box_radius - 0.5), tetra_pcb_mount_height / 2]) {
                rotate([90, 270, 0]) {
                    logo_scale = 1 / (pcb_version == 2 ? 3 : 2.4);
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

module render_tetra_cable_flare(z_offset, flip) {
    translate([0, 0, z_offset]) {
        tetra_mount_flare(pcb_low_clear + pcb_low_exp, mount_lip, 20, box_radius + wall, mount_corner, cable_diam / 2 + wall, - screw_rotation, false);
        translate([0, 0, pcb_low_clear + pcb_low_exp + 20]) {
            tetra_mount_cable_holder(10, cable_diam / 2 + wall);
        }
    }
}

// microphone body: flare to 12 pin connector (slips into PCB holder body)
//

module render_tetra_connector_flare(z_offset, flip) {
    translate([0, 0, z_offset]) {
        // make the upper sleeve shorter
        flare_adjust = 6.0;
        flare_height = 20;
        tetra_mount_flare(pcb_low_clear + pcb_low_exp - flare_adjust, mount_lip, flare_height, box_radius + wall, mount_corner, conn_core_o_diam / 2, - screw_rotation, false, true);
        rotate([0, 0, -90]) translate([0, 0, pcb_low_clear + pcb_low_exp + 20 - flare_adjust]) {
            tetra_mount_connector_holder(conn_core_sleeve, conn_core_o_diam / 2, conn_core_diam / 2, conn_core_overlap, conn_core_s_diam / 2);
        }
    }
}

// microphone body: render all parts with a vertical separation
//

module render_tetra_body(z_offset, spread, showint) {
    rotate([0, 180, 0]) {
        render_tetra_connector_flare(0);
    }
    lippy = spread - mount_lip;
    render_tetra_pcb_mount(lippy, showint);
    render_tetra_capsule_flare(tetra_pcb_mount_height + 2 * lippy);
}

// microphone: render the full assembly with a vertical separation
//

module render_tetra_microphone(z_offset, spread) {
    render_tetra_body(z_offset, spread);
    lippy = spread - mount_lip;
    render_tetra_capsule_array(z_offset + tetra_pcb_mount_height + mount_top_height +
            flare_height + stalk_height + pcb_hi_clear + pcb_hi_exp + 2 * lippy + spread/2 + mic_radius, 0);
}

// microphone: render the full assembly with a vertical separation
//             cut out halt of the assembly so that we can see the inside
//

module render_tetra_microphone_cutout(z_offset, spread) {
    difference() {
        render_tetra_microphone(z_offset, spread);
        // a cube that blots out 1/4 of the microphone
        rotate([0, 0, 90]) {
            translate([0, 0, -300]) {
                cube([50, 100, 650]);
            }
        }
    }
}

// shock mount: microphone clip on stand mount
//

module render_tetra_shock_mount_stand(z_offset) {
    translate([z_offset]) {
        shock_mount_stand(mic_mount_height, mount_wall, mic_mount_wall);
    }
}

// shock mount: external ring
//

module render_tetra_shock_mount_external_ring(z_offset) {
    translate([0, 0, z_offset]) {
        tetra_shock_mount_external_ring(external_ring_height, box_radius, mount_corner, external_ring_radius);
    }
}

// shock mount: bottom internal ring
//
module render_tetra_shock_mount_internal_ring(z_offset) {
    translate([0, 0, z_offset]) {
        tetra_shock_mount_internal_ring(internal_ring_height, box_radius, internal_band_height, mount_corner, internal_ring_gap);
    }
}

// test arm mount
//
module render_tetra_arm_mount(z_offset) {
    translate([0, 0, z_offset]) {
        tetra_arm_mount(internal_ring_height, box_radius, internal_band_height, mount_corner, internal_ring_gap);
    }
}

// shock mount: render all parts
//

module render_tetra_shock_mount(z_offset) {
    // internal ring
    translate([0, 0, z_offset + (internal_ring_height + external_ring_height) / 2 - 1]) {
        rotate([0, 180, 0]) {
            render_tetra_shock_mount_internal_ring(0);
        }
    }
    // external ring
    translate([0, 0, z_offset]) {
        render_tetra_shock_mount_external_ring(0);
    }
    // mount to stand
    translate([box_radius + mount_corner + ring_wall + ring_arm_gap, 0, -(mic_mount_height + mic_mount_radius + 13.25) + z_offset]) {
        render_tetra_shock_mount_stand(0);
    }
}

