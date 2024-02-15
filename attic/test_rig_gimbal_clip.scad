/*-------------------------------------------------
        [Gimbal Mic Clip] 
        Author: Wisam Reid 
  ------------------------------------------------- */ 
/*
Flags 
*/
render_clip = 1;
render_gimbal_bracket = 1;
render_capsule_holder = 1;


// number of facets
$fn=64;

// Build Test Rig
test_rig(20,20,20,1,10,1,5, 0.25, 0.15);

module test_rig (diameter_clip, diameter_gimbal, clip_depth, taper_ratio, capsule_size,center_thickness, thickness, gimbal_spacing, pin_spacing) {
    translate([((thickness) + center_thickness)/2,0,0]) {
      // CAPSULE HOLDER
      difference(){ // cutout center for capsule
            // outer part of mic clip
            union(){ // unite pin and capsule holder
                translate([-(clip_depth + (diameter_gimbal/2)),0,0]){
                        intersection() { // intersect with sphere for rounded edges
                            sphere(r=((capsule_size/2)+thickness)- gimbal_spacing, center=true);
                            cylinder(r=((capsule_size/2)+thickness) - gimbal_spacing, h=thickness, center=true);
                        }
                }
                // pin
                rotate([90,0,0]){
                        translate([-(clip_depth + (diameter_gimbal/2)),0,0]){
                            cylinder(d=(thickness/2) - pin_spacing,h=diameter_gimbal + (thickness/2) - pin_spacing,center=true);
                        }
                }
             }
            rotate([90,0,0]){
                translate([-(clip_depth + (diameter_gimbal/2)),0,0]){
                    rotate(v=[0,0,1], a=45){
                        cube(size=[(thickness/4), (thickness/4),diameter_gimbal + (thickness/2) - (pin_spacing*2)],center=true);
                    }
                }
            }
            // inner cutout for gimbal
            translate([-(clip_depth + (diameter_gimbal/2)),0,0]){
                cylinder(d=capsule_size,h=diameter_clip, center=true);
            }
        }
            
        // GIMBAL BRACKET
        difference(){ // cut gimbal pinhole and inner mic clip radius
            union(){ // unite gimbal bracket with mic clip
           
              translate([-(thickness/(taper_ratio/2)),0,0]){
                    difference(){ // cutout inner part of gimbal bracket
                        intersection(){ // intersect with sphere for rounded edges
                            hull(){ // convex hull of spheres
                                translate([-2*clip_depth,0,0]){
                                    sphere(r=(diameter_gimbal/taper_ratio)-thickness, center=true);  
                                }
                                sphere(r=(diameter_gimbal/taper_ratio)-2*thickness, center=true);  
                            } 
                            hull(){ // outer part of gimbal bracket
                                translate([-clip_depth,0,0]){
                                    cylinder(d=diameter_gimbal+thickness,h=thickness, center=true);
                                }
                                cylinder(d=diameter_gimbal/taper_ratio,h=thickness, center=true);
                            }
                        }
                        hull(){ // inner cutout for gimbal bracket
                            translate([-clip_depth,0,0]){
                                cylinder(d=diameter_gimbal,h=thickness, center=true);
                            }
                            translate([-(center_thickness+thickness),0,0]){
                                cylinder(d=(diameter_gimbal/taper_ratio) - thickness,h=thickness,center=true);
                            }
                        }
                        // C-shape cutout
                        translate([-(diameter_gimbal+clip_depth)+(thickness/(taper_ratio/2)),0,-thickness/2]){
                            rotate([0,0,45]){
                                cube([diameter_gimbal,diameter_gimbal,2*thickness],center=true);
                            }
                        }
                    } 
                }
                if (render_clip)
                    // MIC CLIP 
                    rotate([0,0,180]){
                        translate([thickness/2,0,0]){
                            difference(){ // cutout inner part of mic clip
                                // outer part of mic clip
                                translate([-(diameter_clip+thickness)/2,0,0]){
                                    rotate([0,0,180]){
                                        intersection() { // intersect with sphere for rounded edges
                                            sphere(r=diameter_clip-thickness, center=true);
                                            cylinder(r=diameter_clip-thickness, h=thickness, center=true);
                                        }
                                        // cylinder(d=diameter_clip+thickness,h=thickness, center=true);
                                    }
                                }
                                // cut clip opening 
                                translate([-(diameter_clip*1.5),-(diameter_clip/1.4),-(diameter_clip*3)]){
                                    rotate([0,0,45]){
                                        cube([diameter_clip,diameter_clip,6*diameter_clip]);
                                    }
                                }     
                            }
                        }
                    }
                // gimbal rotation stopper    
                intersection(){ // intersect with sphere for rounded edges
                    hull(){ // convex hull of spheres
                        translate([-2*clip_depth,0,0]){
                            sphere(r=(diameter_gimbal/taper_ratio)-thickness, center=true);  
                        }
                        sphere(r=(diameter_gimbal/taper_ratio)-2*thickness, center=true);  
                    }
                    // rotation stopper
                    rotate([90,0,0]){
                        translate([-(clip_depth + (diameter_gimbal/2)) + (thickness/4),thickness/2 + thickness/15,(diameter_gimbal + (thickness/2))/2 - ((0.8*thickness) /3)]){
                            union(){ // create small hold off
                                rotate([0,5,0]){
                                    cube([(thickness/2),(thickness/10),0.8*thickness], center=true);        
                                    translate([0,-thickness/40,0.2*thickness]){ // offset
                                        cube([(thickness/2),(thickness/10),0.4*thickness], center=true);
                                    }
                                }
                            }
                        }
                    } 
                }
            }
                
            // CUT OUTS   
            // inner cutout for mic clip
            translate([diameter_clip/2,0,0]){
                cylinder(d=diameter_clip,h=diameter_clip, center=true);
            }
          
            // gimbal pin hole
            translate([-(clip_depth + (diameter_gimbal/2)),0,0]){            
                rotate([90,0,0]){
                    cylinder(d=thickness/2,h=diameter_gimbal + (thickness/2), center=true);
                }
            }
        }
    }
}