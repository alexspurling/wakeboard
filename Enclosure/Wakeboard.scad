use <MCAD/boxes.scad>
$fa=1;
$fs=0.4;

import("WakeboardPCB.amf", convexity=3);


inner_width = 34;
inner_length = 59;
inner_height = 13.2;

pcb_width = 30.6;
pcb_length = 58.6;
pcb_height = 1.6;

battery_width = 34.6;
battery_length = 49.6;
battery_height = 11.3;

wall_thickness = 2.6;

outer_width = inner_width + wall_thickness * 2;
outer_length = inner_length + wall_thickness * 2;
outer_height = inner_height + wall_thickness;

outer_radius = 5;
bevel_radius = 0.5;

lip_thickness = 1.3;

support_width = 16;
support_height = 11.6;
support_radius = 4.5;

magnet_radius = 2.5;
magnet_height = 4;


module roundedBox(w, l, h, r) {
    translate([r, r, 0]) cylinder(h, r, r);
    translate([w - r, r, 0]) cylinder(h, r, r);
    translate([w - r, l - r, 0]) cylinder(h, r, r);
    translate([r, l - r, 0]) cylinder(h, r, r);
    
    translate([0, r, 0])
    cube([w, l - 2 * r, h]);
    
    translate([r, 0, 0])
    cube([w - 2 * r, l, h]);
}

module box(w, l, h, r, br=0) {
    if (br > 0) {
        hull() {
            translate([r, r, br])
            rotate_extrude(angle=90, convexity=2)
            translate([-r + br, 0]) circle(br);

            translate([w - r, r, br])
            rotate([0, 0, 90])
            rotate_extrude(angle=90, convexity=2)
            translate([-r + br, 0]) circle(br);

            translate([w - r, l - r, br])
            rotate_extrude(angle=90, convexity=2)
            translate([r - br, 0]) circle(br);

            translate([r, l - r, br])
            rotate([0, 0, 90])
            rotate_extrude(angle=90, convexity=2)
            translate([r - br, 0]) circle(br);
        }
    }

    translate([0, 0, br])
    roundedBox(w, l, h, r);
}

module box_with_lip(inner_width, inner_length, inner_height, radius, wall_thickness, bevel_radius) {
    
    outer_width = inner_width + wall_thickness * 2;
    outer_length = inner_length + wall_thickness * 2;
    outer_height = inner_height + wall_thickness;
    
    difference() {
        // outer box
        union() {
            box(outer_width, outer_length, outer_height, radius, bevel_radius);
            // lip
            translate([wall_thickness - lip_thickness, wall_thickness - lip_thickness, outer_height + bevel_radius])
            box(inner_width + lip_thickness * 2, inner_length + lip_thickness * 2, lip_thickness, radius - wall_thickness + lip_thickness, 0);
        }
        
        // inner cutout
        translate([wall_thickness, wall_thickness, wall_thickness + bevel_radius])
        box(inner_width, inner_length, outer_height + 0.1, radius - wall_thickness, 0);
    }
}

module usb_hole(xpos, ypos, zpos) {
    usb_hole_width = 9.2;
    translate([xpos - usb_hole_width / 2, ypos, zpos])
    cube([usb_hole_width, 5, 5]);
}

module fillet(radius, height) {
    linear_extrude(height=height)
    difference() {
        square([radius, radius]);
        translate([radius, radius])
        circle(radius);
    }
}

module support(radius, width, height) {
    r2 = radius / 2;
    rotate([0, 0, 90])
    fillet(r2, height);
    translate([width, 0])
    fillet(r2, height);
    
    hull() {
        translate([r2, r2])
        cylinder(height, r2, r2);
        translate([width-r2, r2])
        cylinder(height, r2, r2);
        cube([width, r2, height]);
    }
}

module supports() {
    translate([outer_width / 2 - (support_width / 2), wall_thickness, wall_thickness + bevel_radius])
    support(support_radius, support_width, support_height);

    translate([outer_width / 2 + (support_width / 2), wall_thickness + inner_length, wall_thickness + bevel_radius])
    rotate([0, 0, 180])
    support(support_radius, support_width, support_height);
}

supports();

module battery() {
    color([0.5, 0.5, 0.5, 0.9])
    translate([wall_thickness + 0.2, wall_thickness + support_radius + 0.2, wall_thickness + bevel_radius])
    % cube([battery_width, battery_length, battery_height]);
}

battery();


module magnet_holes() {
    mhr = magnet_radius + 0.1; // magnet hole radius
    h = magnet_height * 1.5;
    xoffset = 2;
    yoffset = -0.5;
    translate([outer_radius + xoffset, outer_radius + yoffset, lip_thickness])
    cylinder(h, mhr, mhr);
    translate([outer_width - outer_radius - xoffset, outer_radius + yoffset, lip_thickness])
    cylinder(h, mhr, mhr);
    translate([outer_radius + xoffset, outer_length - outer_radius - yoffset, lip_thickness])
    cylinder(h, mhr, mhr);
    translate([outer_width - outer_radius - xoffset, outer_length - outer_radius - yoffset, lip_thickness])
    cylinder(h, mhr, mhr);
}


module case() {
    difference () {
        box_with_lip(inner_width, inner_length, inner_height, outer_radius, wall_thickness, bevel_radius);
        usb_hole(outer_width / 2, 0, inner_height + wall_thickness + bevel_radius);
        magnet_holes();
    }
}

case();

module pcb() {
    //translate([outer_width / 2 - pcb_width / 2, outer_length / 2 - pcb_length / 2, wall_thickness + bevel_radius + support_height])
    
    r = 3;
    cutout_width = 15.4;
    cutout_length = 4.5;
    
    color([0.5, 0.9, 0.5, 0.7])
    translate([outer_width / 2 - pcb_width / 2, outer_length / 2 - pcb_length / 2, wall_thickness + bevel_radius + support_height])
    difference () {
        roundedBox(pcb_width, pcb_length, pcb_height, r);
        
        translate([pcb_width / 2 - cutout_width / 2, pcb_length - cutout_length + 0.05, -0.05])
        cube([cutout_width, cutout_length + 0.1, pcb_height + 0.1]);
    }
}

pcb();
