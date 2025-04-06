.PHONY: clean check backup summary timing veryclean unpack

RDEV = R-SAN
R_OPTS = --check-subdirs=yes-maybe --no-stop-on-test-error --extra-arch --install-args='--dsym'
RLIBS = ~/R/Library:~/R/Library

include ../Makefile.common
include ../Makefile.parallel
cubature-VARS = MAKE=make MAKEFLAGS=
sparsegl-VARS = MAKE=make MAKEFLAGS=

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@echo ... $* done

all:
	@make backup unpack
	@RunScript

check: $(OUTS)

backup:
	@mkdir -p ../tests-SAN-keep
	@cp -p Makefile pkgdiff RunScript unpack.R summary.R ../tests-SAN-keep
	@cp -p *.out *.log ../tests-SAN-keep

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
	@/Users/ripley/R/R-devel/bin/Rscript unpack.R

summary:
	@/Users/ripley/R/R-devel/bin/Rscript summary.R
