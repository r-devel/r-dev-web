SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`
SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=Rdev
#RDEV=/users/ripley/R/gcc4/bin/R
R_OPTS=-check-subdirs=yes-maybe

%.out: %.in
	@echo `basename $< .in` ...
	+@R_LIBS=/users/ripley/R/test-library $(RDEV) CMD check $(R_OPTS) `basename $< .in` > $@ 2>&1
	@echo ... `basename $< .in` done

all: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in *.out

unpack:
	-csh ../tests-keep/unpack
	rm -rf CoCo.in Rcmdr.in assist.in rgl.in gamlss.in misc3d.in sampfling.in ncdf.in udunits.in tgp.in

