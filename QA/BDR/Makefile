SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`
SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=Rdev
#RDEV=~/R/R-devel-lo/bin/R
R_OPTS=-check-subdirs=yes-maybe
RLIBS=~/R/test-library:~/R/BioC-2.5:~/R/test-Omegahat

## hit CPU limit
CoCo-OPTS=--no-examples
IsoGene-OPTS=--no-examples
STAR-OPTS=--no-examples --no-vignettes
coxphf-OPTS=--no-examples
geozoo-OPTS=--no-examples
gmvalid-OPTS=--no-examples
latentnet-OPTS=--no-examples --no-tests --no-vignettes
latentnetHRT-OPTS=--no-examples --no-tests --no-vignettes
sampfling-OPTS=--no-examples --no-tests
tgp-OPTS=--no-examples --no-vignettes

## slow web access
celsius-OPTS=--no-examples

%.out: %.in
	@echo $* ...
	@rm -f `basename $< .in`/src/*o
	-+@R_LIBS=$(RLIBS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

backup:
	@cp -p Makefile *.out ../tests-devel-keep

unpack:
	-sh unpack.sh
	## depend on software that does not install on my systems
	rm -f RDieHarder.in RScaLAPACK.in Rlsf.in
	rm -f Rcplex.in ROracle.in VhayuR.in
	## superseded
	rm -f rcompgen.in
