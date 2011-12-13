.SUFFICES: .out .log
RDEV=/home/ripley/R/cc/bin/R
RLIBS=/home/ripley/R/Lib32

## hit CPU limit
AGSDest-OPTS = --no-vignettes
BB-OPTS = --no-tests --no-vignettes
ChemSpec-OPTS = --no-rebuild-vignettes
CONOR-OPTS = --no-examples
DAKS-OPTS = --no-vignettes
DOBAD-OPTS = --no-vignettes
GSM-OPTS = --no-examples
GenABEL-OPTS = --no-examples
HiveR-OPTS = --no-vignettes
LaplacesDemon-OPTS = --no-vignettes
LogConcDEAD-OPTS = --no-vignettes
MetabolAnalyze-OPTS = --no-examples
NMF-OPTS = --no-vignettes
#RFinanceYJ-OPTS = --no-examples
Sim.DiffProc-OPTS = --no-examples --no-tests
StatMatch-OPTS = --no-vignettes
TSgetSymbol-OPTS = --no-examples
VGAM-OPTS = --no-vignettes
abc-OPTS = --no-vignettes
adehabitatLT-OPTS = --no-examples --no-vignettes
amei-OPTS = --no-vignettes
amer-OPTS = --no-tests --no-vignettes
aspect-OPTS = --no-vignettes
bfp-OPTS = --no-tests
coxphf-OPTS = --no-examples
crimCV-OPTS = --no-examples
crs-OPTS = --no-examples
#demography-OPTS = --no-examples
dismo-OPTS = --no-vignettes
dse-OPTS = --no-tests
eqtl-OPTS = --no-examples
expectreg-OPTS = --no-examples --no-vignettes --no-tests
fda-OPTS = --no-examples
flexclust-OPTS = --no-tests
geozoo-OPTS = --no-examples
iSubpathwayMiner-OPTS = --no-vignettes
lokern-OPTS = --no-examples --no-tests
lossDev-OPTS = --no-vignettes
mcmc-OPTS = --no-vignettes
micEconCES-OPTS = --no-tests --no-vignettes
modTempEff-OPTS = --no-vignettes
monomvn-OPTS = --no-examples
nFactors-OPTS = --no-vignettes
np-OPTS = --no-examples --no-vignettes
phangorn-OPTS = --no-vignettes
pomp-OPTS = --no-tests
pvclust-OPTS = --no-examples
rWMBAT-OPTS = --no-examples
rattle-OPTS = --no-examples
rebmix-OPTS = --no-vignettes
remMap-OPTS = --no-examples
rphast-OPTS = --no-examples --no-tests --no-vignettes
rtfbs-OPTS = --no-examples --no-tests --no-vignettes
secr-OPTS = --no-examples
seriation-OPTS = --no-examples --no-vignettes
speedglm-OPTS = --no-examples
speff2trial-OPTS = --no-examples
spikeSlabGAM-OPTS = --no-examples --no-vignettes
tgp-OPTS = --no-examples --no-vignettes
unmarked-OPTS = --no-vignettes

## multicore
adegenet-OPTS = --no-vignettes
multicore-OPTS = --no-examples
mboost-OPTS = --no-vignettes
spikeSlabGAM-OPTS = --no-examples --no-vignettes


## slow/broken web access
NCBI2R-OPTS = --no-examples
RLastFM-OPTS = --no-examples
TSgetSymbol-OPTS = --no-examples --no-vignettes
celsius-OPTS = --no-examples
speedglm-OPTS = --no-examples
elliptic-OPTS = --no-vignettes
misc3d-OPTS = --no-examples
gstudio-OPTS = --no-vignettes

## tries to use RMySQL
vegdata-OPTS = --no-vignettes
## tries to use RPostgreSQL
TSPostgreSQL-OPTS = --no-vignettes
TSfame-OPTS = --no-vignettes
TSodbc-OPTS = --no-vignettes

## crash etc
FracSim-OPTS=--no-examples

include Makefile.fakes

RGL_USERS = \
    AER.out CADStat.out ChemoSpec.out DiceDesign.out DiceView.out \
    FieldSim.out GeoXp.out MCMCglmm.out NeatMap.out VecStatGraphs3D.out \
    bpca.out cems.out compositions.out depth.out dti.out \
    edrGraphicalTools.out feature.out grt.out hgam.out homals.out \
    kml3d.out ks.out misc3d.out mixOmics.out msr.out qpcR.out \
    phangorn.out raster.out rgl.out seewave.out shapes.out sm.out smacof.out \
    tolerance.out vcdExtra.out \
    ENmisc.out RcmdrPlugin.mosaic.out LMERConvenienceFunctions.out Rknots.out \
    bios2mds.out rasterVis.out KernSmoothIRT.out alphashape3d.out StatDA.out \
    curvHDR.out ptinpoly.out DirichletReg.out abcdeFBA.out HiveR.out \
    genridge.out


%.out: %.log
	@echo $* ...
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) -l ~/R/Lib32 --install=check:$*.log $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

%.log: %.in
	@echo installing $*
	-+@R_LIBS=$(RLIBS) $($*-VARS) MAKE=make MAKEFLAGS= time $(RDEV) CMD INSTALL $($*-IOPTS) --pkglock ../contrib/$*_*.tar.gz > $@ 2>&1

all:
	@$(MAKE) -k install
	@DISPLAY=:5 gmake -k check

install:
	@$(RDEV) --slave -f swallow.R

installn:
	@$(RDEV) --slave -f swallow-parallel.R

LOGS=${shell ls *.log}
check: $(LOGS:.log=.out)

backup:
	@mkdir -p ../tests32-keep
	@cp -p Makefile script swallow*.R *.out *.log ../tests32-keep

package: summary timing
	@chmod 644 */DESCRIPTION
	@for f in *.out; do \
	  cp `basename $$f .out`/DESCRIPTION `basename $$f .out`.Rcheck/00package.dcf; \
	done
	@gtar jcf Sparc.tar.bz2 *.Rcheck/00check.log *.Rcheck/00install.out *.Rcheck/00package.dcf
	@scp -q Sparc.tar.bz2 gannet:/data/gannet/Rlogs

summary:
	@Rscript ../summary.R
	@scp -pq check.csv gannet:/data/gannet/Rlogs/Sparc-check.csv

timing:
	@Rscript ../check_times.R
	@scp -pq timings.tab gannet:/data/gannet/Rlogs/Sparc-times.tab

rgl-clean:
	@rm -rf $(RGL_USERS)

rgl-make:
	./script-for-rgl2 $(RGL_USERS)

clean:
	find * -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

rm-recommended:
	rm -rf KernSmooth.* MASS.* Matrix.* boot.* class.* cluster.* \
	  codetools.* foreign.* lattice.* mgcv.* nlme.* nnet.* \
	  rpart.log rpart.out spatial.* survival.*

cp-recommended:
	(cd ../tests-pre-keep; cp -p KernSmooth.out MASS.out Matrix.out \
	  boot.out class.out cluster.out \
	  codetools.out foreign.out lattice.out mgcv.out nlme.out nnet.out \
	  rpart.out spatial.out survival.out ../tests32)
