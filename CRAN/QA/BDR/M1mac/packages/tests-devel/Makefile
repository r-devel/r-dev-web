.PHONY: clean check backup package summary timing veryclean unpack unpack2

RDEV=Rd
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/Library

include ../Makefile.common

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile pkgdiff script script2 unpack.R unpack2.R ../tests-devel-keep
	@cp -p [A-Z]*.out ../tests-devel-keep
	@cp -p [a-l]*.out ../tests-devel-keep
	@cp -p [m-z]*.out ../tests-devel-keep

summary:
	@/Users/ripley/R/R-devel/bin/Rscript ../summary.R

timing:
	@/Users/ripley/R/R-devel/bin/Rscript ../check_times.R


clean:
	-@rm -f [A-Z]*.in; rm -f [a-l]*.in; rm -f [m-z]*.in
	-@rm -rf [A-Z]*.Rcheck; rm -rf [a-l]*.Rcheck; rm -rf [m-z]*.Rcheck
	@find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	@find [a-l]* -maxdepth 0 -type d -exec rm -rf {} \;
	@find [m-z]* -maxdepth 0 -type d -exec rm -rf {} \;

veryclean: clean
	-@rm -f [A-Z]*.out; rm -f [a-l]*.out; rm -f [m-z]*.out
	-@rm -f check_log

unpack:
	@/Users/ripley/R/R-devel/bin/Rscript unpack.R

unpack2:
	@/Users/ripley/R/R-devel/bin/Rscript unpack2.R
