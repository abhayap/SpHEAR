//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// OctaSpHEAR or Octathingy, Second Order Ambisonics Microphone
//
// based on:
// "A second-order soundfield microphone with improved polar pattern shape"
// by Eric Benjamin, Audio Engineering Society Convention Paper 8728, 
// October 2012, San Francisco
//
// Microphone optimized for EM200 14mm capsules and Zapnspark interface
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

// microphone version
// 1 -> original
// 2 -> flower power
mic_version = 2;

// printed circuit board version
// 1 -> single layer, milled in house
// 2 -> double layer with ground plane, smaller, fabricated
pcb_version = 2;

// type of octathingy (for mic_version -> 1)
// 0 -> regular octathingy (equilateral triangles in the square antiprism)
// 1 -> tetrahedral compatible octathingy (same elevation angle as the tetrahedral mic)
tetra_compat = 1;

// dimensions of the EM200 electret microphone capsule
capsule_radius = 14.55 / 2;
capsule_height = 4.75;

// radius of capsule array
mic_radius = (mic_version == 1) ? 18 : 20.5;

// include shared modules
//
// http://dkprojects.net/openscad-threads/
include <threads.scad>;

include <SpHEAR_common.scad>
include <Octathingy_common.scad>;
include <SpHEAR_windscreen.scad>;
include <Octathingy_mount_pcb.scad>;

include <polygons.scad>;

////
//// overrides and parameters
////

// override Octathingy_common fudge (0.15)
// 0.17 for Ultimaker 2+
// 0.12 for Ultimaker 3
fudge = 0.12;

// mic_version 1: make triangular legs have the right height
connect = 4;
leg_thick = capsule_height * 0.55;

// radius of windscreen thread
//
// adjusted with offset so that it is inset with respect to the body
// so that the new shock mount sleeve fits over the thread into the body
//
// octa_pcb_radius for pcb v2 is 27.42, the radius used is 25.6 
windscreen_thread_offset = (pcb_version == 2 ? -1.82 : -1.82);
windscreen_thread_radius = octa_pcb_radius + windscreen_thread_offset;
windscreen_radius = windscreen_thread_radius + 5.0;

// windscreen thread for pcb version 1
// this is used for the upper part of the windscreen
windscreen_thread_radius_pcb1 = 31.425;
windscreen_radius_pcb1 = windscreen_thread_radius_pcb1 + 5.0;

// do we need to override thread height?
windscreen_thread_height = 8;

windscreen_height = pcb_version == 2 ? 68.5 : 72;
windscreen_thread_fit = 5 * fit;

//
ridge_width = 1.5;

// up from 1.7 in _common.scad
capsule_cable_diam = 2.0;
cable_wall = wall;


////////
//// ready to print individual parts
////////

// NOTE: remove the "*" at the beginning of a line to render that part
//       make sure mic_version and pcb_version are set to the right version

// single capsule holder
*if (mic_version == 2) {
    // 3d print with support
    rotate([180, 0, 0]) capsule_holder(holder_ratio, transition_ratio);
} else {
    // upper
    render_octa_capsule_top(0);
    // lower
    *render_octa_capsule_bot(0);
}

// capsule array core and stalk
//
if (mic_version == 2) {
    // upper half (3d print with support)
    *capsule_holder_core(mount_radius + wall, stalk_height, 1);
    // lower half (with stalk - 3d print with support)
    *rotate([180, 0, 0]) capsule_holder_core(mount_radius + wall, stalk_height, -1);
    // connection ring
    *translate([0, 0, 0]) capsule_holder_ring(shift = -0.2);
} else {
    *render_octa_capsule_stalk(0);
}

// flare from body to capsule array stalk
*rotate([0, 0, -22.5]) render_octa_capsule_flare(0);

// body
*rotate([0, 0, -22.5]) render_octa_pcb_mount(0, 1);

// flare from body to db25 connector
// (3d print with support)
*rotate([0, 0, 0 + 22.5]) {
    conn_offset = 2.0;
    octa_mount_flare_dsub(pcb_low_clear + pcb_low_exp - 5, mount_lip, 33 - 13,
                            octa_pcb_radius,
                            conn_core_o_diam / 2, conn_core_o_diam + conn_offset);
}

// shock mount
//
// sleeve
*octa_shock_mount_sleeve(octa_pcb_radius, internal_ring_height, true, true);

// external ring
*render_octa_shock_mount_external_ring(0);

// quick lock microphone stand mount
*render_octa_shock_mount_stand(0);

// threaded microphone stand mount
*shock_mount_threaded_stand(20, 2, 1);

// windscreen
//
*if (pcb_version == 2) {
    // tapered lower windscreen for pcb2 (from pcb2 to pcb1 diameter)
    render_sphear_lower_tapered_windscreen(windscreen_radius - 3, windscreen_radius_pcb1, 0);
} else {
    // regular lower windscreen for pcb1
    render_sphear_lower_windscreen(windscreen_radius, 0);
}
// upper windscreen
*render_sphear_upper_windscreen(windscreen_thread_radius_pcb1 + 5.0, 0);

// windscreen or shock mount attachment ring
*sphear_windscreen_round_mount(windscreen_thread_height, windscreen_thread_radius, windscreen_radius - 1.75, 2 * wall, true);


////////
//// full microphone with height offset for different parts
////////

// set to true to render printed circuit board and components for testing
render_pcb = false;

// reduce resolution for quick tests
// facets = 64;
// cfacets = 64;

difference() {
    // separate the parts slightly to show joints
    stretch = 0.1;
    //
    union() {
        // the capsule array
        //
        *if (mic_version == 1) {
            // version 1 capsule array
            //
            rotate([0, 0, -22.5]) render_octa_capsule_array(202.8);
            // stalk from flare to capsule array
            rotate([0, 0, -22.5]) render_octa_capsule_stalk(pcb_version == 2 ? 43.2 : 49.2);
        } else {
            // version 2 flower power capsule array
            //
            translate([0, 0, 194.2]) rotate([0, 0, -22.5]) {
                difference() {
                    union() {
                        // capsule array
                        render_octa_capsule_holder_array();
                        // upper half of spherical core
                        capsule_holder_core(mount_radius + wall, stalk_height, 1);
                        // lower half of spherical core (with stalk)
                        translate([0, 0, -0.05]) capsule_holder_core(mount_radius + wall, stalk_height, -1);
                        // connection ring
                        *translate([0, 0, 0]) capsule_holder_ring(shift = -0.2);
                    }
                    *rotate([0, 0, 0]) translate([-50, -25, -25]) cube([50, 50, 50]);
                }
            }
        }
        // flare from body to stalk
        *rotate([0, 0, -22.5]) render_octa_capsule_flare(pcb_version == 2 ? 42.4 + stretch : 49.2);
        // body
        *rotate([0, 0, -22.5]) render_octa_pcb_mount(0, 1);
        // flare from body to db25 connector
        *rotate([180, 0, 90 - 22.5]) {
            conn_offset = 2.0;
            translate([0, 0, -mount_lip]) octa_mount_flare_dsub(pcb_low_clear + pcb_low_exp - 5, mount_lip, 33 - 13,
                                    octa_pcb_radius,
                                    conn_core_o_diam / 2, conn_core_o_diam + conn_offset);
        }
        // thread cover (protects thread or locks down shock mount when windscreen not used)
        *translate([0, 0, pcb_mount_height - 10 + 15]) {
            sphear_windscreen_round_mount(windscreen_thread_height, windscreen_thread_radius,
                windscreen_radius - 1.75, 2 * wall, true);
        }
        //
        // windscreen
        //
        *if (pcb_version == 2) {
            // tapered lower windscreen for pcb2 (from pcb2 to pcb1 diameter)
            render_sphear_lower_tapered_windscreen(windscreen_radius - 3, windscreen_radius_pcb1, pcb_mount_height - 10 + 15);
        } else {
            // regular lower windscreen for pcb1
            render_sphear_lower_windscreen(windscreen_radius, pcb_mount_height - 10 + 15);
        }
        // upper windscreen for both designs
        *render_sphear_upper_windscreen(windscreen_thread_radius_pcb1 + 5.0, pcb_mount_height - 10 + 15 + windscreen_height);
        //
        // shock mount
        //
        // internal sleeve (slides over body from the top)
        *translate([0, 0, pcb_version == 2 ? 3.0 : 9.1]) rotate([0, 0, 0]) {
            octa_shock_mount_sleeve(octa_pcb_radius, internal_ring_height, true, true);
        }
        // external ring
        *translate([0, 0, (pcb_version == 2 ? 3.0 : 9.1) + (internal_ring_height/2) - (external_ring_height/2)]) {
            render_octa_shock_mount_external_ring(0);
        }
        // quick lock microphone stand mount
        *translate([pcb_version == 2 ? 72.5 : 76, 0, pcb_version == 2 ? -25.5 : -19.5]) {
           render_octa_shock_mount_stand(0);
        }
    }
    //
    // render to have a cutout view of microphone for debugging
    //
    z_rotation = 0;
    *rotate([0, 0, z_rotation]) translate([-100, -100, -100]) {
        cube([100, 100, 400]);
    }
}

// serial number tests
//
*difference() {
    union() {
        // add a serial number
        *translate([-25.5, 0, 43.2 + 7]) rotate([90, 0, -90]) scale ([0.2, 0.2, 0.5])
            linear_extrude(0.5) text("8S004", halign = "center");
    }
}

////
//// old versions
////

// the whole body
*translate([0, 0, -20]) render_octa_body(0, 10, 0);

// the whole microphone
// or use render_octa_microphone_cutout(0, 0) for a "transparent" view
//
*rotate([0, 0, 90 - 22.5]) render_octa_microphone_cutout(0, 0, 0);
*rotate([0, 0, 90 - 22.5]) render_octa_microphone(0, 0, 0);

////
//// old microphone shock mount
////

// sleeve (body slips into it)

*rotate([180, 0, 0]) translate([0, 0, -55/2 - 21 - (pcb_version == 2 ? -5 : 0)]) {
    octa_shock_mount_internal_ring(internal_ring_height, octa_pcb_radius, 20, 0, 0);
}

