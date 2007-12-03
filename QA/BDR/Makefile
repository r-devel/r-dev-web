SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`
SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
#RDEV=Rdev
#RDEV=~/R/R-devel-lo/bin/R
RDEV=Rpat
R_OPTS=-check-subdirs=yes-maybe
RLIBS=~/R/test-library:~/R/BioC-2.1:~/R/test-Omegahat


%.out: %.in
	@echo `basename $< .in` ...
	@rm -f `basename $< .in`/src/*o
	+@R_LIBS=$(RLIBS) $(RDEV) CMD check $(R_OPTS) `basename $< .in` > $@ 2>&1
	@echo ... `basename $< .in` done

all: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-csh unpack.csh
	## crash or loop
	rm -f CoCo.in CVthresh.in NORMT3.in binom.in clv.in geometry.in latentnet.in rqmcmb2.in sampfling.in stochasticGEM.in
	## hit CPU limit
	rm -f GSM.in TSSQLite.in aster.in coxphf.in fCopulae.in lasso2.in mlmRev.in np.in pscl.in robust.in seriation.in tgp.in twang.in
	## Windows only
	rm -f BRugs.in PBSmodelling.in RBloomberg.in R2WinBUGS.in RSAGA.in RWinEdt.in gmvalid.in mimR.in rcom.in snpXpert.in spectrino.in tcltk2.in tdm.in xlsReadWrite.in
	## depend on software that does not install on my systems
	rm -f RScaLAPACK.in Rlsf.in Rmpi.in caretLSF.in caretNWS.in
	rm -f RDieHarder.in ROracle.in RQuantLib.in taskPR.in udunits.in
	## slow web access
	rm -f celsius.in
	## superseded
	rm -f rcompgen.in
