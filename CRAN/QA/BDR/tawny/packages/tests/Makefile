#RDEV=Rpat
RDEV=R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-4.0

include ../Makefile.common

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@mkdir -p ../tests-keep
	@cp -p Makefile script unpack.R ../tests-keep
	@cp -p [A-Z]*.out ../tests-keep
	@cp -p [a-z]*.out ../tests-keep

clean:
	-@rm -f [A-Z]*.in; rm -f [a-z]*.in
	-@rm -rf {A-Z]*.Rcheck; rm -rf [a-z]*.Rcheck
	@find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	@find [a-z]* -maxdepth 0 -type d -exec rm -rf {} \;

veryclean:
	-@rm -f [A-Z]*.in; rm -f [a-z]*.in
	-@rm -f [A-Z]*.out; rm -f [a-z]*.out
	-@rm -rf {A-Z]*.Rcheck; rm -rf [a-z]*.Rcheck
	@find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	@find [a-z]* -maxdepth 0 -type d -exec rm -rf {} \;

unpack:
	@/Users/ripley/R/R-patched/bin/Rscript unpack.R

unpack2:
	@/Users/ripley/R/R-patched/bin/Rscript unpack2.R
