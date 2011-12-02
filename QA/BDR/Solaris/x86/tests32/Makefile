.SUFFICES: .out .log
RDEV=/home/ripley/R/cc/bin/R
RLIBS=/home/ripley/R/Lib32

## runs multicore
mboost-OPTS = --no-vignettes
spikeSlabGAM-OPTS = --no-vignettes

## hit CPU limit
lokern-OPTS = --no-tests
tgp-OPTS = --no-examples --no-vignettes

## chews script
flexclust-OPTS = --no-tests

## slow/broken web access
NCBI2R-OPTS = --no-examples
RLastFM-OPTS = --no-examples
TSgetSymbol-OPTS = --no-examples --no-vignettes
#atmi-OPTS = --no-examples
celsius-OPTS = --no-examples
elliptic-OPTS = --no-vignettes
speedglm-OPTS = --no-examples
## tries to use multicore
adegenet-OPTS = --no-vignettes
## tries to use snow
simFrame-OPTS = --no-vignettes
## tries to use RMySQL
vegdata-OPTS = --no-vignettes
## tries to use RPostgreSQL
TSPostgreSQL-OPTS = --no-vignettes
TSfame-OPTS = --no-vignettes
TSodbc-OPTS = --no-vignettes

include Makefile.fakes

## needs R as shlib
rscproxy-OPTS = --install=fake

lossDev-OPTS = --no-vignettes
FracSim-OPTS = --no-examples

%.out: %.log
	@echo $* ...
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) -l ~/R/Lib32 --install=check:$*.log $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

check: $(OUTS)

install:
	@/home/ripley/R/cc/bin/Rscript swift.R

installn:
	@$(RDEV) --slave -f swift-parallel.R


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
	rm -rf KernSmooth.* MASS.* Matrix.* boot.* class.* cluster.* \
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
