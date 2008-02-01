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
	+@R_LIBS=$(RLIBS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) `basename $< .in` > $@ 2>&1
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
	rm -f CoCo.in CVthresh.in NORMT3.in QRMlib.in clv.in coxphf.in lasso2.in latentnetHRT.in minet.in robust.in rqmcmb2.in sampfling.in stochasticGEM.in
	## hit CPU limit
	rm -f RFreak.in TSSQLite.in Zelig.in aster.in fCopulae.in gamlss.in mlmRev.in np.in poplab.in seriation.in tgp.in twang.in
	## Windows only
	rm -f BRugs.in PBSmodelling.in RBloomberg.in R2WinBUGS.in RSAGA.in RWinEdt.in gmvalid.in mimR.in rcom.in snpXpert.in spectrino.in tcltk2.in tdm.in xlsReadWrite.in
	## depend on software that does not install on my systems
	rm -f RScaLAPACK.in Rlsf.in caretLSF.in caretNWS.in
	rm -f ROracle.in RQuantLib.in
	## slow web/browser access
	rm -f animation.in celsius.in
	## superseded
	rm -f rcompgen.in
