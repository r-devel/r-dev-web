SOURCES=${shell ls *.log}
OUTS=$(SOURCES:.log=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV=/home/ripley/R/cc/bin/R
RLIBS=/home/ripley/R/Lib32

## use foo-VARS=MAKE=make MAKEFLAGS=  to suppress parallel installs
RBRownie-VARS = MAKE=gmake
RSiena-VARS = MAKE=gmake
TSpadi-VARS = MAKE=gmake
sprint-VARS = MAKE=gmake
# Rcpp users
RInside-VARS = MAKE=gmake
RcppArmadillo-VARS = MAKE=gmake
RcppExamples-VARS = MAKE=gmake
cxxPack-VARS = MAKE=gmake
highlight-VARS = MAKE=gmake
minqa-VARS = MAKE=gmake
termtsrc-VARS = MAKE=gmake

Rserve-VARS = MAKE=gmake


## disallows Solaris
GridR-OPTS = --install=fake
cmprskContin-OPTS = --install=fake

## runs multicore
mboost-OPTS = --no-vignettes
spikeSlabGAM-OPTS = --no-vignettes

## hit CPU limit
lokern-OPTS = --no-tests
npRmpi-OPTS = --no-examples

## chews script
flexclust-OPTS = --no-tests

## slow/broken web access
NCBI2R-OPTS = --no-examples
RLastFM-OPTS = --no-examples
atmi-OPTS = --no-examples
celsius-OPTS = --no-examples

## will not install
OpenCL-OPTS = --install=fake
RDieHarder-OPTS = --install=fake
RMark-OPTS = --install=fake
RMySQL-OPTS = --install=fake
ROAuth-OPTS = --install=fake
ROracle-OPTS = --install=fake
RQuantLib-OPTS = --install=fake
RScaLAPACK-OPTS = --install=fake
Rcplex-OPTS = --install=fake
Rlsf-OPTS = --install=fake
TSMySQL-OPTS = --install=fake
VBmix-OPTS = --install=fake
clpAPI-OPTS = --install=fake
cudaBayesreg-OPTS = --install=fake
glpkAPI-OPTS = --install=fake
gputools-OPTS = --install=fake
magma-OPTS = --install=fake
mpc-OPTS = --install=fake
rJavax-OPTS = --install=fake
rpud-OPTS = --install=fake
rpvm-OPTS = --install=fake

## needs R as shlib
rscproxy-OPTS = --install=fake


## depend on JRI which needs R as shlib
gWidgetsrJava-OPTS = --install=fake

lossDev-OPTS = --no-vignettes
FracSim-OPTS = --no-examples

%.out: %.log
	@echo $* ...
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) -l ~/R/Lib32 --install=check:$*.log $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

check: $(OUTS)

install:
	@Rscript swift.R

backup:
	@mkdir -p ../tests32-keep
	@cp -p Makefile script swift.R *.log *.out ../tests32-keep

package: summary timings
	@chmod 644 */DESCRIPTION
	@for f in *.out; do \
	  cp `basename $$f .out`/DESCRIPTION `basename $$f .out`.Rcheck/00package.dcf; \
	done
	@gtar jcf Solx86.tar.bz2 *.Rcheck/00check.log *.Rcheck/00install.out *.Rcheck/00package.dcf
	@scp -q Solx86.tar.bz2 gannet:/data/gannet/Rlogs

summary:
	@Rscript ../summary.R
	@scp -pq check.csv gannet:/data/gannet/Rlogs/Solx86-check.csv

timings:
	@Rscript ../check_times.R
	@scp -pq timings.tab gannet:/data/gannet/Rlogs/Solx86-times.tab

clean:
	find * -type d -exec rm -rf {} \;

veryclean: clean
	rm -f *.out *.log

rm-recommended:
	rm -f KernSmooth.* MASS.* Matrix.* boot.* class.* cluster.* \
	  codetools.* foreign.* lattice.* mgcv.* nlme.* nnet.* \
	  rpart.log rpart.out spatial.* survival.*

cp-recommended:
	(cd ../tests32-keep; cp -p KernSmooth.out MASS.out Matrix.out \
	  boot.out class.out cluster.out \
          codetools.out foreign.out lattice.out mgcv.out nlme.out nnet.out \
          rpart.out spatial.out survival.out \
	  KernSmooth.log MASS.log Matrix.log \
          boot.log class.log cluster.log \
          codetools.log foreign.log lattice.log mgcv.log nlme.log nnet.log \
          rpart.log spatial.log survival.log \
	../tests32)
