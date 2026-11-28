RDEV=/data/gannet/ripley/R/clang19/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-clan19g:~/R/test-BioCdata

include ../Makefile.common

## parallel install mucks up output
APAtree-VARS  = MAKE=make MAKEFLAGS=
EloSteepness-VARS = MAKE=make MAKEFLAGS=
EpiNow2-VARS  = MAKE=make MAKEFLAGS=
fastclime-VARS = MAKE=make MAKEFLAGS=
JHM-VARS = MAKE=make MAKEFLAGS=
MIRES-VARS = MAKE=make MAKEFLAGS=
MeshesTools-VARS = MAKE=make MAKEFLAGS=
MetricGraph-VARS = MAKE=make MAKEFLAGS=
MinkowskiSum-VARS = MAKE=make MAKEFLAGS=
RcppBDT-VARS = MAKE=make MAKEFLAGS=
RcppQuantuccia-VARS = MAKE=make MAKEFLAGS=
RobKF-VARS = MAKE=make MAKEFLAGS=
RoBTT-VARS = MAKE=make MAKEFLAGS=
bakR-VARS = MAKE=make MAKEFLAGS=
bayesforecast-VARS = MAKE=make MAKEFLAGS=
bmgarch-VARS = MAKE=make MAKEFLAGS=
baldur-VARS = MAKE=make MAKEFLAGS=
cgalMeshes-VARS = MAKE=make MAKEFLAGS=
expertsurv-VARS = MAKE=make MAKEFLAGS=
glmmPen-VARS = MAKE=make MAKEFLAGS=
hbamr-VARS = MAKE=make MAKEFLAGS=
locfit-VARS = MAKE=make MAKEFLAGS=
measr-VARS = MAKE=make MAKEFLAGS=
mmrm-VARS = MAKE=make MAKEFLAGS=
networkscaleup-VARS = MAKE=make MAKEFLAGS=
prioriactions-VARS = MAKE=make MAKEFLAGS=
prioritizr-VARS = MAKE=make MAKEFLAGS=
qlcal-VARS = MAKE=make MAKEFLAGS=
rater-VARS = MAKE=make MAKEFLAGS=
qtl2-VARS = MAKE=make MAKEFLAGS=
rgeoda-VARS = MAKE=make MAKEFLAGS=
rmBayes-VARS = MAKE=make MAKEFLAGS=
rts2-VARS = MAKE=make MAKEFLAGS=
ruimtehol-VARS = MAKE=make MAKEFLAGS=
rxode2ll-VARS = MAKE=make MAKEFLAGS=
simmer-VARS = MAKE=make MAKEFLAGS=
spNetwork-VARS = MAKE=make MAKEFLAGS=
volesti-VARS = MAKE=make MAKEFLAGS=

#lifecontingencies-OPTS =

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	-@cp -p $*.Rcheck/00install.out $*.log
	@chmod 644 $*/DESCRIPTION
	@cp $*/DESCRIPTION $*.Rcheck/00package.dcf
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

all:
	@make backup unpack
	@RunScript
	#@make package process

check: $(OUTS)

backup:
	@mkdir -p ../tests-clang-keep
	@cp -p Makefile pkgdiff RunScript unpack.R process.R *.out *.log ../tests-clang-keep

package: summary timing
	@tar cf clang.tar [A-c]*.Rcheck/00*
	@tar rf clang.tar [d-q]*.Rcheck/00*
	@tar rf clang.tar [r-z]*.Rcheck/00*
	@xz -f clang.tar
	-@mv /data/gannet/Rlogs/clang.tar.xz /data/gannet/Rlogs/clang.tar.xz.prev
	@cp -p clang.tar.xz /data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/clang-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	-@mv /data/gannet/Rlogs/clang-times.tab /data/gannet/Rlogs/clang-times.tab-prev
	@cp -p timings.tab /data/gannet/Rlogs/clang-times.tab


clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-m]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [n-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
