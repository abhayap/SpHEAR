//
// Test Rig for Primo EM182 capsules
//
// Copyright 2015, Fernando Lopez-Lezcano, All Rights Reserved
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
//
// 3d Models released under the Creative Commons license as follows:
//   Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// http://creativecommons.org/licenses/by-nc-sa/4.0/

// dimensions of the EM182 electret microphone
capsule_radius = 5;
capsule_radius_i = 2.2;
capsule_height = 4.5;

// wall thickness of capsule holder
wall = 1;

// contact pads
pad_offset = 3.56;

// slot for contact
// contact_width = 0.85;
contact_width = 1.00;

// length of contact
contact_length = 2.9;

// depth of contact channel (includes contact)
// contact_depth = 0.79;
contact_depth = 0.5;

// island around contact
contact_border = 0.5;

// contact offset from center line
contact_offset = 0.3;

// cutout offset from edge of capsule
contact_cutout = 2.0;
contact_cutout_gnd = 2.5;

// support depth
disk_depth = 0.9;
disk_edge = 0.49;

// thinkness of sleeve
sleeve_edge = 0.66;

// adjustment for the inner radius of the capsule holder
//   measured inside diameter of a trial print was around 7.5 to 8.2 
//   instead of 10, capsule diameter was 9.99)
//   changed from 0.15 to 0.1 for tighter fit
fudge = 0.10;

// number of facets for rendering cylinders
facets = 128;

// one slot for a contact
module contact (trans, angle, cutout, slot = false) {
    rotate([0, 0, angle]) {
        translate(trans) {
            translate([- (contact_width + 2 * contact_border) / 2, 0, 0]) {
                if (slot == false) {
                    difference() {
                        // base for the contact
                        cube([contact_width + 2 * contact_border, capsule_radius + wall / 2, disk_depth]);
                        translate([contact_width / 2, 0, contact_depth]) {
                            // channel for clip
                            cube([contact_width, capsule_radius + wall / 2, disk_depth]);
                        }
                        // cutout for clip from edge of disk
                        translate([contact_width / 2, capsule_radius - cutout, 0]) {
                            cube([contact_width, contact_width, disk_depth]);
                            //cylinder(r = contact_width / 2 * 1.25, h = disk_depth, $fn = facets);
                        }
                    }
                } else {
                    // just the cutouts
                    translate([contact_width / 2, 0, contact_depth]) {
                        // channel for clip
                        cube([contact_width, capsule_radius + wall, disk_depth]);
                    }
                    translate([contact_width / 2, capsule_radius - cutout, 0]) {
                        cube([contact_width, contact_width, disk_depth]);
                        //cylinder(r = contact_width / 2 * 1.25, h = disk_depth, $fn = facets);
                    }
                }
            }
        }
    }
}

// main capsule holder
module capsule_holder () {
    difference() {
        cylinder(r = capsule_radius + wall, h = capsule_height, $fn = facets);
        cylinder(r = capsule_radius + fudge, h = capsule_height, $fn = facets);
    }
}

// back plate with contact springs
module backplate () {
    difference() {
        union() {
            difference() {
                union() {
                    cylinder(r = capsule_radius + wall, h = disk_edge, $fn = facets);
                    cylinder(r = capsule_radius, h = disk_depth, $fn = facets);
                }
                difference() {
                    cylinder(r = capsule_radius, h = disk_depth, $fn = facets);
                    cylinder(r = capsule_radius_i, h = disk_depth, $fn = facets);
                }
            }
            // contacts
            contact([contact_border + contact_offset, 0, 0], 0, contact_cutout);
            contact([-contact_border - contact_offset, 0, 0], 0, contact_cutout);
            // GND contact
            contact([- contact_border - contact_offset, 0, 0], 90, contact_cutout_gnd);
            // one more radial connection
            rotate([0, 0, -120]) {
                translate([-contact_width / 2, 0, 0]) {
                    cube([contact_width, capsule_radius, disk_depth]);
                }
            }
        }
        // contact cutouts
        contact([contact_border + contact_offset, 0, 0], 0, contact_cutout, true);
        contact([-contact_border - contact_offset, 0, 0], 0, contact_cutout, true);
        // contact cutout for GND
        contact([- contact_border - contact_offset, 0, 0], 90, contact_cutout_gnd, true);
        // finally trim the seat for the holder
        translate([0, 0, disk_edge]) {
            difference() {
                cylinder(r = capsule_radius + wall, h = disk_depth, $fn = facets);
                cylinder(r = capsule_radius, h = disk_depth, $fn = facets);
            }
        }
    }
}

stalk_height = 12.0;

sleeve_height = capsule_height * 2 / 3;

// sleeve that holds everything together
module sleeve () {
    difference() {
        cylinder(r = capsule_radius + 2 * wall, h = sleeve_height, $fn = facets);
        cylinder(r = capsule_radius + wall, h = sleeve_height, $fn = facets);
    }
    difference() {
        cylinder(r = capsule_radius + wall, h = sleeve_edge, $fn = facets);
        cylinder(r = capsule_radius, h = sleeve_edge, $fn = facets);
    }
    // back plate for contacts 1 / 2
    translate([-(contact_width + 1.5 * contact_border) + 0.1, capsule_radius / 2 - 0.1, 0]) {
        cube([(contact_width + 1.5 * contact_border) * 2 - 0.2, capsule_radius / 2 + 0.1, sleeve_edge]);
    }
    // back plate for GND contact
    rotate([0, 0, 90]) {
        translate([-(contact_width + 1.5 * contact_border), capsule_radius * 1 / 3, 0]) {
            cube([(contact_width + 1.5 * contact_border), capsule_radius * 2 / 3, sleeve_edge]);
        }
    }
    // mount stalk
    translate([-sleeve_height / 2, -(capsule_radius + wall), sleeve_height]) {
        rotate([90, 90, 0]) {
            cube([sleeve_height, sleeve_height, stalk_height + sleeve_height]); 
        }
    }
    // lever to rotate capsule between 0 and 90 degrees
    translate([sleeve_height / 2, - (capsule_radius + wall + stalk_height), 0]) {
        rotate([0, 0, 0]) {
            cube([capsule_height * 2, sleeve_height, sleeve_height]);
        }
    }
}

// mount that clips on a standard microphone stand

// dimensions of microphone holder
mount_radius = 2.75;
mount_wall = 0.75;

// height of mount
mount_height = 40;

// microphone stand mount
//
// diameter of existing shielded wires (x 4)
mic_wire_diam = 1.5;
mic_wire_hole_radius = 2.5;
mic_wire_hole_offset = 5;

// measured diameter = 13.5, inside diameter of sleeve = 13.79 (
mic_mount_radius = 13.50 / 2;
// add this to inside diameter
mic_mount_fit = 0.1;
mic_mount_slot_height = 11.5;
mic_mount_slot_width = 4.25;
mic_mount_slot_radius = 6.25  / 2;
mic_mount_wall = 1.5;
mic_mount_height = 35.0 + mic_wire_hole_offset + mic_wire_hole_radius + 2 * mic_mount_wall;

module mount (wall, stand_wall, separation) {
    translate([0, 0, -separation]) {
        difference() {
            union() {
                // stalk
                translate([0, 0, mic_mount_height + mount_height * 2/3]) {
                    difference() {
                        cylinder(r = mount_radius + wall, h = mount_height / 3, $fn = facets);
                        // make the hole for the mount
                        cylinder(r = mount_radius, h = mount_height / 3, $fn = facets);
                    }
                }
                // transition to stand mount
                *translate([0, 0, mic_mount_height]) {
                    difference() {
                        cylinder(r2 = mount_radius + wall, r1 = mic_mount_radius + mic_mount_fit + stand_wall, 
                                h = mount_height * 2 / 3, $fn = facets);
                        // make the hole for the mount
                        cylinder(r2 = mount_radius, r1 = mic_mount_radius + mic_mount_fit, 
                                h = mount_height * 2 / 3, $fn = facets);
                    }
                }
                // stand mount
                *translate([0, 0, 0]) {
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
                    }
                }
            }
            // cut slot for detente at the top of the mount
            translate([- sleeve_height / 2, - sleeve_height / 2, mic_mount_height + mount_height - sleeve_height / 2]) {
                cube([2 * mount_radius + wall, 2 * mount_radius + wall, sleeve_height / 2]);
            }
        }
    }
}


tab_width = 3.0;
tab_length = 3.0;

module mount_cap (wall, separation) {
    translate([0, 0, -(separation)]) {
        difference() {
            union() {
                // cap
                cylinder(r = mount_radius + wall, h = 3 * wall, $fn = facets);
                translate([0, 0, - 2 * wall]) {
                    cylinder(r = mount_radius + mic_mount_fit, h = 3 * wall, $fn = facets);
                }
            }
            // hole in the center
            *translate([0, 0, - 2 * wall]) {
                cylinder(r = sleeve_height / 2, h = 6 * wall, $fn = facets);
            }
            // slot for detente
            translate([- sleeve_height / 2, - sleeve_height / 2, 2 * wall]) {
                cube([2 * mount_radius + wall, 2 * mount_radius + wall, wall]);
            }
        }
    }
}

// stalk: measured in print: 2.86 - 2.87
// hole: measured: 2.63 - 2.68
//   so need a fit of 2.87 - 2.68 / 2 = 0.095 ~ 0.1 (hole should be bigger by this amount)
square_fit = 0.1;

// mount tube: measured 7.1 (average)
// skirt inner diameter: 6.88
//   fit: 7.1 - 6.88 / 2 = 0.11 ~ 0.1 too tight, 0.25 too lose
mount_fit = 0.2;

module mount_adapter(wall, separation) {
    difference() {
        union() {
            translate([0, 0, -separation]) {
                difference() {
                    cylinder(r = mount_radius + 2 * wall + mount_fit, h = 3 * wall, $fn = facets);
                    // hole for square peg
                    hole_side = sleeve_height + square_fit * 2;
                    translate([-hole_side / 2, -hole_side / 2]) {
                        cube([hole_side, hole_side, hole_side]);
                    }
                }
            }
            // skirt that grabs the mount and allows the holder to rotate
            translate([0, 0, - 5 * wall]) {
                difference() {
                    cylinder(r = mount_radius + 2 * wall + mount_fit, h = 5 * wall, $fn = facets);
                    cylinder(r = mount_radius + wall + mount_fit, h = 5 * wall, $fn = facets);
                }
            }
            // tab to stop rotation at 0 and 90 degrees
            translate([sleeve_height * 3 / 2, - sleeve_height / 2, - sleeve_height / 2]) {
                rotate([0, -90, 0]) {
                    cube([sleeve_height, sleeve_height, sleeve_height]);
                }
            }
        }
        // clip the outside...
        translate([0, 0, -2 * wall]) {
            difference() {
                cylinder(r = mount_radius + 4 * wall + mount_fit, h = 4 * wall, $fn = facets);
                cylinder(r = mount_radius + 2 * wall + mount_fit, h = 4 * wall, $fn = facets);
            }
        }
    }
}

////

printset = 1;

if (printset == 1) {

    // adapter
    rotate([0, 180, 0]) {
        translate([0, 0, - sleeve_height + sleeve_height / 4]) {
            mount_adapter(mount_wall, 0);
        }
    }
    // sleeve
    *translate([- sleeve_height / 2, 15, 0]) {
        rotate([0, 0, 90]) {
            sleeve();
        }
    }
    // backplate
    *translate([15, 0, 0]) {
        backplate();
    }
    // mount (test)
    *translate([12, 0, -(mic_mount_height + mount_height - mount_height / 3)]) {
        mount(mount_wall, mic_mount_wall);
    }
    
} else {

translate([0, 0, -(mic_mount_height + mount_height + capsule_radius + 2 * wall + 2.2 * stalk_height)]) {
    mount(mount_wall, mic_mount_wall);
}

rotate([0, 0, 90]) {
    translate([0, 0, -2.2 * stalk_height]) {
        mount_adapter(mount_wall, 0);
    }
}

*translate([0, 0, - 2.7 * stalk_height]) {
    mount_cap(mount_wall, 0);
}

translate([- sleeve_height / 2, 0, 0]) {
    rotate([90, 0, 90]) {
        sleeve();
    }
}

*backplate();

translate([capsule_radius * 3.0, capsule_radius * 3, 0]) {
    rotate([90, 0, 0]) {
        capsule_holder();
    }
}

}
