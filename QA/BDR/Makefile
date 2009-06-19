SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=Rdev
#RDEV=~/R/R-devel-lo/bin/R
R_OPTS=-check-subdirs=yes-maybe
RLIBS=~/R/test-library:~/R/BioC-2.5:~/R/test-Omegahat

## use foo-VARS=MAKE=make MAKEFLAGS=  to suppress parallel installs

## hit CPU limit
BB-OPTS=--no-tests
IsoGene-OPTS=--no-examples
STAR-OPTS=--no-examples --no-vignettes
amei-OPTS=--no-vignettes
geozoo-OPTS=--no-examples
latentnet-OPTS=--no-examples --no-tests
latentnetHRT-OPTS=--no-examples --no-tests
tgp-OPTS=--no-examples --no-vignettes

## slow web access
celsius-OPTS=--no-examples

## leaves java instances running
dynGraph-OPTS=--no-examples

## crash etc
CoCo-OPTS=--no-examples
coxphf-OPTS=--no-examples
gmvalid-OPTS=--no-examples
sampfling-OPTS=--no-examples --no-tests

## will not install
RDieHarder-OPTS = --install=fake
ROracle-OPTS = --install=fake
RQuantLib-OPTS = --install=fake
RScaLAPACK-OPTS = --install=fake
Rcplex-OPTS = --install=fake
Rlsf-OPTS = --install=fake

## depend on Windows (undeclared)
VhayuR-OPTS = --install=fake

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

backup:
	@mkdir -p keep
	@cp -p Makefile *.out keep

unpack:
	-sh unpack.sh
	## superseded
	rm -f rcompgen.in
