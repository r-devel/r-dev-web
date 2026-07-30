RDEV=/data/localhost/ripley/R/R-devel/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-dev:~/R/test-BioCdata


.PHONY: all check clean veryclean unpack


include ../Makefile.common

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

dummy:
	@/bin/echo "dummy first target"

all:
	@make backup unpack
	@RunScript
	@make summary process

check: $(OUTS)

backup:
	@mkdir -p ../tests-donttest-keep
	@cp -pr Makefile PkgDiff  RunScript unpack.R *.out *.log ../tests-donttest-keep

summary:
	@~/R/R-devel/bin/Rscript summary.R

process:
	@~/R/R-devel/bin/Rscript process.R

clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-m]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [n-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@~/R/R-devel/bin/Rscript unpack.R
