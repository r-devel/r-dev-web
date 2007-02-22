SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`
SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=Rdev
#RDEV=/users/ripley/R/R-devel-lo/bin/R
#RDEV=/users/ripley/R/R-2-4-branch/bin/R
R_OPTS=-check-subdirs=yes-maybe
RLIBS=/users/ripley/R/test-library:/users/ripley/R/test-BioC:/users/ripley/R/test-Omegahat

%.out: %.in
	@echo `basename $< .in` ...
	+@R_LIBS=$(RLIBS) $(RDEV) CMD check $(R_OPTS) `basename $< .in` > $@ 2>&1
	@echo ... `basename $< .in` done

all: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-csh ../tests-keep/unpack
	rm -rf CoCo.in CVthresh.in aod.in assist.in gamlss.in sampfling.in udunits.in
	rm -f ggplot.in pscl.in tgp.in twang.in mlmRev.in seewave.in
	rm -f BRugs.in RBloomberg.in R2WinBUGS.in RWinEdt.in mimR.in rcom.in spectrino.in tcltk2.in xlsReadWrite.in
