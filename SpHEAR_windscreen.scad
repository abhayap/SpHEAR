//
// Spherical Harmonics Ear Project (*SpHEAR)
//
// Windscreen modules
// 
// Copyright 2017, Fernando Lopez-Lezcano, All Rights Reserved
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

// number of helixes of windscreen frame
windscreen_sides = 12;

// radius of windscreen beams
windscreen_beam_radius = 1.3;

// radius of frame connectors
windscreen_conn_radius = windscreen_beam_radius + 0.8;

// height of connector pin
windscreen_pin_height = 4.0;


// windscreen frame

module sphear_windscreen_frame(sides, height, radius, beam_radius, twist) {
    inc = 360/sides;
    for (r = [0:inc:360]) for (t = [1, -1]) rotate([0, 0, r]) {
        render() {
            linear_extrude(height = height, center = false, convexity = 0, twist = twist * t, $fn = facets/2) {
                translate([radius, 0, 0]) {
                    circle(r = beam_radius, $fn = facets/2);
                }
            }
        }
    }
}

// windscreen tapered frame

module sphear_windscreen_tapered_frame(sides, height, radius, radius_h, beam_radius, twist) {
    echo(radius_h/radius);
    inc = 360/sides;
    for (r = [0:inc:360]) for (t = [1, -1]) rotate([0, 0, r]) {
        render() {
            linear_extrude(height = height, center = false, convexity = 0, twist = twist * t, scale = radius_h/radius, $fn = facets/2) {
                translate([radius, 0, 0]) {
                    circle(r = beam_radius, $fn = facets/2);
                }
            }
        }
    }
}

// windscreen inset frame

module sphear_windscreen_inset_frame(sides, height, radius, iradius, beam_radius, xscale = 1.0, yscale = 1.0) {
    inc = 360/sides;
    difference() {
        for (r = [0:inc:360]) for (t = [1, -1]) rotate([0, 0, r]) {
            render() {
                hull() {
                    translate([iradius, 0, 0]) {
                        scale([xscale, yscale, 1.0]) cylinder(r = beam_radius, h = thin_mint, $fn = facets / 2);
                    }
                    rotate([0, 0, inc/2 * t]) translate([radius, 0, height]) {
                        cylinder(r = beam_radius, h = thin_mint, $fn = facets / 2);
                    }
                }
            }
        }
        cylinder(r = iradius, h = height, $fn = facets);
    }
}

// windscreen frame reinforcements

module sphear_windscreen_frame_reinforcements(sides, radius, beam_radius, zrotation, yrotation) {
    for (r = [0:360/sides:360]) rotate([0, 0, r + zrotation]) {
        translate([radius, 0, 0]) {
            render() rotate([0, yrotation, 0]) intersection() {
                scale([1.0, 1.55, 1.0]) {
                    translate([0, 0, -beam_radius * 2]) {
                        cylinder(r = beam_radius, h = beam_radius * 4, $fn = facets);
                    }
                }
                scale([1, 2, 2.5]) sphere(r = beam_radius, $fn = facets);
            }
        }
    }
}

// windscreen dome

module sphear_windscreen_dome(sides, radius, beam_radius) {
    arcs = sides/2 - 1;
    ang = 360 / sides;
    difference() {
        for (r = [0, 90]) rotate([0, 0, r]) {
            for (t = [1, -1]) {
                translate([radius * sin(ang/2) * t, 0, 0]) rotate([0, 90, 0]) {
                    render() rotate_extrude(convexity = 10, $fn = facets) {
                        translate([radius * cos(ang/2), 0, 0]) {
                            circle(r = beam_radius, $fn = facets);
                        }
                    }
                }
                translate([radius * sin(ang/(2/3)) * t, 0, 0]) rotate([0, 90, 0]) {
                    render() rotate_extrude(convexity = 10, $fn = facets) {
                        translate([radius * cos(ang/(2/3)), 0, 0]) {
                            circle(r = beam_radius, $fn = facets);
                        }
                    }
                }
            }
        }
        brad = radius + 2 * beam_radius + thin_mint;
        translate([-brad, -brad, - 2 * brad]) {
            cube([2 * brad, 2 * brad, 2 * brad]);
        }
    }
}

// octagonal windscreen mount to body with thread

module sphear_windscreen_mount(height, radius, beam_radius) {
    octagon_radius = (radius + 2 * beam_radius + wall) * cos(PI/8);
    difference() {
        cylinder(r = radius + 2 * beam_radius + windscreen_thread_depth, h = height, $fn = facets);
        metric_thread(diameter = radius * 2 + windscreen_thread_fit, pitch = windscreen_thread_pitch,
                length = height, angle = windscreen_thread_angle, internal = true);
        // make outside be a octagon instead of a circle
        rotate([0, 0, 22.5]) translate([0, 0, -thin_mint]) {
            difference() {
                cylinder(r = 1.5 * radius, h = height + 2 * thin_mint);
                cylinder(r = octagon_radius, h = height + 2 * thin_mint, $fn = 8);
            }
        }
    }
    // marker for center of screen
    translate([-(radius + wall), 0, 0]) {
        cylinder(r = 1.0, h = height, $fn = facets);
    }
}

// round windscreen mount to body with thread

module sphear_windscreen_round_mount(height, radius, wradius, wall, knurl = false) {
    difference() {
        cylinder(r = radius + wall, h = height, $fn = facets);
        rotate([0, 0, -22.5/2]) metric_thread(diameter = radius * 2 + windscreen_thread_fit, pitch = windscreen_thread_pitch,
                length = height, angle = windscreen_thread_angle, internal = true);
    }
    // outer ring that attaches to windscreen
    difference() {
        union() {
            cylinder(r = wradius, h = height/2, $fn = facets);
            translate([0, 0, height/2]) {
                cylinder(r1 = wradius, r2 = radius + wall, h = height/2, $fn = facets);
            }
        }
        cylinder(r = radius + wall, h = height, $fn = facets);
        if (knurl) {
            for (r = [0:45/4:360]) rotate([0, 0, r]) {
                translate([radius + 2 * wall + 1.0 - 0.4, 0, 0]) scale([1.0, 1.5, 1]) cylinder(r = 2.0, h = height, $fn = facets);
            }
        }
    }
    // marker for center of microphone
    translate([-(wradius), 0, 0]) {
        cylinder(r = 1.0, h = height/2, $fn = facets);
    }
}

// round windscreen thread cover

module sphear_windscreen_thread_cover(height, radius, wall) {
    difference() {
        cylinder(r = radius + 2 * wall, h = height, $fn = facets);
        metric_thread(diameter = radius * 2 + windscreen_thread_fit, pitch = windscreen_thread_pitch,
                length = height + thin_mint, angle = windscreen_thread_angle, internal = true);
    }
    // smooth transition to flare
    *translate([0, 0, height/2]) {
        difference() {
            translate([0, 0, height/2]) {
                cylinder(r2 = radius - windscreen_thread_depth/2, r1 = radius + 2 * wall, h = height/3, $fn = facets);
            }
            cylinder(r2 = radius - windscreen_thread_depth, r1 = radius + wall, h = height, $fn = facets);
        }
    }
}

// upper windscreen frame

module sphear_upper_windscreen(sides, height, radius, beam_radius, conn_radius, pin_height, connectors = true) {
    ang = 360 / sides;
    // dome at top
    translate([0, 0, height]) {
        sphear_windscreen_dome(sides, radius, beam_radius);
    }
    // spiral wireframe
    translate([0, 0, 2]) {
        difference() {
            sphear_windscreen_frame(sides, height, radius, beam_radius, 45);
            if (connectors) {
                // remove bottom of beams to make space for the connectors
                for (r = [1:360/sides:360]) rotate([0, 0, r]) {
                    translate([radius, -beam_radius/2, 0]) {
                        cylinder(r = conn_radius, h = pin_height - 1.0, $fn = facets);
                    }
                }
            }
        }
    }
    if (connectors) {
        // connectors to lower frame
        for (r = [1:360/sides:360]) rotate([0, 0, r]) {
            translate([radius, -beam_radius/2, 0]) {
                difference() {
                    union() {
                        cylinder(r = conn_radius, h = pin_height + 1.0, $fn = facets);
                        translate([0, 0, pin_height + 1]) {
                            sphere(r = conn_radius, $fn = facets);
                        }
                    }
                    cylinder(r = beam_radius + fit, h = pin_height + 0.5, $fn = facets);
                }
            }
        }
        // bottom ring, prevents connectors to lower frame from toppling when printing
         difference() {
            scale([1.0, 1.0, 1.85]) rotate_extrude(convexity = 10, $fn = facets/2) {
                translate([radius, 0, 0]) {
                    circle(r = beam_radius * 1.25, $fn = facets/2);
                }
            }
            translate([0, 0, -4 * beam_radius]) {
                cylinder(r = radius + beam_radius * 1.25, h = 4 * beam_radius + thin_mint, $fn = facets/2);
            }
            for (r = [1:360/sides:360]) rotate([0, 0, r]) {
                translate([radius, -beam_radius/2, -2]) {
                        cylinder(r = conn_radius - thin_mint, h = 6.0 + thin_mint, $fn = facets/2);
                }
            }
        }
        // workaround for adhesion problems to the build plate (hack)
        // build a ring
        r_h = 0.4;
        difference() {
            cylinder(r = radius + 8 * wall, h = r_h, $fn = facets/2);
            translate([0, 0, -2*thin_mint]) cylinder(r = radius + 4 * wall, h = r_h + 4 * thin_mint, $fn = facets/2);
        }
        // and connect it to the windscreen
        for (r = [1:360/sides:360]) rotate([0, 0, r]) {
            translate([radius + conn_radius - beam_radius/2, -1, 0]) {
                    cube([4 * wall, 1, r_h]);
            }
        }
        for (r = [360/(sides*2):360/sides:360]) rotate([0, 0, r]) {
            translate([radius + wall, -1, 0]) {
                    cube([4 * wall, 1, r_h]);
            }
        }
    }
    // crossing reinforcements
    // first mid crossing
    translate([0, 0, height/3 + 2.0]) {
        sphear_windscreen_frame_reinforcements(sides, radius, beam_radius, ang/2, 0);
    }
    // second mid crossing
    translate([0, 0, height*2/3 + 2.0]) {
        sphear_windscreen_frame_reinforcements(sides, radius, beam_radius, 0, 0);
    }
    // to dome
    translate([0, 0, height + 2.0]) {
        sphear_windscreen_frame_reinforcements(sides, radius, beam_radius, ang/2, 0);
    }
}

// lower windscreen frame

module sphear_lower_windscreen(sides, height, radius, beam_radius, conn_radius, pin_height, connectors = true) {
    ang = 360 / sides;
    // frame
    rotate([0, 0, ang/2]) {
        sphear_windscreen_frame(sides, height, radius, beam_radius, 45);
    }
    // frame crossing reinforcements
    rotate([0, 0, ang/2]) {
        // first mid crossing
        translate([0, 0, height/3]) {
            sphear_windscreen_frame_reinforcements(sides, radius, beam_radius, ang/2, 0);
        }
        // second mid crossing
        translate([0, 0, height*2/3]) {
            sphear_windscreen_frame_reinforcements(sides, radius, beam_radius, 0, 0);
        }
    }
    // connector to upper frame
    for (r = [1:ang:360]) rotate([0, 0, r]) {
        translate([radius, -beam_radius/2, height - 1.0 + 0.4]) {
            render() {
                difference() {
                    sphere(r = conn_radius, $fn = facets);
                    translate([-2 * conn_radius, -2 * conn_radius, (beam_radius) / 2]) {
                        cube([4 * conn_radius, 4 * conn_radius, 4 * conn_radius]);
                    }
                }
                // pin
                cylinder(r = beam_radius - fit, h = pin_height, $fn = facets);
            }
        }
    }
    // mount to body
    sphear_windscreen_round_mount(windscreen_thread_height, windscreen_thread_radius, windscreen_radius, 2 * wall);
}

// lower windscreen frame with inset

module sphear_lower_tapered_windscreen(sides, height, radius, radius_h, beam_radius, conn_radius, pin_height, connectors = true) {
    ang = 360 / sides;
    // frame
    rotate([0, 0, ang/2]) {
        sphear_windscreen_tapered_frame(sides, height, radius, radius_h, beam_radius, 45);
    }
    // frame crossing reinforcements
    rotate([0, 0, ang/2]) {
        // first mid crossing
        translate([0, 0, height/3]) {
            sphear_windscreen_frame_reinforcements(sides, radius * (radius_h/radius*0.84), beam_radius, ang/2, 0);
        }
        // second mid crossing
        translate([0, 0, height*2/3]) {
            sphear_windscreen_frame_reinforcements(sides, radius * (radius_h/radius*0.92), beam_radius, 0, 0);
        }
    }
    // connector to upper frame
    for (r = [1:ang:360]) rotate([0, 0, r]) {
        translate([radius * (radius_h/radius), -beam_radius/2, height - 1.0 + 0.4]) {
            render() {
                difference() {
                    sphere(r = conn_radius, $fn = facets);
                    translate([-2 * conn_radius, -2 * conn_radius, (beam_radius) / 2]) {
                        cube([4 * conn_radius, 4 * conn_radius, 4 * conn_radius]);
                    }
                }
                // pin
                cylinder(r = beam_radius - fit, h = pin_height, $fn = facets);
            }
        }
    }
    // mount to body
    sphear_windscreen_round_mount(windscreen_thread_height, windscreen_thread_radius, windscreen_radius - 1.75, 2 * wall);
}

//
// Render components
//

// upper windscreen

module render_sphear_upper_windscreen(windscreen_radius, zoffset) {
    translate([0, 0, zoffset]) {
        sphear_upper_windscreen(windscreen_sides, windscreen_height, windscreen_radius,
            windscreen_beam_radius, windscreen_conn_radius, windscreen_pin_height, connectors = true);
    }
}

// lower windscreen

module render_sphear_lower_windscreen(windscreen_radius, zoffset) {
    translate([0, 0, zoffset]) {
        sphear_lower_windscreen(windscreen_sides, windscreen_height, windscreen_radius,
            windscreen_beam_radius, windscreen_conn_radius, windscreen_pin_height, connectors = true);
    }
}

// lower windscreen

module render_sphear_lower_tapered_windscreen(windscreen_radius_l, windscreen_radius_u, zoffset) {
    translate([0, 0, zoffset]) {
        sphear_lower_tapered_windscreen(windscreen_sides, windscreen_height, windscreen_radius_l, windscreen_radius_u,
            windscreen_beam_radius, windscreen_conn_radius, windscreen_pin_height, connectors = true);
    }
}

// windscreen thread cover

module render_sphear_windscreen_thread_cover(zoffset) {
    translate([0, 0, zoffset]) {
        sphear_windscreen_thread_cover(windscreen_thread_height, windscreen_thread_radius, wall);
    }
}
