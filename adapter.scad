
// Small distance added to compensate floating point problems when subtracting
// 0.01 is too small, because some remains can be seen in OpenSCAD UI when rotating the object
$epsilon=0.02;
// Default round parts divisions
$fn=25;
// Slack to accomodate printing tolerances (try increasing if unable to fit drives
// or unable to fit the adapter into the slot)
$slack=0.1;

$nut_trap_slack_s=0.5;
$nut_trap_slack_d=0.2;

$layer_thickness=0.2;

SEMI_TOOLLESS=true;

// Source: https://doc.xdevs.com/doc/Seagate/SFF-8201.PDF

// The thickness (height) of the drive. Standard allows many different thicknesses
// Common values are 7.0 for SSD and 9.50 for HDD
sff_8201_A1=7.50;

// max width according to notes (A4+A5)
drive_25_width=70.10 + $slack;
drive_25_height=sff_8201_A1 + $slack;
drive_25_depth=100.45 + $slack;

sff_8201_A52=14 + $slack;
sff_8201_A53=90.60 + $slack;
sff_8201_A23=3.60 + $slack;

// Source: https://doc.xdevs.com/doc/Seagate/SFF-8551.PDF

slot_525_width=146.05 - $slack;
slot_525_height=41.53 - $slack;

sff_8551_A1=41.53 + $slack;
sff_8551_A2=42.30 + 0.2;
sff_8551_A11=79.25 + $slack;
sff_8551_A13=10.00 + $slack;
sff_8551_A14=21.84 + $slack;

square_nut_m3_s=6+$slack;
square_nut_m3_d=1.6;
wall_thickness_square_nut=1.3;

wall_thickness_side=2.1;
wall_thickness_bottom_top=14;
side_space=10;
side_slot_width=5;

adapter_length=SEMI_TOOLLESS ? (drive_25_depth + wall_thickness_side) : drive_25_depth;

n_drives=6;

module bay_attachment_hole()
{
    rotate([0,90,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
    translate([wall_thickness_square_nut+$epsilon, -square_nut_m3_s/2-0.1, -square_nut_m3_s/2-0.1]) cube([wall_thickness_side-wall_thickness_square_nut+$epsilon, square_nut_m3_s+0.2, square_nut_m3_s+0.2]);
}

module bay_attachment_holes()
{
    z_offset = (adapter_length-sff_8551_A11)/2;
    
    translate([-$epsilon,sff_8551_A13,z_offset]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A13,z_offset+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A14,z_offset]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A14,z_offset+sff_8551_A11]) bay_attachment_hole();

    // Hole for reduction of material usage    
    translate([-$epsilon,(sff_8551_A14+sff_8551_A13)/2,0])
        hull() {
            translate([0,0,adapter_length-26]) rotate([0,90,0]) cylinder(r=10, h=wall_thickness_side+2*$epsilon);
            translate([0,0,26]) rotate([0,90,0]) cylinder(r=10, h=wall_thickness_side+2*$epsilon);
        };
}

module side_cutouts()
{
    // Left and right spacing
    // Slot moved for $slack upwards
    translate([wall_thickness_side,wall_thickness_side,-$epsilon]) cube([side_space, sff_8551_A2-2*wall_thickness_side-side_slot_width+$slack, adapter_length+2*$epsilon]);

    translate([wall_thickness_side,sff_8551_A2+wall_thickness_side+$slack,-$epsilon]) cube([side_space, 2*slot_525_height-sff_8551_A2-2*wall_thickness_side-$slack, adapter_length+2*$epsilon]);
    
    translate([-$epsilon, sff_8551_A2-side_slot_width+$slack, -$epsilon]) cube([side_space+$epsilon, side_slot_width, adapter_length+2*$epsilon]);
        
    // Holes (reduce material usage)
    //#translate([-$epsilon,(2*slot_525_height)/2,adapter_length/2]) rotate([0,90,0]) cylinder(r=30, h=wall_thickness_side+2*$epsilon, $fn=40);
    
    bay_attachment_holes();
    translate([0,sff_8551_A2,0]) bay_attachment_holes();
}

module drive_attachment_hole()
{
    cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
    translate([0,0,$epsilon + 1]) cylinder(r=4.25, h=wall_thickness_side + $epsilon - 1);
}

slot_stride = ((slot_525_width-2*wall_thickness_side-2*side_space)/(n_drives));

top_bottom_spacing_x = slot_525_width-2*(side_space+2*wall_thickness_side);
top_bottom_spacing_y = (2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2;

module top_bottom_cutouts(z_cutout_start)
{
    // Top and bottom cutouts
    translate([side_space+2*wall_thickness_side,-$epsilon,z_cutout_start]) cube([top_bottom_spacing_x, top_bottom_spacing_y+$epsilon, adapter_length+2*$epsilon]);

    // Slots for drives
    for ( i = [0 : (n_drives-1)] ){
        translate([wall_thickness_side + side_space + i*slot_stride + slot_stride/2 - drive_25_height/2, ((2*slot_525_height)-drive_25_width)/2, -$epsilon]) {
            // Drive
            cube([drive_25_height, 10, drive_25_depth+2*$epsilon]);
            
            if (!SEMI_TOOLLESS) 
            {
                // Screw holes
                translate([sff_8201_A23,$epsilon,sff_8201_A52]) rotate([90,0,0]) drive_attachment_hole();
                translate([sff_8201_A23,$epsilon,sff_8201_A53]) rotate([90,0,0]) drive_attachment_hole();
            }
        }
    }
    
    // Cutout in fins (reduce material usage)
    // Slot fins should cover the screw hole, because disks have more consistent thickness at this point
    // (important in semi-toolless variant)
    a = wall_thickness_bottom_top-((2*slot_525_height)-drive_25_width)/2;
    #translate([wall_thickness_side+side_space-$epsilon,0,0])
       rotate([90,0,90])         
       linear_extrude(height=slot_525_width-2*wall_thickness_side-2*side_space+2*$epsilon) 
       polygon( points=[
              [wall_thickness_bottom_top+$epsilon,sff_8201_A52-a/2],
              [((2*slot_525_height)-drive_25_width)/2,sff_8201_A52+a/2],
              [((2*slot_525_height)-drive_25_width)/2,sff_8201_A53-a/2],
              [wall_thickness_bottom_top+$epsilon,sff_8201_A53+a/2],
          ]
       );
    
    // Coutouts in top and bottom (reduce material usage)
    hole_r = (slot_stride-drive_25_height)/2;
    for ( i = [1 : (n_drives-1)] ){
        translate([wall_thickness_side + side_space + i*slot_stride + slot_stride/2 - drive_25_height/2, 0, -$epsilon]) {
            hull() {
                translate([-hole_r ,-$epsilon,80]) rotate([-90,0,0]) cylinder(r=hole_r , h=10+2*$epsilon);
                translate([-hole_r ,-$epsilon,20+6]) rotate([-90,0,0]) cylinder(r=hole_r , h=10+2*$epsilon);
            }
        }
    }
}

difference() {
    // Base block
    cube([slot_525_width, 2*slot_525_height, adapter_length]);
    
    // Main internal volume cutout
    translate([wall_thickness_side+side_space-$epsilon,wall_thickness_bottom_top,-$epsilon]) cube([slot_525_width-2*wall_thickness_side-2*side_space+2*$epsilon, 2*slot_525_height-2*wall_thickness_bottom_top, adapter_length+2*$epsilon]);
    
    // Side cutouts (simetrical along the x axis trough the middle plane)
    side_cutouts();
    translate([slot_525_width,0,0]) mirror([1,0,0]) side_cutouts();
    
    // Top and bottom cutouts (simetrical along the y axis trough the middle plane)
    // For semi-toolless variant, add a lip to reduce bending
    top_bottom_cutouts(SEMI_TOOLLESS ? wall_thickness_side : -$epsilon);
    translate([0,2*slot_525_height,0]) mirror([0,1,0]) top_bottom_cutouts(-$epsilon);
}

lock_plate_screw_post_x = side_space;
lock_plate_screw_post_y = wall_thickness_bottom_top-wall_thickness_side;
lock_plate_screw_post_z = square_nut_m3_d + 2*wall_thickness_square_nut;

module lock_plate_screw_post()
{
    translate([wall_thickness_side-$epsilon, 2*slot_525_height-wall_thickness_side-lock_plate_screw_post_y+$epsilon, 0])
        difference () {
            cube([lock_plate_screw_post_x+2*$epsilon, lock_plate_screw_post_y+$epsilon, lock_plate_screw_post_z]);
            translate([(lock_plate_screw_post_x-(square_nut_m3_s+$nut_trap_slack_s))/2, -$epsilon, wall_thickness_square_nut])
                cube([square_nut_m3_s+$nut_trap_slack_s, square_nut_m3_s+$nut_trap_slack_s+$epsilon, square_nut_m3_d+$nut_trap_slack_d]);
            // Hole below square nut trap
            translate([lock_plate_screw_post_x/2, (square_nut_m3_s+$slack)/2, -$epsilon])
              cylinder(r=1.7, h=wall_thickness_square_nut+2*$epsilon);
            // Hole above the square nut trap - leave one layer for support
            translate([lock_plate_screw_post_x/2, (square_nut_m3_s+$slack)/2, wall_thickness_square_nut+square_nut_m3_d+$slack+$layer_thickness])
              cylinder(r=1.7, h=wall_thickness_square_nut);
        }
}

lock_plate_y = wall_thickness_bottom_top;

module lock_plate_screw_hole()
{
    translate([wall_thickness_side+lock_plate_screw_post_x/2, (square_nut_m3_s+$slack)/2, -$epsilon])
        cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
}

module lock_plate()
{
    difference() {
        cube([slot_525_width, lock_plate_y, wall_thickness_side]);
        lock_plate_screw_hole();
        translate([slot_525_width,0,0]) mirror([1,0,0]) lock_plate_screw_hole();
    }
    
    translate([(slot_525_width-(top_bottom_spacing_x-2*$slack))/2, lock_plate_y-top_bottom_spacing_y+$slack, wall_thickness_side])
        cube([top_bottom_spacing_x-2*$slack, top_bottom_spacing_y-$slack, 5]);
}

if (SEMI_TOOLLESS)
{
    lock_plate_screw_post();
    translate([slot_525_width,0,0]) mirror([1,0,0]) lock_plate_screw_post();
    
    translate([0, 2*slot_525_height + 10, 0])
        lock_plate();
}
