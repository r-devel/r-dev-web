.PHONY: clean check backup package summary timing veryclean unpack unpack

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
	@cp -p [a-l]*.out ../tests-keep
	@cp -p [m-z]*.out ../tests-keep

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
	@/Users/ripley/R/R-patched/bin/Rscript unpack.R

unpack2:
	@/Users/ripley/R/R-patched/bin/Rscript unpack2.R