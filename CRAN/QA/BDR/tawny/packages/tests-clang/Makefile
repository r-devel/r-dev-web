RDEV=/Users/ripley/R/R-clang/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.0

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
check0: $(OUTS0)

backup:
	@mkdir -p ../tests-keep
	@cp -p Makefile script unpack.sh *.out ../tests-clang-keep

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-@sh unpack.sh

rgl-clean:
	@rm -rf $(RGL_USERS)

rgl-make:
	./script2 $(RGL_USERS)
