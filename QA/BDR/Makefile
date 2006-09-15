SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`
SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=Rdev
#RDEV=/users/ripley/R/R-devel-lo/bin/R
RDEV=/users/ripley/R/R-2-4-branch/bin/R
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
	rm -rf CoCo.in CVthresh.in aod.in assist.in gamlss.in sampfling.in udunits.in xlsReadWrite.in
	rm -f ggplot.in pscl.in tgp.in twang.in mlmRev.in seewave.in

X11: grasper.out pinktoe.out rpanel.out tkrplot.out uroot.out rgl.out ks.out misc3d.out feature.out

