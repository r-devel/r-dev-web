RDEV=/data/gannet/ripley/R/R-clang-SAN/bin/R
R_OPTS=--check-subdirs=yes-maybe --extra-arch --no-stop-on-test-error
RLIBS=~/R/test-clang-SAN:~/R/test-clang

include ../Makefile.common

## parallel install mucks up output
Boom-VARS = MAKE=make MAKEFLAGS=
EcoEnsemble-VARS = MAKE=make MAKEFLAGS=
OpenMx-VARS = MAKE=make MAKEFLAGS=
QFASA-VARS = MAKE=make MAKEFLAGS=
RcppMLPACK-VARS = MAKE=make MAKEFLAGS=
RcppShark-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
gaston-VARS = MAKE=make MAKEFLAGS=
mixedMem-VARS = MAKE=make MAKEFLAGS=
pcalg-VARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=
rgdal-VARS = MAKE=make MAKEFLAGS=
spsurv-VARS = MAKE=make MAKEFLAGS=

crmPack-OPTS = --no-vignettes
rmetasim-OPTS = --no-vignettes
skm-OPTS = --no-vignettes
walker-OPTS = --no-vignettes

## parallel install mucks up output
APAtree-VARS  = MAKE=make MAKEFLAGS=
EloSteepness-VARS  = MAKE=make MAKEFLAGS=
fastclime-VARS = MAKE=make MAKEFLAGS=
MIRES-VARS = MAKE=make MAKEFLAGS=
MeshesTools-VARS = MAKE=make MAKEFLAGS=
MinkowskiSum-VARS = MAKE=make MAKEFLAGS=
RcppBDT-VARS = MAKE=make MAKEFLAGS=
RobKF-VARS = MAKE=make MAKEFLAGS=
bmggum-VARS = MAKE=make MAKEFLAGS=
bmgarch-VARS = MAKE=make MAKEFLAGS=
disbayes-VARS = MAKE=make MAKEFLAGS=
glmmPen-VARS = MAKE=make MAKEFLAGS=
locfit-VARS = MAKE=make MAKEFLAGS=
networkscaleup-VARS = MAKE=make MAKEFLAGS=
opera-VARS = MAKE=make MAKEFLAGS=
paropt-VARS = MAKE=make MAKEFLAGS=
prioritizr-VARS = MAKE=make MAKEFLAGS=
rgeoda-VARS = MAKE=make MAKEFLAGS=
rxode2ll-VARS = MAKE=make MAKEFLAGS=
simmer-VARS = MAKE=make MAKEFLAGS=
spNetwork-VARS = MAKE=make MAKEFLAGS=


%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

dummy:
	@/bin/echo "dummy first target"

all:
	-@make backup
	@make unpack
	@./script
	@make process

check: $(OUTS)

backup:
	@mkdir -p ../tests-clang-SAN-keep
	@-cp -p Makefile pkgdiff script process.R process2.R unpack.R *.out ../tests-clang-SAN-keep

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-ASAN
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-UBSAN
	@/data/gannet/ripley/R/R-devel/bin/Rscript process2.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R
