
all: adapter.stl adapter.png adapter-semi-toolless.stl adapter-semi-toolless.png

%.stl: %.scad
	openscad -o $@ $<

%.png: %.scad
	openscad -o $@ $< --projection=perspective --render --viewall

adapter-semi-toolless.stl: adapter.scad
	openscad -D SEMI_TOOLLESS=true -o $@ $<

adapter-semi-toolless.png: adapter.scad
	openscad -D SEMI_TOOLLESS=true -o $@ $< --projection=perspective --render --viewall

clean:
	rm -f *.stl *.png

.PHONY: all clean
