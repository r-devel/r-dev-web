RDEV=Rpat
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.3

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
	@cp -p Makefile script script2 unpack.R *.out ../tests-keep

clean:
	-@rm -r *.Rcheck
	@find * -maxdepth 0 -type d -exec rm -rf {} \;
	-@rm -f *.in

veryclean:
	-@rm -f *.in
	-@rm -f *.out
	-@rm -rf *.Rcheck
	@find * -maxdepth 0 -type d -exec rm -rf {} \;

unpack:
	@Rscript unpack.R

