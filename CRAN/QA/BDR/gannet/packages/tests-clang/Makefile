RDEV=/data/gannet/ripley/R/R-clang/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-clang

include ../Makefile.common

## parallel install mucks up output
APAtree-VARS  = MAKE=make MAKEFLAGS=
EloSteepness-VARS  = MAKE=make MAKEFLAGS=
fastclime-VARS = MAKE=make MAKEFLAGS=
MIRES-VARS = MAKE=make MAKEFLAGS=
MeshesTools-VARS = MAKE=make MAKEFLAGS=
MinkowskiSum-VARS = MAKE=make MAKEFLAGS=
RcppBDT-VARS = MAKE=make MAKEFLAGS=
RcppQuantuccia-VARS = MAKE=make MAKEFLAGS=
bmgarch-VARS = MAKE=make MAKEFLAGS=
cgalMeshes-VARS = MAKE=make MAKEFLAGS=
glmmPen-VARS = MAKE=make MAKEFLAGS=
locfit-VARS = MAKE=make MAKEFLAGS=
networkscaleup-VARS = MAKE=make MAKEFLAGS=
prioriactions-VARS = MAKE=make MAKEFLAGS=
prioritizr-VARS = MAKE=make MAKEFLAGS=
qlcal-VARS = MAKE=make MAKEFLAGS=
rater-VARS = MAKE=make MAKEFLAGS=
rgeoda-VARS = MAKE=make MAKEFLAGS=
ruimtehol-VARS = MAKE=make MAKEFLAGS=
rxode2ll-VARS = MAKE=make MAKEFLAGS=
simmer-VARS = MAKE=make MAKEFLAGS=
spNetwork-VARS = MAKE=make MAKEFLAGS=

#lifecontingencies-OPTS =

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
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@/data/gannet/ripley/R/R-devel/bin/Rscript process15.R
