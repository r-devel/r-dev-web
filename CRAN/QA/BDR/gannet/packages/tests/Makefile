RDEV = Rpat
R_OPTS = --check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS = ~/R/test-pat

include ../Makefile.common
#prc-OPTS = --no-tests


%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@cp -p $*.Rcheck/00install.out $*.log
	@rm -r $*.Rcheck/$*
	@/bin/echo ... $* done

all:
	@make backup unpack
	@./RunScript

check: $(OUTS)

backup:
	@mkdir -p ../tests-keep
	@cp -p Makefile pkgdiff RunScript unpack.R  *.out ../tests-keep

clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-patched/bin/Rscript unpack.R
