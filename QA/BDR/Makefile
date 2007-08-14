SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`
SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=Rdev
#RDEV=~/R/R-devel-lo/bin/R
#RDEV=Rpat
R_OPTS=-check-subdirs=yes-maybe
#RLIBS=~/R/test-library:~/R/test-BioC:~/R/test-Omegahat
RLIBS=~/R/test26:~/R/test-library:~/R/BioC-2.1:~/R/test-Omegahat


%.out: %.in
	@echo `basename $< .in` ...
	@rm -f `basename $< .in`/src/*o
	+@R_LIBS=$(RLIBS) $(RDEV) CMD check $(R_OPTS) `basename $< .in` > $@ 2>&1
	@echo ... `basename $< .in` done

all: $(OUTS)

clean:
	find * -maxdepth 0 -type d -delete
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-csh ../tests-keep/unpack
	## crash
	rm -f CoCo.in CVthresh.in sampfling.in latentnet.in
	## hit CPU limit
	rm -f aster.in coxphf.in gamlss.in ggplot.in pscl.in tgp.in twang.in mlmRev.in np.in robust.in
	## Windows only
	rm -f BRugs.in PBSmodelling.in RBloomberg.in R2WinBUGS.in RWinEdt.in mimR.in rcom.in snpXpert.in spectrino.in tcltk2.in tdm.in xlsReadWrite.in
	## depend on software that does not install on my systems
	rm -f RScaLAPACK.in Rlsf.in Rmpi.in maanova.in papply.in pvclust.in rpvm.in scaleboot.in snowFT.in varSelRF.in
	rm -f RDieHarder.in RGrace.in ROracle.in RQuantLib.in taskPR.in udunits.in
	## slow web access
	rm -f celsius.in
