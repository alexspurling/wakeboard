use <MCAD/boxes.scad>
$fa=1;
$fs=0.4;


inner_width = 31;
inner_length = 59;
wall_thickness = 2;

outer_width = inner_width + wall_thickness * 2;
outer_length = inner_length + wall_thickness * 2;
height = 13.2;

bevel_radius = 0.5;

lip_thickness = 1;


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

module box_with_lip(inner_width, inner_length, height, radius, wall_thickness=2, bevel_radius=0) {
    
    outer_width = inner_width + wall_thickness * 2;
    outer_length = inner_length + wall_thickness * 2;
    
    difference() {
        // outer box
        union() {
            box(outer_width, outer_length, height, 5, bevel_radius);
            translate([1, 1, height + bevel_radius])
            box(inner_width + lip_thickness * 2, inner_length + lip_thickness * 2, lip_thickness, 4, 0);
        }
        
        // inner cutout
        translate([2, 2, 2])
        box(inner_width, inner_length, height, 3, 0);
    }
}

box_with_lip(inner_width, inner_length, height, 5, wall_thickness, bevel_radius);