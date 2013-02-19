SOURCES=${shell ls *.log}
OUTS=$(SOURCES:.log=.out)

OUTS0 = MSToolkit.out MSwM.out NHPoission.out gdsfmt.out geneSignatureFinder.out simFrame.out snowFT.out

.SUFFICES:
.SUFFICES: .in .out

RDEV=/home/ripley/R/cc/bin/R
RLIBS=/home/ripley/R/Lib32
BACKUP=../tests32-keep


## runs multicore
#adegenet-OPTS = --no-vignettes
flexclust-OPTS = --no-tests
mboost-OPTS = --no-vignettes
spikeSlabGAM-OPTS = --no-vignettes


## OpenMP hangs
sme-OPTS = --no-examples --no-tests --no-vignettes

## vignettes need BRugs
fanplot-OPTS = --no-vignettes

## hit CPU limit
lokern-OPTS = --no-tests
lossDev-OPTS = --no-vignettes
tgp-OPTS = --no-vignettes

## slow/broken web access
DSPRqtl-OPTS = --no-vignettes
NCBI2R-OPTS = --no-examples
PAGI-OPTS = --no-rebuild-vignettes
RNCEP-OPTS = --no-examples
RLastFM-OPTS = --no-examples
TSgetSymbol-OPTS = --no-examples --no-vignettes
celsius-OPTS = --no-examples
#speedglm-OPTS = --no-examples
SSOAP-OPTS = --no-examples
XML-OPTS = --no-examples
rebmix-OPTS = --no-rebuild-vignettes
STAR-OPTS = --no-rebuild-vignettes
mcmc-OPTS = --no-rebuild-vignettes
phylosim-OPTS = --no-vignettes
amei-OPTS = --no-rebuild-vignettes
dismo-OPTS = --no-rebuild-vignettes
crs-OPTS = --no-rebuild-vignettes


## needs BRugs
bcrm-OPTS = --no-examples
## needs pari/gp
elliptic-OPTS = --no-vignettes
## tries to use RMySQL
vegdata-OPTS = --no-vignettes
TSdata-OPTS = --no-vignettes

## problems with using snow
simFrame-OPTS = --no-vignettes
DSL-OPTS = --no-vignettes

include Makefile.fakes

%.out: %.log
	@echo $* ...
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) -l $(RLIBS) --install=check:$*.log $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

Rcpp.out:
	@touch Rcpp.log
	@rm -rf Rcpp
	@gtar xf ../contrib/Rcpp_*.tar.gz
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) Rcpp > Rcpp.out 2>&1

check: $(OUTS)

check0: $(OUTS0)

install:
	@$(RDEV) --slave -f swift.R

installn:
	@$(RDEV) --slave -f swift-parallel.R


backup:
	@mkdir -p $(BACKUP)
	@cp -p Makefile script pkgdiff common.R swift*.R *.log *.out $(BACKUP)

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
