.PHONY: clean check backup summary timing veryclean unpack

RDEV=~/R/newAccelerate/bin/R
#RDEV=~/R/R-Accelerate/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/Library

include ../Makefile.common
include ../Makefile.parallel
cubature-VARS = MAKE=make MAKEFLAGS=

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@echo ... $* done

all:
	@make unpack
	@RunScript

check: $(OUTS)

timing:
	@/Users/ripley/R/R-devel/bin/Rscript ../check_times.R


clean:
	-@rm -f *.in
	-@rm -rf *.Rcheck
	@find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	@find [a-l]* -maxdepth 0 -type d -exec rm -rf {} \;
	@find [m-z]* -maxdepth 0 -type d -exec rm -rf {} \;

veryclean: clean
	-@rm -f *.out
	-@rm -f *.log
	-@rm -f check_log

unpack:
	@/Users/ripley/R/R-devel/bin/Rscript unpack2.R

unpack0:
	@/Users/ripley/R/R-devel/bin/Rscript unpack.R
