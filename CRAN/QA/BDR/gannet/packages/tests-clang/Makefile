RDEV=/data/gannet/ripley/R/R-clang/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-clang

include ../Makefile.common

## parallel install mucks up output
APAtree-VARS  = MAKE=make MAKEFLAGS=
BayesXsrc-VARS = MAKE=make MAKEFLAGS=
BINtools-VARS = MAKE=make MAKEFLAGS=
Boom-VARS = MAKE=make MAKEFLAGS=
Matrix-VARS = MAKE=make MAKEFLAGS=
OpenMx-VARS = MAKE=make MAKEFLAGS=
RcppMLPACK-VARS = MAKE=make MAKEFLAGS=
RcppShark-VARS = MAKE=make MAKEFLAGS=
SimilaR-VARS = MAKE=make MAKEFLAGS=
bws-VARS = MAKE=make MAKEFLAGS=
#cld3-VARS = MAKE=make MAKEFLAGS=
delaunay-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
fastclime-VARS = MAKE=make MAKEFLAGS=
gaston-VARS = MAKE=make MAKEFLAGS=
locfit-VARS = MAKE=make MAKEFLAGS=
mixedMem-VARS = MAKE=make MAKEFLAGS=
networkscaleup-VARS = MAKE=make MAKEFLAGS=
parsermd-VARS = MAKE=make MAKEFLAGS=
pcalg-VARS = MAKE=make MAKEFLAGS=
qlcal-VARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=
rgdal-VARS = MAKE=make MAKEFLAGS=
rmBayes-VARS = MAKE=make MAKEFLAGS=
rmumps-VARS = MAKE=make MAKEFLAGS=
wellknown-VARS = MAKE=make MAKEFLAGS=

lifecontingencies-OPTS =




%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	-@cp -p $*.Rcheck/00install.out $*.log
	@chmod 644 $*/DESCRIPTION
	@cp $*/DESCRIPTION $*.Rcheck/00package.dcf
	@rm -rf $* $*.Rcheck/$*
	@echo ... $* done

all:
	@make backup unpack
	@script
	@make package process

check: $(OUTS)

backup:
	@mkdir -p ../tests-clang-keep
	@cp -p Makefile pkgdiff script unpack.R process.R *.out *.log ../tests-clang-keep

package: summary timing
	@tar cf clang.tar [A-f]*.Rcheck/00*
	@tar rf clang.tar [g-z]*.Rcheck/00*
	@xz -f clang.tar
	@mv /data/gannet/Rlogs/clang.tar.xz /data/gannet/Rlogs/clang.tar.xz.prev
	@cp -p clang.tar.xz /data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/clang-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	@cp -p timings.tab /data/gannet/Rlogs/clang-times.tab


clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@/data/gannet/ripley/R/R-devel/bin/Rscript process15.R
