
all: adapter.stl

%.stl: %.scad
	openscad -o $@ $<

clean:
	rm *.stl

.PHONY: all clean
