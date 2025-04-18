RDEV=/data/gannet/ripley/R/R-devel/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-dev:~/R/test-BioCdata

include ../Makefile.common

#prc-OPTS=--no-tests


%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@chmod 644 $*/DESCRIPTION
	@cp $*/DESCRIPTION $*.Rcheck/00package.dcf
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

all:
	@make backup unpack
	@RunScript
	@make package process

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile PkgDiff RunScript unpack.R *.out *.log ../tests-devel-keep

package: summary timing
	@tar cf gcc.tar [A-c]*.Rcheck/00*
	@tar rf gcc.tar [d-q]*.Rcheck/00*
	@tar rf gcc.tar [r-z]*.Rcheck/00*
	@xz -f gcc.tar
	-@mv /data/gannet/Rlogs/gcc.tar.xz /data/gannet/Rlogs/gcc.tar.xz.prev
	@cp gcc.tar.xz /data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/gcc-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	-@mv /data/gannet/Rlogs/gcc-times.tab /data/gannet/Rlogs/gcc-times.tab-prev
	@cp -p timings.tab /data/gannet/Rlogs/gcc-times.tab

clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-m]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [n-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
