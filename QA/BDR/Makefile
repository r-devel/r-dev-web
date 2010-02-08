SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=~/R/R-devel/bin/R
#RDEV=~/R/R-devel-lo/bin/R
R_OPTS=-check-subdirs=yes-maybe
RLIBS=~/R/test-2.11:~/R/BioC-2.6:~/R/test-Omegahat

## use foo-VARS=MAKE=make MAKEFLAGS=  to suppress parallel installs
farmR-VARS = MAKE=make MAKEFLAGS=

## hit CPU limit
BB-OPTS = --no-tests --no-vignettes
Bergm-OPTS = --no-examples
IsoGene-OPTS = --no-examples
VGAM-OPTS = --no-examples
amei-OPTS = --no-vignettes
geozoo-OPTS = --no-examples
rWMBAT-OPTS = --no-examples
speff2trial-OPTS = --no-examples
surveillance-OPTS = --no-examples
tgp-OPTS = --no-examples --no-vignettes

## slow/broken web access
atmi-OPTS = --no-examples
celsius-OPTS = --no-examples

## leaves java instances running
#dynGraph-OPTS = --no-examples

## crash etc
#CoCo-OPTS=--no-examples
coxphf-OPTS=--no-examples
#gmvalid-OPTS=--no-examples
sampfling-OPTS=--no-examples --no-tests

## will not install
RDieHarder-OPTS = --install=fake
ROracle-OPTS = --install=fake
RQuantLib-OPTS = --install=fake
RScaLAPACK-OPTS = --install=fake
Rcplex-OPTS = --install=fake
Rlsf-OPTS = --install=fake
Rserve-OPTS = --install=fake
cudaBayesreg-OPTS = --install=fake
gputools-OPTS = --install=fake
rscproxy-OPTS = --install=fake

## depend on Windows (undeclared)
VhayuR-OPTS = --install=fake

## depends on JRI which need Rshlib
Deducer-OPTS = --install=fake
gWidgetsrJava-OPTS = --install=fake


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile script unpack.sh *.out ../tests-devel-keep

package:
	@chmod 644 */DESCRIPTION
	@for f in *.in; do \
	  cp `basename $$f .in`/DESCRIPTION `basename $$f .in`.Rcheck/00package.dcf; \
	  cp `basename $$f .in`.out `basename $$f .in`.Rcheck/00check.out; \
	done
	@tar jcf gcc.tar.bz2 *.Rcheck/00*
	@cp gcc.tar.bz2 /data/gannet/Rlogs
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/gcc-check.csv

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/gcc-check.csv

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-@sh unpack.sh
	@rm R2PPT.in
