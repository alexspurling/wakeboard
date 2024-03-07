use <MCAD/boxes.scad>
$fa=1;
$fs=0.4;


inner_width = 31;
inner_length = 59;
inner_height = 13.2;
pcb_height = 11.2;

battery_length = 50;

wall_thickness = 2.6;

outer_width = inner_width + wall_thickness * 2;
outer_length = inner_length + wall_thickness * 2;
outer_height = inner_height + wall_thickness;


bevel_radius = 0.5;

lip_thickness = 1.3;

support_width = 20;
support_radius = 4.5;


module box(width, length, height, radius, bevel_radius=0) {
    difference() {
        minkowski() {
            sphere(bevel_radius);
            hull() {
                translate([radius + bevel_radius, radius + bevel_radius, bevel_radius]) cylinder(height, radius, radius);
                translate([width - radius - bevel_radius, radius + bevel_radius, bevel_radius]) cylinder(height, radius, radius);
                translate([width - radius - bevel_radius, length - radius - bevel_radius, bevel_radius]) cylinder(height, radius, radius);
                translate([radius + bevel_radius, length - radius - bevel_radius, bevel_radius]) cylinder(height, radius, radius);
            }
        }
        translate([0, 0, height + bevel_radius]) cube([width, length, bevel_radius]);
    }
}

module box_with_lip(inner_width, inner_length, inner_height, radius, wall_thickness, bevel_radius) {
    
    outer_width = inner_width + wall_thickness * 2;
    outer_length = inner_length + wall_thickness * 2;
    outer_height = inner_height + wall_thickness;
    
    difference() {
        // outer box
        union() {
            box(outer_width, outer_length, outer_height, 5, bevel_radius);
            // lip
            translate([wall_thickness - lip_thickness, wall_thickness - lip_thickness, outer_height + bevel_radius])
            box(inner_width + lip_thickness * 2, inner_length + lip_thickness * 2, lip_thickness, 4, 0);
        }
        
        // inner cutout
        translate([wall_thickness, wall_thickness, wall_thickness + bevel_radius])
        box(inner_width, inner_length, outer_height + 0.1, 3, 0);
    }
}

module usb_hole(xpos, ypos, zpos) {
    usb_hole_width = 9.2;
    translate([xpos - usb_hole_width / 2, ypos, zpos])
    cube([usb_hole_width, 5, 5]);
}

difference () {
    box_with_lip(inner_width, inner_length, inner_height, 5, wall_thickness, bevel_radius);
    usb_hole(outer_width / 2, 0, inner_height + wall_thickness + bevel_radius);
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

translate([outer_width / 2 - support_width / 2, wall_thickness, wall_thickness + bevel_radius])
support(support_radius, 20, pcb_height);

translate([outer_width / 2 + support_width / 2, wall_thickness + inner_length, wall_thickness + bevel_radius])
rotate([0, 0, 180])
support(support_radius, 20, pcb_height);