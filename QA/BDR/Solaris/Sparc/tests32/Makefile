#SOURCES=${shell ls *.in}
#OUTS=$(SOURCES:.in=.out)
#LOGS=$(SOURCES:.in=.log)

.SUFFICES:
.SUFFICES: .in .out .log
RDEV=/home/ripley/R/cc/bin/R
RLIBS=/home/ripley/R/Lib32

## use foo-VARS=MAKE=make MAKEFLAGS=  to suppress parallel installs
RSiena-VARS = MAKE=gmake
Cairo-VARS = MAKE=gmake
CORElearn-VARS = MAKE=gmake
GDD-VARS = MAKE=gmake
Rserve-VARS = MAKE=gmake
JavaGD-VARS = MAKE=gmake
TSpadi-VARS = MAKE=gmake
farmR-VARS = MAKE=gmake
mspath-VARS = MAKE=gmake
phyclust-VARS = MAKE=gmake
png-VARS = MAKE=gmake
# rJava-VARS = MAKE=gmake

## Rcpp users
Rcpp-VARS = MAKE=gmake
RcppArmadillo-VARS = MAKE=gmake
RcppExamples-VARS = MAKE=gmake
RInside-VARS = MAKE=gmake
cxxPack-VARS = MAKE=gmake
highlight-VARS = MAKE=gmake
minqa-VARS = MAKE=gmake
termstrc-VARS = MAKE=gmake


## disallows Solaris
GridR-OPTS = --install=fake
cmprskContin-OPTS = --install=fake

## hit CPU limit
BB-OPTS = --no-tests --no-vignettes
GSM-OPTS = --no-examples
GenABEL-OPTS = --no-examples
LaplacesDemon-OPTS = --no-vignettes
LogConcDEAD-OPTS = --no-vignettes
MetabolAnalyze-OPTS = --no-examples
#RFinanceYJ-OPTS = --no-examples
Sim.DiffProc-OPTS = --no-examples --no-tests
adehabitatLT-OPTS = --no-examples --no-vignettes
amei-OPTS = --no-vignettes
bfp-OPTS = --no-tests
coxphf-OPTS = --no-examples
crimCV-OPTS = --no-examples
#demography-OPTS = --no-examples
dismo-OPTS = --no-vignettes
eqtl-OPTS = --no-examples
expectreg-OPTS = --no-examples --no-vignettes
flexclust-OPTS = --no-tests
geozoo-OPTS = --no-examples
iSubpathwayMiner-OPTS = --no-vignettes
lokern-OPTS = --no-examples --no-tests
lossDev-OPTS = --no-vignettes
mcmc-OPTS = --no-vignettes
micEconCES-OPTS = --no-tests --no-vignettes
nFactors-OPTS = --no-vignettes
np-OPTS = --no-examples --no-vignettes
npRmpi-OPTS = --no-examples --no-vignettes
pomp-OPTS = --no-tests
pvclust-OPTS = --no-examples
rWMBAT-OPTS = --no-examples
rattle-OPTS = --no-examples
rebmix-OPTS = --no-vignettes
remMap-OPTS = --no-examples
rphast-OPTS = --no-examples --no-tests --no-vignettes
rtfbs-OPTS = --no-examples --no-tests --no-vignettes
seriation-OPTS = --no-examples --no-vignettes
spikeSlabGAM-OPTS = --no-examples --no-vignettes
tgp-OPTS = --no-examples --no-vignettes

## multicore
mboost-OPTS = --no-vignettes


## slow/broken web access
NCBI2R-OPTS = --no-examples
RLastFM-OPTS = --no-examples
atmi-OPTS = --no-examples
celsius-OPTS = --no-examples

## leaves java instances running
#dynGraph-OPTS = --no-examples

## crash etc
#coxphf-OPTS=--no-examples
#sampfling-OPTS=--no-examples --no-tests

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

## depend on Windows (undeclared)
VhayuR-OPTS = --install=fake

## depend on JRI which needs R as shlib
gWidgetsrJava-OPTS = --install=fake

RGL_USERS = \
    AER.out CADStat.out ChemoSpec.out DiceDesign.out DiceView.out \
    FieldSim.out GeoXp.out MCMCglmm.out NeatMap.out VecStatGraphs3D.out \
    bpca.out cems.out compositions.out depth.out dti.out \
    edrGraphicalTools.out feature.out grt.out hgam.out homals.out \
    kml3d.out ks.out misc3d.out mixOmics.out msr.out qpcR.out \
    phangorn.out raster.out rgl.out seewave.out shapes.out sm.out smacof.out \
    tolerance.out vcdExtra.out \
    ENmisc.out RcmdrPlugin.mosaic.out LMERConvenienceFunctions.out Rknots.out \
    bios2mds.out rasterVis.out


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

LOGS=${shell ls *.log}
check: $(LOGS:.log=.out)

backup:
	@mkdir -p ../tests32-keep
	@cp -p Makefile script unpack.sh swallow.R *.out *.log ../tests32-keep

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

unpack:
	-@bash unpack.sh
	rm -rf RMySQL* TSMySQL* TSpadi* ROracle*
	rm -rf RGtk2.*
	rm -rf RProtoBuf* RQuantLib* SV*
	rm -rf rggobi* PKgraph* classifly* clusterfly* ripa* magnets* beadarrayMSV* WMTregions*
	rm -rf sabreR.* RBerkeley.* psgp.*
	rm -rf biganalytics.*  bigtabulate.*

rm-recommended:
	rm -f KernSmooth.* MASS.* Matrix.* boot.* class.* cluster.* \
	  codetools.* foreign.* lattice.* mgcv.* nlme.* nnet.* \
	  rpart.log rpart.out survival.*

cp-recommended:
	(cd ../tests32-keep; cp KernSmooth.out MASS.out Matrix.out \
	  boot.out class.out cluster.out \
	  codetools.out foreign.out lattice.out mgcv.out nlme.out nnet.out \
	  rpart.out spatial.out survival.out ../tests32)
