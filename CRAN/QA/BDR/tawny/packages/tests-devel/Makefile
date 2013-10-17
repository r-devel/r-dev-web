RDEV=Rdev
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.1

include ../Makefile.common

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile script unpack.R *.out ../tests-devel-keep

clean:
	@rm -f *.in
	@-rm -r *.Rcheck
	find * -maxdepth 0 -type d -exec rm -rf {} \;

veryclean:
	@rm -f *.in
	@rm -f *.out
	@-rm -r *.Rcheck
	@find * -maxdepth 0 -type d -exec rm -rf {} \;


unpack:
	@Rscript unpack.R

