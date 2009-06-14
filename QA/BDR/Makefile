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
BB-OPTS=--no-tests
IsoGene-OPTS=--no-examples
STAR-OPTS=--no-examples --no-vignettes
amei-OPTS=--no-vignettes
geozoo-OPTS=--no-examples
latentnet-OPTS=--no-examples --no-tests
latentnetHRT-OPTS=--no-examples --no-tests
mmcm-OPTS=--no-examples
tgp-OPTS=--no-examples --no-vignettes

## slow web access
celsius-OPTS=--no-examples

## leave firefox/java instances running
brew-OPTS=--no-examples
dynGraph-OPTS=--no-examples

## crash etc
CoCo-OPTS=--no-examples
coxphf-OPTS=--no-examples
gmvalid-OPTS=--no-examples
sampfling-OPTS=--no-examples --no-tests

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*o
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
