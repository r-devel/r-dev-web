.SUFFICES: .out .log

RDEV=/home/ripley/R/cc/bin/R
RLIBS=/home/ripley/R/Lib32
BACKUP=../tests32-keep

## hit CPU limit
AGSDest-OPTS = --no-vignettes
BB-OPTS = --no-tests --no-vignettes
BMS-OPTS = --no-vignettes
ChemoSpec-OPTS = --no-rebuild-vignettes
CONOR-OPTS = --no-examples
CDVine-OPTS = --no-rebuild-vignettes
DAKS-OPTS = --no-vignettes
DDD-OPTS = --no-examples
DOBAD-OPTS = --no-vignettes
GOGANPA-OPTS = --no-examples
GSM-OPTS = --no-examples
GenABEL-OPTS = --no-examples
HiveR-OPTS = --no-vignettes
LaplacesDemon-OPTS = --no-vignettes
LogConcDEAD-OPTS = --no-vignettes
MetabolAnalyze-OPTS = --no-examples
ModelMap-OPTS = --no-vignettes
NMF-OPTS = --no-vignettes
PerformanceAnalytics-OPTS = --no-vignettes
#RFinanceYJ-OPTS = --no-examples
SNPRelate-OPTS = --no-examples --no-tests --no-vignettes
SpatialVX-OPTS = --no-examples
STAR-OPTS = --no-vignettes
Sim.DiffProc-OPTS = --no-examples --no-tests
StatMatch-OPTS = --no-vignettes
VGAM-OPTS = --no-vignettes
ZeligGAM-OPTS = --no-vignettes
abc-OPTS = --no-vignettes
adehabitatLT-OPTS = --no-examples --no-vignettes
amei-OPTS = --no-vignettes
amer-OPTS = --no-tests --no-vignettes
apcluster-OPTS = --no-vignettes
aspect-OPTS = --no-vignettes
bcrm-OPTS = --no-examples
bfp-OPTS = --no-tests
caret-OPTS = --no-vignettes
copula-OPTS = --no-vignettes
coxphf-OPTS = --no-examples
crimCV-OPTS = --no-examples
crs-OPTS = --no-vignettes
dismo-OPTS = --no-vignettes
dse-OPTS = --no-tests
eqtl-OPTS = --no-examples
expectreg-OPTS = --no-examples --no-vignettes --no-tests
fanplot-OPTS = --no-vignettes
fda-OPTS = --no-examples
flexclust-OPTS = --no-tests
geozoo-OPTS = --no-examples
iSubpathwayMiner-OPTS = --no-vignettes
lokern-OPTS = --no-examples --no-tests
lossDev-OPTS = --no-vignettes
mcmc-OPTS = --no-rebuild-vignettes
mediation-OPTS = --no-vignettes
micEconCES-OPTS = --no-tests --no-vignettes
modTempEff-OPTS = --no-vignettes
monomvn-OPTS = --no-examples
nFactors-OPTS = --no-vignettes
np-OPTS = --no-examples --no-vignettes
nsRFA-OPTS = --no-vignettes
phangorn-OPTS = --no-vignettes
phylosim-OPTS = --no-vignettes
pomp-OPTS = --no-tests --no-vignettes
psych-OPTS = --no-vignettes
psychomix-OPTS = --no-vignettes
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
twang-OPTS = --no-vignettes
unmarked-OPTS = --no-vignettes
vines-OPTS = --no-tests

## multicore
adegenet-OPTS = --no-vignettes
multicore-OPTS = --no-examples
mboost-OPTS = --no-vignettes
spikeSlabGAM-OPTS = --no-examples --no-vignettes

## OpenMP
sme-OPTS = --no-examples --no-vignettes --no-tests

## slow/broken web access
DSPRqtl-OPTS = --no-vignettes
NCBI2R-OPTS = --no-examples
RLastFM-OPTS = --no-examples
TSgetSymbol-OPTS = --no-examples --no-vignettes
atmi-OPTS = --no-examples
celsius-OPTS = --no-examples
speedglm-OPTS = --no-examples
elliptic-OPTS = --no-vignettes
misc3d-OPTS = --no-examples
gstudio-OPTS = --no-vignettes
XML-OPTS = --no-examples
SSOAP-OPTS = --no-examples

## tries to use RMySQL
vegdata-OPTS = --no-vignettes
TSdata-OPTS = --no-vignettes

DSL-OPTS = --no-vignettes
vegan-OPTS = --no-rebuild-vignettes


## crash etc
FracSim-OPTS=--no-examples

include Makefile.fakes

RGL_USERS = \
    AER.out CADStat.out ChemoSpec.out DiceDesign.out DiceView.out \
    FieldSim.out GeoXp.out MCMCglmm.out NeatMap.out VecStatGraphs3D.out \
    bpca.out cems.out compositions.out dti.out \
    edrGraphicalTools.out feature.out grt.out hgam.out homals.out \
    ks.out misc3d.out mixOmics.out msr.out qpcR.out \
    phangorn.out raster.out rgl.out seewave.out shapes.out sm.out smacof.out \
    tolerance.out vcdExtra.out \
    ENmisc.out RcmdrPlugin.mosaic.out LMERConvenienceFunctions.out Rknots.out \
    rasterVis.out KernSmoothIRT.out alphashape3d.out StatDA.out \
    curvHDR.out ptinpoly.out DirichletReg.out abcdeFBA.out HiveR.out \
    genridge.out StructR.out WMTregions.out caret.out lle.out bios2mds.out \
    spatgraphs.out hiPOD.out R330.out MSQC.out phytools.out depth.out \
    sphereplot.out visreg.out kml3d.out longitudinalData.out


%.out: %.log
	@echo $* ...
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) -l $(RLIBS) --install=check:$*.log $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

Rcpp.out:
	@touch Rcpp.log
	@rm -rf Rcpp
	@gtar xf ../contrib/Rcpp_*.tar.gz
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time $(RDEV) CMD check $(R_OPTS) Rcpp > Rcpp.out 2>&1

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
	@mkdir -p $(BACKUP)
	@cp -p Makefile script script-for-rgl2 pkgdiff common.R swallow*.R *.out *.log $(BACKUP)

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
