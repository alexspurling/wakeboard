use <MCAD/boxes.scad>
$fa=1;
$fs=0.2;


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

base = wall_thickness + bevel_radius;

lip_thickness = 1.3;
lip_height = 2;

support_width = 9.5;
support_height = 11.6;
support_radius = 4.5;

magnet_radius = 2.5;
magnet_height = 4;

battery_socket_width = 7.4;
battery_socket_length = 7.9;
battery_socket_height = 5.5;

battery_socket_x = (outer_width / 2 - pcb_width / 2) + 4.8;
battery_socket_y = (outer_length / 2 - pcb_length / 2) + 9;

slot_depth = 1;
slot_width = 2;
slot_height = support_height + 1;

lid_height = 8;
lid_inner_height = lid_height - wall_thickness;

usb_hole_width = 9.1;
usb_hole_height = 3.5;

tab_width = 10;
tab_height = lip_height - 0.4;


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
            box(inner_width + lip_thickness * 2, inner_length + lip_thickness * 2, lip_height, radius - wall_thickness + lip_thickness, 0);
        }
        
        // inner cutout
        translate([wall_thickness, wall_thickness, base])
        box(inner_width, inner_length, outer_height + 0.1, radius - wall_thickness, 0);
        
        recess_width = outer_width - 15;
        recess_length = outer_length - 15;
        recess_height = 0.15;
        recess_radius = 2;
        // bottom recess
        translate([outer_width / 2 - recess_width / 2, outer_length / 2 - recess_length / 2, -0.05])
        box(recess_width, recess_length, recess_height, recess_radius, 0);
        
        // cutout for tab slot left
        translate([wall_thickness - lip_thickness -0.05, outer_length / 2 - tab_width / 2, outer_height + bevel_radius])
        cube([lip_thickness + 0.1, tab_width, lip_height]);
        
        // cutout for tab slot right
        translate([outer_width - wall_thickness -0.05, outer_length / 2 - tab_width / 2, outer_height + bevel_radius])
        cube([lip_thickness + 0.1, tab_width, lip_height]);
        
        // cutout for tab slot back
        translate([outer_width / 2 - tab_width / 2, outer_length - wall_thickness - 0.05, outer_height + bevel_radius])
        cube([tab_width, lip_thickness + 0.1, lip_height]);
    }
    
    // tab slot left
    translate([wall_thickness - lip_thickness, outer_length / 2 + tab_width / 2, outer_height + bevel_radius])
    rotate([0, 0, 270])
    tab_slot(tab_width, tab_height);
    
    // tab slot right
    translate([outer_width - wall_thickness + lip_thickness, outer_length / 2 - tab_width / 2, outer_height + bevel_radius])
    rotate([0, 0, 90])
    tab_slot(tab_width, tab_height);
    
    // tab slot back
    translate([outer_width / 2 + tab_width / 2, outer_length - wall_thickness + lip_thickness, outer_height + bevel_radius])
    rotate([0, 0, 180])
    tab_slot(tab_width, tab_height, 0);
    
    supports();
}

module usb_hole(xpos, ypos, zpos) {
    translate([xpos - usb_hole_width / 2, ypos, zpos])
    cube([usb_hole_width, 5, usb_hole_height]);
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

/*
module supports() {
    translate([outer_width - 10, wall_thickness, base])
    support(support_radius, support_width, support_height);

    translate([outer_width / 2 + (support_width / 2), wall_thickness + inner_length, base])
    rotate([0, 0, 180])
    support(support_radius, support_width, support_height);
}
*/

module supports() {
    translate([wall_thickness, wall_thickness, base])
    cube([support_width, support_radius, support_height]);
    
    translate([outer_width - wall_thickness - support_width, wall_thickness, base])
    cube([support_width, support_radius, support_height]);
    
    translate([wall_thickness, outer_length - wall_thickness - support_radius, base])
    cube([support_width, support_radius, support_height]);
    
    translate([outer_width - wall_thickness - support_width, outer_length - wall_thickness - support_radius, base])
    cube([support_width, support_radius, support_height]);
}

module battery() {
    color([0.5, 0.5, 0.5, 0.9])
    translate([wall_thickness + 0.2, wall_thickness + support_radius + 0.2, base])
    cube([battery_width, battery_length, battery_height]);
}


module magnet_hole() {
    mhr = magnet_radius + 0.1; // magnet hole radius
    h = magnet_height * 2;
    xoffset = 2;
    yoffset = -0.5;
    
    translate([0, 0, -lip_thickness])
    cylinder(h, mhr, mhr);
    translate([0, 0, h - lip_thickness])
    sphere(mhr);
    translate([0, 0, h - lip_thickness])
    rotate([90, 0, 0])
    cylinder(mhr * 1.5, mhr, mhr);
    translate([-mhr, -mhr * 1.5, 0])
    cube([mhr * 2, mhr * 1.5, h - lip_thickness]);
}


module magnet_holes() {
    mhr = magnet_radius + 0.1; // magnet hole radius
    h = magnet_height * 2;
    xoffset = 2;
    yoffset = -0.5;
    
    translate([outer_radius + xoffset, outer_radius + yoffset, base])
    rotate([0, 0, 180])
    magnet_hole();
    
    translate([outer_width - outer_radius - xoffset, outer_radius + yoffset, base])
    rotate([0, 0, 180])
    magnet_hole();
    
    translate([outer_radius + xoffset, outer_length - outer_radius - yoffset, base])
    magnet_hole();
    
    translate([outer_width - outer_radius - xoffset, outer_length - outer_radius - yoffset, base])
    magnet_hole();
}

module battery_wire_slot() {
    translate([wall_thickness - slot_depth, battery_socket_y + battery_socket_length / 2 - slot_width / 2, base])
    cube([slot_depth + 0.2, slot_width, slot_height]);
}


module case() {
    difference () {
        box_with_lip(inner_width, inner_length, inner_height, outer_radius, wall_thickness, bevel_radius);
        usb_hole(outer_width / 2, 0, inner_height + base + 0.01);
        magnet_holes();
        battery_wire_slot();
    }
    mhr = magnet_radius + 0.1; // magnet hole radius
    h = magnet_height * 1.5;
    xoffset = 2;
    yoffset = -0.5;
}

module pcb() {
    //translate([outer_width / 2 - pcb_width / 2, outer_length / 2 - pcb_length / 2, base + support_height])
    
    r = 3;
    cutout_width = 15.4;
    cutout_length = 4.5;
    
    color([0.5, 0.9, 0.5, 0.5])
    translate([outer_width / 2 - pcb_width / 2, outer_length / 2 - pcb_length / 2, base + support_height])
    difference () {
        roundedBox(pcb_width, pcb_length, pcb_height, r);
        
        translate([pcb_width / 2 - cutout_width / 2, pcb_length - cutout_length + 0.05, -0.05])
        cube([cutout_width, cutout_length + 0.1, pcb_height + 0.1]);
    }
    
    translate([
        (outer_width / 2 - pcb_width / 2) + 4.8, 
        (outer_length / 2 - pcb_length / 2) + 9, 
        base + support_height + pcb_height
    ])
    cube([battery_socket_width, battery_socket_length, battery_socket_height]);
}



module lid() {    
    lid_lip_thickness = lip_thickness - 0.1;
    tab_clearance = 0.15;
    
    // translate([0, 0, outer_height + 5])
    translate([-5, 0, lid_height + bevel_radius])
    rotate([0, 180, 0])
    union() {
        difference() {
            rotate([0, 180, 0])
            translate([-outer_width, 0, -lid_height-bevel_radius])
            box(outer_width, outer_length, lid_height, outer_radius, bevel_radius);
        
            // lip
            translate([lid_lip_thickness, lid_lip_thickness, -0.1])
            box(outer_width - lid_lip_thickness * 2, outer_length - lid_lip_thickness * 2, lip_height, outer_radius - lid_lip_thickness);
            
            // Inner cutout
            translate([wall_thickness, wall_thickness, lip_thickness - 0.1])
            box(outer_width - wall_thickness * 2, outer_length - wall_thickness * 2, lid_inner_height + 0.1, outer_radius - wall_thickness);
            
            // USB hole
            usb_hole(outer_width / 2, -0.1, -0.05);
            
            // Logo
            translate([12, outer_length - wall_thickness - 1, lid_height])
            rotate([0, 0, 270])
            scale([0.65, 0.65, 1])
            linear_extrude(0.51)
            import("LogoNoVersion2.svg");
        }
        
        // Tab left
        translate([lid_lip_thickness - tab_clearance, outer_length / 2 + tab_width / 2, 0])
        rotate([0, 0, 270])
        tab(tab_width, tab_height);
        
        // Tab right
        translate([outer_width - lid_lip_thickness + tab_clearance, outer_length / 2 - tab_width / 2, 0])
        rotate([0, 0, 90])
        tab(tab_width, tab_height);
        
        // Tab back
        translate([outer_width / 2 + tab_width / 2, outer_length - lid_lip_thickness + tab_clearance, 0])
        rotate([0, 0, 180])
        tab(tab_width, tab_height);
    }
    
}


case();
// % battery();
// pcb();
// lid();


module tab(w, h) {
    angle = 35;
    depth = (h / 2) / tan(angle);
    
    points = [
        [0, 0, 0], 
        [0, 0, h], 
        [w, 0, h],
        [w, 0, 0], 
        [depth, depth, h / 2], 
        [w - depth, depth, h / 2], 
        ];
    faces = [[0, 1, 2, 3], [1, 4, 5, 2], [0, 3, 5, 4], [0, 4, 1], [3, 2, 5]];
    polyhedron(points, faces);
}

module tab_slot(w, h, cutoff=0.4) {
    scale_x = 1.1;
    scale_y = 1.25;
    scale_z = 1.35;
    
    difference() {
    
        union() {
            // containing wall
            translate([(w - w * scale_x) / 2, 0, 0])
            cube([w * scale_x, lip_thickness, lip_height]);
            
            // outer tab
            translate([(w - w * scale_x) / 2, 0.4, (h - h * scale_z) / 2])
            scale([scale_x, scale_y, scale_z])
            tab(w, h);
        }
        
        // tab hole
        translate([0, -.01, 0])
        tab(w, h);
        
        // Cut sharp point of outer part of slot
        translate([0, lip_thickness + cutoff, 0])
        cube([w, 1, h]);
    }
    
    // translate([0, lip_thickness + 0.01, 0])
    // cube([w, lip_thickness, lip_height / 2]);
}

// tab(10, lip_height - 0.3);
// tab_slot(10, lip_height - 0.4, 0);


