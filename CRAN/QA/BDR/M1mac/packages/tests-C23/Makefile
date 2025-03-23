.PHONY: clean check backup summary timing veryclean unpack

RDEV = ~/R/notC23/bin/R
RLIBS = ~/R/Library

include ../Makefile.common
include ../Makefile.parallel
cubature-VARS = MAKE=make MAKEFLAGS=
sparsegl-VARS = MAKE=make MAKEFLAGS=

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	 @mkdir -p ~/R/packages/tests-C23/Libs/$*-lib
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD INSTALL -l ~/R/packages/tests-C23/Libs/$*-lib $* > $@ 2>&1
	@rm -rf $*
	@rm -rf ~/R/packages/tests-C23/Libs/$*-lib
	@echo ... $* done

all:
	@make unpack
	@RunScript

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile RunScript unpack.R ../tests-devel-keep
	@cp -p *.out *.log ../tests-devel-keep

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
	@/Users/ripley/R/R-devel/bin/Rscript unpack.R
