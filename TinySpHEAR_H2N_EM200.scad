//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// TinySpHEAR, First Order (B-format) Ambisonics Microphone
// Add-on array for H2N with EM200 capsules
// 
// Copyright 2015-2017, Fernando Lopez-Lezcano, All Rights Reserved
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
include <TinySpHEAR_H2N_common.scad>;

// dimensions of the EM200 electret microphone capsule
capsule_radius = 14.6 / 2;
capsule_height = 4.75;
mic_radius = 11;

// make triangular legs have the right height
connect = 1;
leg_thick = capsule_height;

// adjust the depth of slots in mount
mic_to_mount_fit = -0.7;

////
//// render the different assemblies
////

facets = 128;

//// microphone body and array
windscreen_thread_radius = mic_radius * 1.6;
windscreen_thread_height = 8;

// make winscreen radius and height the same as for the EM200 standalone microphone
windscreen_height = 66;
windscreen_radius = box_corner_radius + 6.0;

// height of the lower windscreen
windscreen_lower_height = 25;

// render the whole thing

difference() {
union() {

*h2n_ring(h2n_width_m, h2n_depth_m, h2n_depth * 0.425, h2n_band_height, h2n_col_tilt,
         h2n_side_band_w, h2n_side_band, h2n_band_wall, h2n_band_wall, mount_radius, h2n_col_wall);

*h2n_columns(h2n_width_m, h2n_column_height, h2n_band_height, h2n_col_tilt,
            transition_height, h2n_mount_radius, h2n_col_wall, wall);

translate([0, 0, h2n_column_height]) {
    h2n_bridge((h2n_width_m / 2 + mount_radius - h2n_col_wall - h2n_column_height * tan(h2n_col_tilt)) * 2,
               h2n_bridge_base_height, h2n_bridge_stalk_height, mount_radius, h2n_col_wall, h2n_stalk_wall, wall, 
               windscreen_thread_radius, windscreen_thread_height);
}

// capsule array mount
rotate([0, 0, -90]) translate([0, 0, 95]) {
    tetra_capsule_array_mount([-45, 135], mount_radius, wall);
}

// cylindrical stalk
translate([0, 0, 65]) {
    difference() {
        cylinder(r = mount_radius + wall, h = 30.0, $fn = facets);
        cylinder(r = mount_radius, h = 30.0, $fn = facets);
    }
}

// conical stalk
translate([0, 0, 44]) {
    difference() {
        cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth, r2 = mount_radius + wall, 
                h = 21, $fn = facets);
        cylinder(r1 = windscreen_thread_radius - windscreen_thread_depth - wall, r2 = mount_radius, 
                h = 21, $fn = facets);
    }
}

render_sphear_upper_windscreen(37.2 + 23 - 0.5);

render_h2n_lower_windscreen(37.2);

*translate([0, 0, h2n_column_height]) {
    h2n_bridge_connector((h2n_width_m / 2 + mount_radius - h2n_col_wall - h2n_column_height * tan(h2n_col_tilt)) * 2,
               h2n_bridge_base_height, mount_radius, h2n_col_wall, h2n_stalk_wall, wall);
}

*translate([0, 0, h2n_column_height + 40]) {
    h2n_connector_to_stalk((h2n_width_m / 2 + mount_radius - h2n_col_wall - h2n_column_height * tan(h2n_col_tilt)) * 2,
            h2n_xlr_height, h2n_xlr_thread_height, h2n_xlr_thread_diam, h2n_xlr_thread_pitch, h2n_xlr_shoulder, h2n_stalk_wall);
}

*translate([0, 0, h2n_column_height + h2n_xlr_height + 5 + 40]) {
    h2n_stalk_to_array_mount((h2n_width_m / 2 + mount_radius - h2n_col_wall - h2n_column_height * tan(h2n_col_tilt)) * 2,
            h2n_xlr_stalk_height, h2n_stalk_wall);
}

rotate([0, 0, 90]) {
    render_tetra_capsule_array(h2n_column_height + h2n_bridge_base_height + h2n_bridge_stalk_height + 46);
}

translate([0, 0, 100]) {
    *h2n_wind_screen_vertical_ring(h2n_width_m, 1.6, 10.0);
    *rotate([0, 0, 180]) h2n_wind_screen_vertical_ring(h2n_width_m, 1.6, 10.0);
    *h2n_wind_screen_horizontal_ring(h2n_width_m, 1.6);
    *h2n_wind_screen_vertical_aux_ring(h2n_width_m, 1.6);
}

*rotate([0, 90, 0])
    h2n_wind_screen_vertical_ring(h2n_width_m, 1.6, 10.0);


*h2n_wind_screen_horizontal_ring(h2n_width_m, 1.6);


*rotate([90, 180, 0])
    h2n_wind_screen_vertical_aux_ring(h2n_width_m, 1.6);

}
*rotate([0, 0, 22.5/2]) translate([-40, -50, 0]) {
    cube([80, 50, 170]);
}
}

// individual capsule holders

*render_tetra_capsule_top(0);

*render_tetra_capsule_bot(0);

// make sure dimensions are fine
*translate([-(h2n_width_m - 0.1) / 2, - 0.5, 0]) {
    cube([h2n_width_m - 0.1, 1, 1]);
}

*translate([-0.5, -(h2n_depth_m - 0.1) / 2, 0]) {
    cube([1, h2n_depth_m - 0.1, 1]);
}

// some tests with traced profiles
*difference() {
    translate([0, -2.5, 0]) {
        scale([2.15, 2.15, 1.0]) {
            H2N_top_up_outline(5.0);
        }
    }
// scale([1.75, 1.75, 1.0]) {
    translate([0, -2.4, 0]) {
        scale([2.02, 2.02, 1.0]) {
            H2N_top_up_outline(5.0);
        }
    }
}

*scale(1.665) {
    translate([0, 10, -0]) {
        rotate([0, 0, 0]) {
            H2N_front_outline(1.0);
        }
    }
}
*rotate([0, 0, 4]) translate([35, 0, 0])
    cube([2, 80, 4]);
