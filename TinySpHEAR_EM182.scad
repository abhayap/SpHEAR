//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// TinySpHEAR, First Order (B-format) Ambisonics Microphone
// Microphone optimized for EM182 capsules and Zapnspark interface
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

// dimensions of the EM182 electret microphone capsule (measured 10mm)
capsule_radius = 10.0 / 2;
capsule_height = 4.5;
mic_radius = 9.2;

// make triangular legs have the height of the capsule
connect = 1;
leg_thick = capsule_height;

// thinner connection legs
leg_width = 4;

// lower the capsule assembly into the mount a bit more
mic_to_mount_fit = 0.5;

// parameters for windscreen rendering
windscreen_height = 66;
windscreen_radius = box_corner_radius + 6.0;

////
//// render the different assemblies
////

facets = 128;

//// microphone body and array

*render_tetra_capsule_array(0, 0);

*render_tetra_capsule_flare(0);

*render_tetra_pcb_mount(0, 0);

*render_tetra_connector_flare(0);

*render_tetra_connector_lock(0);

*render_tetra_cable_flare(0);

// the whole body
*render_tetra_body(0, 10, 0);

// the whole microphone
// or use render_tetra_microphone_cutout(0, 0) for a "transparent" view
//
*render_tetra_microphone(0, 0, 0);

//// windscreen

*render_sphear_upper_windscreen(tetra_pcb_mount_height - 10 + windscreen_height);

*render_sphear_lower_windscreen(tetra_pcb_mount_height - 10);

*render_sphear_windscreen_thread_cover(tetra_pcb_mount_height - 10);

//// microphone shock mount

*render_tetra_shock_mount_stand(0);

*render_tetra_shock_mount_external_ring(0);

*render_tetra_shock_mount_internal_ring(0);

// the full mount
*render_tetra_shock_mount(12);

// individual capsule holders

*render_tetra_capsule_top(0);
