RDEV=/data/gannet/ripley/R/OpenBLAS/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-3.5

include ../Makefile.common

prc-OPTS=--no-tests


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@chmod 644 $*/DESCRIPTION
	@cp $*/DESCRIPTION $*.Rcheck/00package.dcf
	@rm -rf $*
	@echo ... $* done

all:
	@make backup unpack
	@script
	@make package

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile pkgdiff script unpack.R  *.out ../tests-devel-keep

package: summary timing
	@tar Jcf gcc.tar.xz *.Rcheck/00*
	@cp gcc.tar.xz /data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/gcc-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	@cp -p timings.tab /data/gannet/Rlogs/gcc-times.tab

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript ~/R/packages/tests-devel/unpack.R