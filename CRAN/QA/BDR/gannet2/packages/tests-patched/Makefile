RDEV = Rpat
R_OPTS = --check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS = ~/R/test-pat:~/R/test-BioCdata

include ~/R/packages/Makefile.common


%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

all:
	@make backup unpack
	@./RunScript

check: $(OUTS)

backup:
	@mkdir -p ../KEEP/tests-patched-keep
	@cp -p Makefile PkgDiff pkgdiff2 RunScript unpack.R  *.out ../KEEP/tests-patched-keep

clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@~/R/R-patched/bin/Rscript unpack.R
