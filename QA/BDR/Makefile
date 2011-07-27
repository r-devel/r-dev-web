SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=/data/gannet/ripley/R/R-devel/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-2.14:~/R/BioC-2.9:~/R/test-Omegahat

## use foo-VARS=MAKE=make MAKEFLAGS=  to suppress parallel installs
FNN-VARS = MAKE=make MAKEFLAGS=
GenABEL-VARS = MAKE=make MAKEFLAGS=
RProtoBuf-VARS = MAKE=make MAKEFLAGS=
TSpadi-VARS = MAKE=make MAKEFLAGS=
farmR-VARS = MAKE=make MAKEFLAGS=
nloptr-VARS = MAKE=make MAKEFLAGS=

RNetCDF-OPTS = --install-args='--configure-args=--with-netcdf-include=/usr/include/udunits2'
Rserve-OPTS = --install-args='--configure-args=--without-server'
udunits2-OPTS = --install-args='--configure-args=--with-udunits2-include=/usr/include/udunits2'

## hit CPU limit
coxphf-OPTS  = --no-examples
lossDev-OPTS = --no-vignettes
npRmpi-OPTS = --no-examples
spikeSlabGAM-OPTS = --no-vignettes
tgp-OPTS = --no-examples --no-vignettes

## memory runs away
surveillance-OPTS = --no-examples

## slow/broken web access
NCBI2R-OPTS = --no-examples
RLastFM-OPTS = --no-examples
atmi-OPTS = --no-examples
celsius-OPTS = --no-examples

## leaves java instances running
#dynGraph-OPTS = --no-examples

## crash etc
#spsurvey-OPTS = --no-vignettes
ptinpoly-OPTS = --install=fake


## will not install
RDieHarder-OPTS = --install=fake
RMark-OPTS = --install=fake
ROracle-OPTS = --install=fake
RQuantLib-OPTS = --install=fake
RScaLAPACK-OPTS = --install=fake
Rcplex-OPTS = --install=fake
Rlsf-OPTS = --install=fake
cudaBayesreg-OPTS = --install=fake
gputools-OPTS = --install=fake
magma-OPTS = --install=fake
rpud-OPTS = --install=fake

## needs R as shlib
rscproxy-OPTS = --install=fake


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script
	@make package

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile script unpack.sh *.out ../tests-devel-keep

package: summary timing
	@chmod 644 */DESCRIPTION
	@for f in *.in; do \
	  cp `basename $$f .in`/DESCRIPTION `basename $$f .in`.Rcheck/00package.dcf; \
	done
	@tar jcf gcc.tar.bz2 *.Rcheck/00*
	@cp gcc.tar.bz2 /data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/gcc-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	@cp -p timings.tab /data/gannet/Rlogs/gcc-times.tab

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-@sh unpack.sh
