// Breadboard resistor lead bender inspired by the supplied video screenshots.
// Units: mm. Print the single former upright.

// Small 1/4 W axial resistor and standard breadboard hole spacing.
hole_pitch = 2.54;
hole_count = 2;             // Finished lead pitch: 2 holes = 5.08 mm.
lead_diameter = 0.45;
body_length = 3.2;
body_diameter = 1.7;

resistor_count = 24;
row_pitch = 2.54;
end_margin = 5;
former_height = 20/3;
shoulder_chamfer = 0.35;
body_clearance = 0.3;
// Sized for a 0.4 mm nozzle and 0.2 mm layers: grooves span four layers.
lead_groove_width = 1.2;
lead_groove_depth = 0.8;
body_recess = body_diameter/2 + lead_groove_depth - lead_diameter/2;

target_lead_pitch = hole_count * hole_pitch;
// The vertical leg centerlines lie roughly one lead radius beyond each face.
former_width = target_lead_pitch - lead_diameter;
former_length = (resistor_count - 1) * row_pitch + 2 * end_margin;
body_channel_width = body_length + body_clearance;

assert(hole_count >= 2);
assert(former_width > body_channel_width + 2 * lead_diameter,
       "Lead pitch is too narrow for this resistor body. Increase hole_count.");
assert(row_pitch >= body_diameter,
       "Adjacent resistor bodies would overlap. Increase row_pitch.");
assert(lead_groove_width < row_pitch - 0.8,
       "Leave at least 0.8 mm of material between adjacent grooves.");

module former_blank() {
    // Cross section in the Y/Z plane.  The two small bevels soften the bend.
    rotate([0, 90, 0])
        linear_extrude(height = former_length, center = true)
            polygon([
                [0, -former_width/2],
                [-former_height + shoulder_chamfer, -former_width/2],
                [-former_height, -former_width/2 + shoulder_chamfer],
                [-former_height, former_width/2 - shoulder_chamfer],
                [-former_height + shoulder_chamfer, former_width/2],
                [0, former_width/2]
            ]);
}

module former() {
    difference() {
        former_blank();

        // The bodies sit slightly below the top, bringing their leads close
        // to the lead grooves while leaving the bending shoulders at full height.
        translate([0, 0, former_height - body_recess/2 + 0.01])
            cube([former_length - 2 * end_margin + row_pitch,
                  body_channel_width, body_recess + 0.02], center = true);

        // Open-ended slots at each row position remain visible to a 0.4 mm
        // nozzle. The channel depth keeps the body and lead axes aligned.
        for (i = [0 : resistor_count - 1]) {
            x = (i - (resistor_count - 1)/2) * row_pitch;
            for (side = [-1, 1])
                translate([x,
                           side * (body_channel_width/2 + former_width/2)/2,
                           former_height - lead_groove_depth/2 + 0.01])
                    cube([lead_groove_width,
                          former_width/2 - body_channel_width/2 + 0.04,
                          lead_groove_depth + 0.02], center = true);
        }
    }
}

former();
