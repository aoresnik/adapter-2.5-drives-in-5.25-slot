
all: adapter.stl adapter.png

%.stl: %.scad
	openscad -o $@ $<

%.png: %.scad
	openscad -o $@ $< --projection=perspective --render --viewall

clean:
	rm -f *.stl *.png

.PHONY: all clean
