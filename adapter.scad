
// Small distance added to compensate floating point problems when subtracting
$epsilon=0.01;
// Default round parts divisions
$fn=20;
// Slack to accomodate printing tolerances (try increasing if unable to fit drives
// or unable to fit the adapter into the slot)
$slack=0.2;

// Source: https://doc.xdevs.com/doc/Seagate/SFF-8201.PDF

// max width according to notes (A4+A5)
drive_25_width=70.10 + $slack;
drive_25_height=9.50 + $slack;
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
square_nut_m3_d=1.6+$slack;

adapter_length=drive_25_depth;

wall_thickness_side=3;
wall_thickness_bottom_top=9;
side_space=10;

n_drives=6;

module bay_attachment_hole()
{
    rotate([0,90,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
    translate([wall_thickness_side-square_nut_m3_d+$epsilon, -square_nut_m3_s/2-0.1, -square_nut_m3_s/2-0.1]) cube([square_nut_m3_d+$epsilon, square_nut_m3_s+0.2, square_nut_m3_s+0.2]);
}

module side_cutouts()
{
    // Left and right spacing
    translate([wall_thickness_side,wall_thickness_side,-$epsilon]) cube([side_space, 2*slot_525_height-2*wall_thickness_side, adapter_length+2*$epsilon]);
    
    // Holes (reduce material usage)
    translate([-$epsilon,(2*slot_525_height)/2,adapter_length/2]) rotate([0,90,0]) cylinder(r=30, h=wall_thickness_side+2*$epsilon, $fn=40);
    
    translate([-$epsilon,sff_8551_A13,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A13,10+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A14,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A14,10+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A13,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A13,10+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A14,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A14,10+sff_8551_A11]) bay_attachment_hole();    
}

module drive_attachment_hole()
{
    cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
    translate([0,0,$epsilon + 1]) cylinder(r=4, h=wall_thickness_side + $epsilon - 1);
}

slot_stride = ((slot_525_width-2*wall_thickness_side)/(n_drives+1));

difference() {
    // Base block
    cube([slot_525_width, 2*slot_525_height, adapter_length]);
    
    // Main internal volume cutout
    translate([wall_thickness_side+side_space,wall_thickness_bottom_top,-$epsilon]) cube([slot_525_width-2*wall_thickness_side-2*side_space, 2*slot_525_height-2*wall_thickness_bottom_top, adapter_length+2*$epsilon]);
    
    // Top and bottom cutouts
    translate([side_space+2*wall_thickness_side,-$epsilon,-$epsilon]) cube([slot_525_width-2*(side_space+2*wall_thickness_side), (2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2+$epsilon, adapter_length+2*$epsilon]);
    translate([side_space+2*wall_thickness_side,2*slot_525_height-(2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2,-$epsilon]) cube([slot_525_width-2*(side_space+2*wall_thickness_side), (2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2+$epsilon, adapter_length+2*$epsilon]);

    // Mounting holes
    side_cutouts();
    translate([slot_525_width,0,0]) mirror([1,0,0]) side_cutouts();
    
    // Slots for drives
    for ( i = [0 : (n_drives-1)] ){
        translate([wall_thickness_side + (i+0.5)*slot_stride + drive_25_height/2, ((2*slot_525_height)-drive_25_width)/2, -$epsilon]) {
            // Drive
            cube([drive_25_height, drive_25_width, drive_25_depth+2*$epsilon]);
            
            // Screw holes
            translate([sff_8201_A23,$epsilon,sff_8201_A52]) rotate([90,0,0]) drive_attachment_hole();
            translate([sff_8201_A23,$epsilon,sff_8201_A53]) rotate([90,0,0]) drive_attachment_hole();
            translate([sff_8201_A23,drive_25_width-$epsilon,sff_8201_A52]) rotate([-90,0,0]) drive_attachment_hole();
            translate([sff_8201_A23,drive_25_width-$epsilon,sff_8201_A53]) rotate([-90,0,0]) drive_attachment_hole();
        }
    }
    
    // Cutout in fins (reduce material usage)
    translate([wall_thickness_side+side_space-$epsilon,0,0])
       rotate([90,0,90])         
       linear_extrude(height=slot_525_width-2*wall_thickness_side-2*side_space+2*$epsilon) 
       polygon( points=[
              [10,0],
              [((2*slot_525_height)-drive_25_width)/2,10],
              [((2*slot_525_height)-drive_25_width)/2,adapter_length-10],
              [10,adapter_length],
              [(2*slot_525_height)-10,adapter_length],
              [((2*slot_525_height)-drive_25_width)/2+drive_25_width,adapter_length-10],
              [((2*slot_525_height)-drive_25_width)/2+drive_25_width,10],
              [(2*slot_525_height)-10,0],
          ]
       );
    
    // Coutouts in top and bottom (reduce material usage)
    for ( i = [0 : (n_drives-2)] ){
        translate([wall_thickness_side + (i+1.5)*slot_stride + drive_25_height/2, 0, -$epsilon]) {
            hull() {
                translate([-6,-$epsilon,80]) rotate([-90,0,0]) cylinder(r=6, h=2*slot_525_height+2*$epsilon);
                translate([-6,-$epsilon,20+6]) rotate([-90,0,0]) cylinder(r=6, h=2*slot_525_height+2*$epsilon);
            }
        }
    }
}
