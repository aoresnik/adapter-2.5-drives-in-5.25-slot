
// TODO: a bit of slack to accomodate tolerances
// TODO: better alignment of slots

$epsilon=0.01;
$fn=20;
$slack=0.2;

// Source: https://doc.xdevs.com/doc/Seagate/SFF-8201.PDF

// max width according to notes (A4+A5)
drive_25_width=70.10;
drive_25_height=9.50;
drive_25_depth=100.45;

sff_8201_A52=14;
sff_8201_A53=90.60;
sff_8201_A23=3.60;

// Source: https://doc.xdevs.com/doc/Seagate/SFF-8551.PDF

sff_8551_A1=41.53;
sff_8551_A2=42.30;
sff_8551_A11=79.25;
sff_8551_A13=10.00;
sff_8551_A14=21.84;

slot_525_width=146.05;
slot_525_height=41.53;

square_nut_m3_s=6;
square_nut_m3_d=1.6;

adapter_length=100;

wall_thickness_side=3;
wall_thickness_bottom_top=9;

n_drives=6;

module bay_attachment_hole()
{
    rotate([0,90,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
    translate([wall_thickness_side-square_nut_m3_d+$epsilon, -square_nut_m3_s/2-0.1, -square_nut_m3_s/2-0.1]) cube([square_nut_m3_d+$epsilon, square_nut_m3_s+0.2, square_nut_m3_s+0.2]);
}

module bay_attachment_holes()
{
    translate([-$epsilon,sff_8551_A13,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A13,10+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A14,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A14,10+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A13,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A13,10+sff_8551_A11]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A14,10]) bay_attachment_hole();
    translate([-$epsilon,sff_8551_A2+sff_8551_A14,10+sff_8551_A11]) bay_attachment_hole();    
}

slot_stride = ((slot_525_width-2*wall_thickness_side)/(n_drives+1));

difference() {
    cube([slot_525_width, 2*slot_525_height, adapter_length]);
    
    translate([wall_thickness_side,wall_thickness_bottom_top,-$epsilon]) cube([slot_525_width-2*wall_thickness_side, 2*slot_525_height-2*wall_thickness_bottom_top, adapter_length+2*$epsilon]);

    translate([wall_thickness_side,wall_thickness_side,-$epsilon]) cube([10, 2*slot_525_height-2*wall_thickness_side, adapter_length+2*$epsilon]);
    translate([slot_525_width-wall_thickness_side-10,wall_thickness_side,-$epsilon]) cube([10, 2*slot_525_height-2*wall_thickness_side, adapter_length+2*$epsilon]);
    
    translate([10+2*wall_thickness_side,-$epsilon,-$epsilon]) cube([slot_525_width-2*(10+2*wall_thickness_side), (2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2+$epsilon, adapter_length+2*$epsilon]);
    translate([10+2*wall_thickness_side,2*slot_525_height-(2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2,-$epsilon]) cube([slot_525_width-2*(10+2*wall_thickness_side), (2*slot_525_height-(drive_25_width+2*wall_thickness_side))/2+$epsilon, adapter_length+2*$epsilon]);

    // Mounting holes
    bay_attachment_holes();
    translate([slot_525_width,0,0]) mirror([1,0,0]) bay_attachment_holes();
    
    // Slots for drives
    for ( i = [0 : (n_drives-1)] ){
        translate([wall_thickness_side + (i+0.5)*slot_stride + drive_25_height/2, ((2*slot_525_height)-drive_25_width)/2, -$epsilon]) {
            cube([drive_25_height, drive_25_width, drive_25_depth]);
            translate([sff_8201_A23,$epsilon,sff_8201_A52]) rotate([90,0,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
            translate([sff_8201_A23,$epsilon,sff_8201_A53]) rotate([90,0,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
            translate([sff_8201_A23,drive_25_width-$epsilon,sff_8201_A52]) rotate([-90,0,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
            translate([sff_8201_A23,drive_25_width-$epsilon,sff_8201_A53]) rotate([-90,0,0]) cylinder(r=1.7, h=wall_thickness_side+2*$epsilon);
        }
    }
    
    // Holes (reduce material usage)
    translate([-$epsilon,(2*slot_525_height)/2,adapter_length/2]) rotate([0,90,0]) cylinder(r=30, h=wall_thickness_side+2*$epsilon);
    translate([slot_525_width-$epsilon-wall_thickness_side,(2*slot_525_height)/2,adapter_length/2]) rotate([0,90,0]) cylinder(r=30, h=wall_thickness_side+2*$epsilon);
    
    // Cutout in fins (reduce material usage)
    translate([wall_thickness_side,0,0])
       rotate([90,0,90])         
       linear_extrude(height=slot_525_width-2*wall_thickness_side) 
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
        translate([wall_thickness_side + (i+1)*slot_stride + drive_25_height/2, 0, -$epsilon]) {
            hull() {
                translate([6,-$epsilon,80]) rotate([-90,0,0]) cylinder(r=6, h=2*slot_525_height+2*$epsilon);
                translate([6,-$epsilon,20+6]) rotate([-90,0,0]) cylinder(r=6, h=2*slot_525_height+2*$epsilon);
            }
        }
    }
}
