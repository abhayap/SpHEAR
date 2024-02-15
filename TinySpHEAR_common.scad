//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// TinySpHEAR, First Order (B-format) Ambisonics Microphone
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

// https://en.wikipedia.org/wiki/Tetrahedron
// angle of capsule to vertical axis = atan(sqrt(2)) = 54.7356103172

////
//// default model parameters
////

// height and eccentricity of top connector
mount_top_height = 15.0;
mount_top_eccentricity = 1.3;

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
mic_mount_fit = 0.2;
mic_mount_slot_height = 11.5;
mic_mount_slot_width = 4.25;
mic_mount_slot_radius = 6.25  / 2;
mic_mount_wall = 1.5;
mic_mount_height = 20.0 + mic_wire_hole_offset + mic_wire_hole_radius + 2 * mic_mount_wall;

// back (leads) and front (components) clearance of pcb
pcb_front = pcb_version == 2 ? 10.00 : 13.25;
pcb_back = pcb_version == 2 ? 2.0 : 3.0;

// calculated minimum "radius" of microphone box
box_radius = pcb_front + (pcb_thickness + pcb_tfit) + pcb_back + (pcb_version == 2 ? 1 : 2) * wall;

// calculated main body corner radius
mount_corner = box_radius - pcb_width / 2 + pcb_slot_depth + (pcb_version == 2 ? 1 : 4);

// calculated radius at the corners
box_corner_radius = (box_radius + wall - mount_corner) / sin(45) + mount_corner;

// windscreen thread radius (for version 1 of microphone)
windscreen_thread_radius = box_corner_radius + windscreen_thread_depth;

//// end of model parameters
////
//// rendering control

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

// elevation angle for the capsule holders (fixed for this microphone)
elev_angle = atan(sqrt(1/2));

// angles of the connection legs and adjacent capsule holders
leg_angles_top = 
    [
        [-120, elev_angle], 
        [0, elev_angle],
        [120, elev_angle]
    ];

leg_angles_bot = 
    [
        [-120, elev_angle], 
        [120, elev_angle]
    ];

// adjustment for the inner radius of the capsule holder
//   measured inside diameter of a trial print was around 7.5 to 8.2 
//   instead of 10, capsule diameter was 9.99)
fudge = 0.12;

// adjustment for fit of slots in connection legs and mount
// 0.1: initial setting
// 0.1 ->0.15: Ultimaker 2 + Extended plus APL (2016.06.17)
fit = 0.15;

// microphone structure geometry
capsule_sep_min = (mic_radius - capsule_height) * cos(elev_angle) - (capsule_radius + wall) * sin(elev_angle);
capsule_sep_max = mic_radius * cos(elev_angle) - (capsule_radius + wall) * sin(elev_angle);
capsule_bottom = mic_radius * sin(elev_angle) + (capsule_radius + wall) * cos(elev_angle);
mount_radius_capsule = capsule_sep_max;

// simple microphone mount, clips into standard microphone stand
//
// angles: angles for mount slots
// wall: thickness of cylinder wall
// stand_wall: thickness of stand mount wall
// separation: height of mount with respect of the microphone assembly (for display)

module ellipsoid(height, rad_bot, rad_top, eccentricity) {
    linear_extrude(height = height, scale = [eccentricity, rad_top / rad_bot]) {
        circle(r = rad_bot, $fn = facets); 
    }
}

module mount (angles, wall, stand_wall, separation) {
    translate([0, 0, -separation]) {
        difference() {
            union() {
                // conic section
                translate([0, 0, mic_mount_height + mount_height]) {
                    rotate([0, 0, 45]) {
                        difference() {
                            ellipsoid(mount_top_height, mount_radius + wall, mount_radius_capsule, mount_top_eccentricity);
                            ellipsoid(mount_top_height, mount_radius, mount_radius_capsule * 0.5, mount_top_eccentricity * 1.05);
                        }
                    }
                }
                // stalk
                translate([0, 0, mic_mount_height + mount_height * 2/3]) {
                    difference() {
                        cylinder(r = mount_radius + wall, h = mount_height / 3, $fn = facets);
                        // make the hole for the mount
                        cylinder(r = mount_radius, h = mount_height / 3, $fn = facets);
                    }
                }
                // transition to stand mount
                translate([0, 0, mic_mount_height]) {
                    difference() {
                        cylinder(r2 = mount_radius + wall, r1 = mic_mount_radius + mic_mount_fit + stand_wall, 
                                h = mount_height * 2 / 3, $fn = facets);
                        // make the hole for the mount
                        cylinder(r2 = mount_radius, r1 = mic_mount_radius + mic_mount_fit, 
                                h = mount_height * 2 / 3, $fn = facets);
                    }
                }
                // stand mount
                translate([0, 0, 0]) {
                    difference() {
                        union() {
                            // main mount cylinder
                            translate([0, 0, 0]) {
                                difference() {
                                    cylinder(r = mic_mount_radius + mic_mount_fit + stand_wall, h = mic_mount_height, $fn = facets);
                                    // make the hole for the mount (* 1.5 to cut the ridge as well)
                                    cylinder(r = mic_mount_radius + mic_mount_fit, h = mic_mount_height, $fn = facets);
                                }
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
                        // hole for microphone wiring
                        translate([mic_mount_radius - stand_wall / 2, 0, mic_mount_height - mic_wire_hole_offset]) {
                            rotate([0, 90, 0]) {
                                cylinder(r = mic_wire_hole_radius, h = 2 * stand_wall, $fn = facets);
                            }
                        } 
                    }
                }
            }
            // indentations that match the two lower capsule holders
            translate([0, 0, mic_mount_height + mount_height + mount_top_height + 
                       (mic_radius - capsule_height) + capsule_height * cos(elev_angle)]) {
                rotate([0, (90 + elev_angle), angles[0]]) {
                    translate([0, 0, mic_radius - capsule_height]) {
                        capsule([], 0, 1, ridge_wfit, ridge_hfit, 1);
                    }
                }
                rotate([0, (90 + elev_angle), angles[1]]) {
                    translate([0, 0, mic_radius - capsule_height]) {
                        capsule([], 0, 1, ridge_wfit, ridge_hfit, 1);
                    }
                }
            }
        }
    }
}

// render a tetrahedral capsule array
//
module render_tetra_capsule_array_old(z_offset) {
    translate([0, 0, z_offset]) {
        // all four capsules
        rotate([0, (90 - elev_angle), 45]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule(leg_angles_top, 60, 0, 0.0, 0.0, 0);
            }
        }
        rotate([0, (90 - elev_angle), -135]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule(leg_angles_top, 60, 0, 0.0, 0.0, 0);
            }
        }
        rotate([0, (90 + elev_angle), -45]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule(leg_angles_bot, 0, 1, 0.0, 0.0, 0);
            }
        }
        rotate([0, (90 + elev_angle), 135]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule(leg_angles_bot, 0, 1, 0.0, 0.0, 0);
            }
        }
    }
}

module render_tetra_capsule_array(z_offset, r_offset) {
    translate([0, 0, z_offset]) {
        // all four capsules
        rotate([0, (90 - elev_angle), 45]) {
            translate([0, 0, mic_radius - capsule_height + r_offset]) {
                capsule(leg_angles_top, 60, 0, 0.0, 0.0, 0);
            }
        }
        rotate([0, (90 - elev_angle), -135]) {
            translate([0, 0, mic_radius - capsule_height + r_offset]) {
                capsule(leg_angles_top, 60, 0, 0.0, 0.0, 0);
            }
        }
        rotate([0, (90 + elev_angle), -45]) {
            translate([0, 0, mic_radius - capsule_height + r_offset]) {
                capsule(leg_angles_top, 0, 0, 0.0, 0.0, 0);
            }
        }
        rotate([0, (90 + elev_angle), 135]) {
            translate([0, 0, mic_radius - capsule_height + r_offset]) {
                capsule(leg_angles_top, 0, 0, 0.0, 0.0, 0);
            }
        }
    }
}

// render individual capsules
//
module render_tetra_capsule_top() {
    capsule(leg_angles_top, 60, 0, 0.0, 0.0, 0);
}

module render_tetra_capsule_bot() {
    capsule(leg_angles_bot, 0, 1, 0.0, 0.0, 0);
}

// render simple microphone stand mount
//
module render_simple_stand_mount(z_offset) {
    translate([0, 0, z_offset]) {
        mount([-45, 135], mount_wall, mic_mount_wall, mic_mount_height + mount_top_height + mount_height + capsule_bottom);
    }
}

// capsule holder with conical mount
//
// ratio of capsule radius to transition length
transition_ratio = 1.0;
// ratio of capsule radius to bottom radius of holder
holder_ratio = 0.4;

// diameter of microphone capsule cable (Mogami 2490)
capsule_cable_diam = 1.7;

module capsule_holder(ratio, transition, hollow = true) {
    capsule_h = capsule_height;
    difference() {
        // main capsule holder, use a conical bore to press fit the capsule
        f = 0.05;
        cylinder(r = capsule_radius + fudge + wall, h = capsule_h, $fn = cfacets);
        if (hollow) cylinder(r1 = capsule_radius + fudge - f, r2 = capsule_radius + fudge, h = capsule_h + thin_mint, $fn = cfacets);
    }
    // conical transition into core sphere
    transition_h = transition * capsule_radius;
    translate([0, 0, - transition_h]) {
        difference() {
            cylinder(r2 = capsule_radius + fudge + wall, r1 = (capsule_radius) * ratio + wall, h = transition_h, $fn = facets);
            // add overhang so that we have a stop when inserting the capsule
            overhang = 0.2;
            if (hollow) cylinder(r2 = capsule_radius + fudge - overhang, r1 = (capsule_radius) * ratio, h = transition_h, $fn = facets);
            // add holes in the walls of the conical transition
            if (hollow) {
                for (r = [0:36:179]) {
                    rotate([0, 90, r]) {
                        translate([-transition_h, 0, -capsule_radius - 2 * wall])
                            scale([3.5, 1.25, 1]) cylinder(r = 1.0, h = (capsule_radius + 2 * wall) * 2, $fn = facets);
                    }
                }
            }
        }
        // lip to insert holder into core
        lip_d = 1.4 * wall;
        translate([0, 0, hollow == false ? -3 : -lip_d]) {
            difference() {
                // if not hollow make the ring longer to cut into core
                // cylinder(r = (capsule_radius) * ratio + wall + (hollow == true ? 0 : fit/2),
                cylinder(r = (capsule_radius) * ratio + wall + (hollow == true ? 0 : 0),
                        h = hollow == true ? lip_d : 4.0, $fn = facets);
                if (hollow) { cylinder(r = capsule_cable_diam/2 * 1.4, h = lip_d + thin_mint, $fn = facets); }
            }
        }
    }
}

// new stype capsule array

// the spherical core and mounting stalk
//
// render = 0: the full sphere (for visualization)
// render = 1: upper half
// render = -1: lower half with stalk

// thickness of ring that connects both halves of the core sphere
core_ring_height = 5.0;

// holes for screws that hold together both halves of the sphere
module capsule_holder_screws(radius, wall, screw_r, shift = 0) {
    h_offset = 1.2;
        for (r = [90, 270]) {
            for (t = [0, 45]) {
                m = t > 0 ? 1 : 0;
                // 11.5 matches the angle for the flat shaves in the core
                mirror([0, 0, m]) rotate([0, 11.5, r + t]) translate([-(radius + 2 * wall), 0, shift]) {
                    rotate([0, 90, 0]) {
                        cylinder(r = screw_r, h = radius, $fn = facets);
                    }
                }
            }
        }
}

// ring that connects the two halves of the core sphere
module capsule_holder_ring(offset = 3.5, shift = 0) {
    s_radius = mic_radius - capsule_radius * (1 + transition_ratio) + offset;
    ring_h = core_ring_height - 0.2;
    translate([0, 0, -ring_h/2]) difference() {
        cylinder(r = s_radius - 2.5 * wall - fit, h = ring_h, $fn = facets);
        cylinder(r = s_radius - 4 * wall - fit, h = ring_h, $fn = facets);
        // shift the holes slightly so the two halves are pressed together
        translate([0, 0, ring_h/2]) capsule_holder_screws(s_radius, wall, 0.65, shift);
    }
}

// spherical core
module capsule_holder_core(top_radius, render = 0, offset = 3.5) {
    s_radius = mic_radius - capsule_radius * (1 + transition_ratio) + offset;
    difference() {
        union() {
            difference() {
                // core
                sphere(r = s_radius, $fn = facets);
                sphere(r = s_radius - 2.5 * wall, $fn = facets);
                // shave sides as well (cosmetic, really)
                for (az = [-45, 135]) rotate([0, -elev_angle, az]) {
                    translate([s_radius - 0.5 * wall, -s_radius/2, -s_radius/2]) {
                        cube([s_radius, s_radius, s_radius]);
                    }
                }
                for (az = [45, -135]) rotate([0, elev_angle, az]) {
                    translate([s_radius - 0.5 * wall, -s_radius/2, -s_radius/2]) {
                        cube([s_radius, s_radius, s_radius]);
                    }
                }
                // remove one half of the sphere
                if (render == 1) {
                    translate([-mic_radius, -mic_radius, -mic_radius * 2]) cube([mic_radius * 2, mic_radius * 2, mic_radius * 2]);
                }
                if (render == -1) {
                    translate([-mic_radius, -mic_radius, 0]) cube([mic_radius * 2, mic_radius * 2, mic_radius * 2]);
                }
                // make space for connection ring
                ring_h = core_ring_height;
                translate([0, 0, -ring_h/2]) {
                    cylinder(r = s_radius - 2.5 * wall, h = ring_h, $fn = facets);
                }
                // hole for stalk
                if (render == -1) {
                    translate([0, 0, -mic_radius]) cylinder(r = mount_radius - 2*wall, h = mic_radius, $fn = facets);
                }
            }
            // stalk that transitions into flare
            if (render == -1) {
                //stalk_len = 15.0;
                // normal length plus 10 to insert into flare
                stalk_len = stalk_height + 10.0 + 10.0;
                inset = wall;
                translate([0, 0, - (stalk_len - inset + s_radius)]) {
                    difference() {
                        cylinder(r = top_radius, h = stalk_len + inset, $fn = facets);
                        cylinder(r = top_radius - wall, h = stalk_len + inset + thin_mint, $fn = facets);
                    }
                }
                // add flange for coupling into flare
                translate([0, 0, - (stalk_height - inset - 0.5 + 10.0 + 10.0)]) {
                    difference() {
                        cylinder(r2 = top_radius, r1 = top_radius + wall, h = 10.0, $fn = facets);
                        cylinder(r2 = top_radius - wall, r1 = top_radius, h = 10.0, $fn = facets);
                    }
                }
                translate([top_radius, 0, - (stalk_height - inset - 0.5 + 10.0 + 10.0 + 10.0)]) {
                    // add key to stalk so orientation is always correct
                    difference() {
                        cylinder(r = 0.4, h = 10.0, $fn = facets);
                    }
                }
            }
        }
        // make holes for capsule holders
        render_tetra_capsule_holder_array(false);
    }
    // index for aligning the two halves of core sphere
    rotate([0, 0, 0]) translate([s_radius, 0, 0]) {
        difference() {
            scale([1, 1, 2]) sphere(r = 0.5, $fn = facets);
            translate([-2.2, -1, -4]) cube([2, 2, 8]);
            if (render == 1) {
                translate([-2, -1, -8]) cube([4, 2, 8]);
            }
            if (render == -1) {
                translate([-2, -1, 0]) cube([4, 2, 8]);
            }
        }
    }
}

holder_ratio = 0.4;
transition_ratio = 0.8;

module render_tetra_capsule_holder_array(hollow = true) {
    // all four capsules
    rotate([0, (90 - elev_angle), 45]) {
        translate([0, 0, mic_radius - capsule_height]) {
            capsule_holder(holder_ratio, transition_ratio, hollow);
        }
    }
    rotate([0, (90 - elev_angle), -135]) {
        translate([0, 0, mic_radius - capsule_height]) {
            capsule_holder(holder_ratio, transition_ratio, hollow);
        }
    }
    rotate([0, (90 + elev_angle), -45]) {
        translate([0, 0, mic_radius - capsule_height]) {
            capsule_holder(holder_ratio, transition_ratio, hollow);
        }
    }
    rotate([0, (90 + elev_angle), 135]) {
        translate([0, 0, mic_radius - capsule_height]) {
            capsule_holder(holder_ratio, transition_ratio, hollow);
        }
    }
}

