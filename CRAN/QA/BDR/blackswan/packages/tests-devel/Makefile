RDEV=/data/blackswan/ripley/R/R-devel/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/R-devel/site-library

.PHONY: all check clean veryclean unpack


include ../Makefile.common

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@/bin/echo ... $* done

dummy:
	@/bin/echo "dummy first target"

all:
	@make backup unpack
	@RunScript
	@make summary

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile pkgdiff RunScript unpack.R *.out ../tests-devel-keep

summary:
	@~/R/R-devel/bin/Rscript summary.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@~/R/R-devel/bin/Rscript unpack.R
