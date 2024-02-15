//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// Octathingy, Second Order Ambisonics Microphone
//
// based on:
// "A second-order soundfield microphone with improved polar pattern shape"
// by Eric Benjamin, Audio Engineering Society Convention Paper 8728, 
// October 2012, San Francisco
//
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

include <Octathingy_common.scad>;
include <Octathingy_mount_pcb.scad>;

// dimensions of the electret microphone capsule
capsule_radius = 5;
capsule_height = 4.5;
mic_radius = 13.5;

// make triangular legs have the right height
connect = 1;
leg_thick = capsule_height * 0.45;

////
//// render the different assemblies
////

//// microphone body and array

*render_octa_capsule_array(0);

*render_octa_capsule_flare(0);

*render_octa_pcb_mount(0, 0);

*render_octa_cable_flare(0);

// the whole body
*render_octa_body(0, 10, 0);

// the whole microphone
// or use render_octa_microphone_cutout(0, 0) for a "transparent" view
//
*render_octa_microphone_cutout(0, 0, 0);

//// microphone shock mount

*render_octa_shock_mount_stand(0);

*render_octa_shock_mount_external_ring(0);

*render_octa_shock_mount_internal_ring_bot(0);

*render_octa_shock_mount_internal_ring_top(0);

*render_octa_shock_mount_ring_connectors(5);

// the full mount at the right height to render with the microphone
*render_octa_shock_mount(-3);

// individual capsule holders

*render_octa_capsule_top(0);

*render_octa_capsule_bot(0);
