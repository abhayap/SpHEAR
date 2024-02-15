//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// OctaSpHEAR or Octathingy, Second Order Ambisonics Microphone
//
// based on:
// "A second-order soundfield microphone with improved polar pattern shape"
// by Eric Benjamin, Audio Engineering Society Convention Paper 8728, 
// October 2012, San Francisco

// Copyright 2015-2019, Fernando Lopez-Lezcano, All Rights Reserved
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
// 3d Models released under the Creative Commons license as follows:
//   Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// http://creativecommons.org/licenses/by-nc-sa/4.0/

////
//// overrides

// inner radius of stalk
mount_radius = 4.0;

// this adds space for the protuding molex pins on which we solder
pcb_low_clear = 15.0;
pcb_hi_clear = 15.0;

////
//// rendering control

// what type of connection to use between capsule holders:
// 0 -> original cylindrical angled legs
// 1 -> interlocking horizontal legs
// 2 -> interlocking vertical legs
connect = 1;

// adjustment for the radius of the capsule
//   measured inside diameter of a trial print was around 7.5 to 8.2 
//   instead of 10, capsule diameter was 9.99)
fudge = 0.15;

// back and front clearance of pcb (components and leads)
pcb_front = pcb_version == 2 ? 2.50 : 3.00;
pcb_back = pcb_version == 2 ? 1.70 : 1.80;

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
elev_angle =  90 - (tetra_compat == 0 ? atan(1 / (2 * sqrt(sqrt(2))) * sqrt(2)) : atan(sqrt(1/2)));

// calculate half angle between vertices in the square antiprism
// these angles define the length of the connecting legs
//
// z coordinate of antiprism vertices
vert_z = (sqrt(2) / 2) / tan(elev_angle);
// vector length (same for all antiprism vertices)
vert_n = norm([-0.5, -0.5, vert_z]);
// half angle between adjacent vertices in either the upper or lower rings
vert_angle_h = acos(([-0.5, -0.5, vert_z] / vert_n) * ([0.5, -0.5, vert_z] / vert_n)) / 2;
// half angle between adjacent vertices in the upper and lower rings
vert_angle_v = acos(([0.0, -1 / sqrt(2), -vert_z] / vert_n) * ([0.5, -0.5, vert_z] / vert_n)) / 2;

// angles of the connection legs and adjacent capsule holders
leg_angles = tetra_compat == 0 ?
    [
        [-63, 90 - vert_angle_h, 0, 1], 
        [63, 90 - vert_angle_h, 0, 1],
        [-141, 90 - vert_angle_v, 0, 1],
        [141, 90 - vert_angle_v, 0, 1]
    ] :
    [
        [-60.5, vert_angle_h, 19.5, 1], 
        [60.5, vert_angle_h, 19.5, 1],
        [-144.3, vert_angle_v, 8, 2],
        [144.3, vert_angle_v, 8, 2]
    ];

// microphone holder geometry
capsule_sep_min = (mic_radius - capsule_height) * sin(elev_angle) - (capsule_radius + wall) * cos(elev_angle);
capsule_sep_max = mic_radius * sin(elev_angle) - (capsule_radius + wall) * cos(elev_angle);
capsule_bottom = mic_radius * cos(elev_angle) + (capsule_radius + wall) * sin(elev_angle);
mount_radius_capsule = capsule_sep_max;

// render the capsule array
//
module render_octa_capsule_array(z_offset) {
    translate([0, 0, z_offset]) {
        for (az = [45, 135, -45, -135]) {
            rotate([0, elev_angle, az]) {
                translate([0, 0, mic_radius - capsule_height]) {
                    capsule(leg_angles, 180, 0, 0.0, 0.0, 0);
                }
            }
            rotate([0, 180 - elev_angle, az + 45]) {
                translate([0, 0, mic_radius - capsule_height]) {
                    capsule(leg_angles, 0, 1, 0.0, 0.0, 0);
                }
            }
        }
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
        if (hollow) {
            cylinder(r1 = capsule_radius + fudge, r2 = capsule_radius + fudge + f, h = capsule_h/2 + thin_mint, $fn = cfacets);
            translate([0, 0, capsule_h*1/2]) {
                cylinder(r = capsule_radius + fudge + f, h = capsule_h + thin_mint, $fn = cfacets);
            }
        }
    }
    // conical transition into core sphere
    transition_h = transition * capsule_radius;
    translate([0, 0, - transition_h]) {
        difference() {
            // add ridge to get a perfect alignment when inserting into core
            over = 0.5;
            cylinder(r2 = capsule_radius + fudge + wall, r1 = (capsule_radius) * ratio + wall + over, h = transition_h, $fn = facets);
            // add overhang so that we have a stop when inserting the capsule
            overhang = 0.2;
            if (hollow) cylinder(r2 = capsule_radius + fudge - overhang, r1 = (capsule_radius) * ratio, h = transition_h, $fn = facets);
            // add holes in the walls of the conical transition
            if (hollow) {
                for (r = [0:36:179]) {
                    rotate([0, 90, r]) {
                        translate([-transition_h, 0, -capsule_radius - 2 * wall])
                            scale([7, 1.2, 1]) cylinder(r = 1.0, h = (capsule_radius + 2 * wall) * 2, $fn = facets);
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

module capsule_holder_float(ratio, transition, hollow = true, depth = 0) {
    capsule_h = capsule_height;
    f = 0.05;
    difference() {
        // main capsule holder, use a conical bore to press fit the capsule
        cylinder(r = capsule_radius + fudge + wall, h = capsule_h + depth, $fn = cfacets);
        if (hollow) {
            cylinder(r1 = capsule_radius + fudge, r2 = capsule_radius + fudge + f, h = capsule_h/2 + thin_mint + depth, $fn = cfacets);
            translate([0, 0, capsule_h*1/2]) {
                cylinder(r = capsule_radius + fudge + f, h = capsule_h + thin_mint + depth, $fn = cfacets);
            }
        }
    }
    // overhang to act as a back stop for the capsule
    overhang = 0.3;
    translate([0, 0, -overhang]) difference() {
        cylinder(r = capsule_radius + fudge + wall, h = overhang, $fn = cfacets);
        if (hollow) {
            cylinder(r1 = capsule_radius + fudge, r2 = capsule_radius + fudge + f - overhang, h = overhang + thin_mint, $fn = cfacets);
        }
    }
}

// capsule holder array
//
module render_octa_capsule_holder_ring_array(rot = 0, rot2 = 0, hollow = true, depth = 0) {
    for (az = [45, 135, -45, -135]) {
        rotate([0, elev_angle, az]) {
            translate([0, 0, mic_radius - capsule_height]) {
                rotate([rot, 0, -rot2]) capsule_holder_float(holder_ratio, transition_ratio, hollow, depth);
            }
        }
        rotate([0, 180 - elev_angle, az + 45]) {
            translate([0, 0, mic_radius - capsule_height]) {
                rotate([rot, 0, rot2]) capsule_holder_float(holder_ratio, transition_ratio, hollow, depth);
            }
        }
    }
}

module render_octa_capsule_holder_array(hollow = true, depth = 0) {
    for (az = [45, 135, -45, -135]) {
        rotate([0, elev_angle, az]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule_holder(holder_ratio, transition_ratio, hollow, depth);
            }
        }
        rotate([0, 180 - elev_angle, az + 45]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule_holder(holder_ratio, transition_ratio, hollow, depth);
            }
        }
    }
}

module render_tetra_capsule_holder_array(hollow = true) {
    for (az = [45, 135, -45, -135]) {
        rotate([0, elev_angle, az]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule_holder(holder_ratio, transition_ratio, hollow);
            }
        }
        rotate([0, 180 - elev_angle, az + 45]) {
            translate([0, 0, mic_radius - capsule_height]) {
                capsule_holder(holder_ratio, transition_ratio, hollow);
            }
        }
    }
}

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
        translate([0, 0, ring_h/2]) capsule_holder_screws(s_radius, wall, 0.55, shift);
    }
}

// spherical core
module capsule_holder_core(top_radius, height, render = 0, offset = 3.5) {
    s_radius = mic_radius - capsule_radius * (1 + transition_ratio) + offset;
    difference() {
        union() {
            difference() {
                // core
                sphere(r = s_radius, $fn = facets);
                sphere(r = s_radius - 2.5 * wall, $fn = facets);
                // holes for screws
                capsule_holder_screws(s_radius, wall, 0.9, 0.0);
                // remove slice at the top
                translate([-s_radius, -s_radius, s_radius - wall]) {
                    cube([2 * s_radius, 2 * s_radius, s_radius]);
                }
                // shave sides as well (cosmetic, really)
                for (az = [45, 135, -45, -135]) rotate([0, -11.5, az + 45]) {
                    translate([s_radius - 0.5 * wall, -s_radius/2, -s_radius/2]) {
                        cube([s_radius, s_radius, s_radius]);
                    }
                }
                for (az = [45, 135, -45, -135]) rotate([0, 11.5, az]) {
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
                    translate([0, 0, -mic_radius]) cylinder(r = mount_radius, h = mic_radius, $fn = facets);
                }
            }
            // stalk that transitions into flare
            if (render == -1) {
                //stalk_len = 15.0;
                // normal length plus 10 to insert into flare
                stalk_len = height + 10.0 + 10.0;
                inset = wall;
                translate([0, 0, - (stalk_len - inset + s_radius)]) {
                    difference() {
                        cylinder(r = top_radius, h = stalk_len + inset, $fn = facets);
                        cylinder(r = top_radius - wall, h = stalk_len + inset + thin_mint, $fn = facets);
                    }
                }
                // add flange for coupling into flare
                translate([0, 0, - (height - inset - 0.5 + 10.0 + 10.0)]) {
                    difference() {
                        cylinder(r2 = top_radius, r1 = top_radius + wall, h = 10.0, $fn = facets);
                        cylinder(r2 = top_radius - wall, r1 = top_radius, h = 10.0, $fn = facets);
                    }
                }
                translate([top_radius, 0, - (height - inset - 0.5 + 10.0 + 10.0 + 10.0)]) {
                    // add key to stalk so orientation is always correct
                    difference() {
                        cylinder(r = 0.4, h = 10.0, $fn = facets);
                    }
                }
            }
        }
        // make holes for capsule holders
        render_octa_capsule_holder_array(false);
    }
    // index for aligning the two halves of core sphere
    rotate([0, 0, 22.5]) translate([s_radius, 0, 0]) {
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

// capsule array stalk
module capsule_holder_stalk(top_radius, height, render = 0, offset = 3.5) {
    s_radius = mic_radius - capsule_radius * (1 + transition_ratio) + offset;
    union() {
        // stalk that transitions into flare
        if (render == -1) {
            //stalk_len = 15.0;
            // normal length plus 10 to insert into flare
            stalk_len = height + 10.0 + 10.0;
            inset = wall;
            translate([0, 0, - (stalk_len - inset + s_radius)]) {
                difference() {
                    cylinder(r = top_radius, h = stalk_len + inset, $fn = facets);
                    cylinder(r = top_radius - wall, h = stalk_len + inset + thin_mint, $fn = facets);
                }
            }
            // add flange for coupling into flare
            translate([0, 0, - (height - inset - 0.5 + 10.0 + 10.0)]) {
                difference() {
                    cylinder(r2 = top_radius, r1 = top_radius + wall, h = 10.0, $fn = facets);
                    cylinder(r2 = top_radius - wall, r1 = top_radius, h = 10.0, $fn = facets);
                }
            }
            translate([top_radius, 0, - (height - inset - 0.5 + 10.0 + 10.0 + 10.0)]) {
                // add key to stalk so orientation is always correct
                difference() {
                    cylinder(r = 0.4, h = 10.0, $fn = facets);
                }
            }
        }
    }
    // index for aligning the two halves of core sphere
    rotate([0, 0, 22.5]) translate([s_radius, 0, 0]) {
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

// connect array to upper flare
module flare_connector(top_radius, height, offset = 3.5) {
    s_radius = mic_radius - capsule_radius * (1 + transition_ratio) + offset;
    // stalk that transitions into flare
    //stalk_len = 15.0;
    // normal length plus 10 to insert into flare
    stalk_len = height + 10.0;
    inset = wall;
    translate([0, 0, - (2*stalk_len - inset + s_radius)]) {
        difference() {
            cylinder(r = top_radius, h = stalk_len + inset, $fn = facets);
            cylinder(r = top_radius - wall, h = stalk_len + inset + thin_mint, $fn = facets);
        }
    }
    translate([top_radius, 0, - (height - inset - 0.5 + 10.0 + 10.0 + 10.0)]) {
        // add key to stalk so orientation is always correct
        difference() {
            cylinder(r = 0.4, h = 13.0, $fn = facets);
        }
    }
}

// render individual capsules
//
module render_octa_capsule_top() {
    capsule(leg_angles, 180, 0, 0.0, 0.0, 0);
}

module render_octa_capsule_bot() {
    capsule(leg_angles, 0, 1, 0.0, 0.0, 0);
}

// render simple microphone stand mount
//
module render_simple_stand_mount(z_offset) {
    translate([0, 0, z_offset]) {
        mount([-45, 135], mount_wall, mic_mount_wall, mic_mount_height + mount_top_height + mount_height + capsule_bottom);
    }
}
