# Makefile to simplify rebuilding the STL files from OpenSCAD source
# Requires that make and openscad executables are accessible in PATH. Tested under Linux

all: adapter.stl adapter.png adapter-semi-toolless.stl adapter-semi-toolless.png

# Semi toolless variant is appropriate for SSD drives only - generate 7mm slots
SEMI_TOOLLESS_OPTIONS=-D SEMI_TOOLLESS=true -D sff_8201_A1=7.5
# Regular variant (screw-in) is appropriate for 2.5" HDD drives - allow 9.5mm thickness
REGULAR_VARIANT_OPTIONS=-D SEMI_TOOLLESS=false -D sff_8201_A1=10.00

%.stl: %.scad
	openscad $(REGULAR_VARIANT_OPTIONS) -o $@ $<

%.png: %.scad
	openscad $(REGULAR_VARIANT_OPTIONS) -o $@ $< --projection=perspective --render --viewall

adapter-semi-toolless.stl: adapter.scad
	openscad $(SEMI_TOOLLESS_OPTIONS) -o $@ $<

adapter-semi-toolless.png: adapter.scad
	openscad $(SEMI_TOOLLESS_OPTIONS) -o $@ $< --projection=perspective --render --viewall

clean:
	rm -f *.stl *.png

.PHONY: all clean
