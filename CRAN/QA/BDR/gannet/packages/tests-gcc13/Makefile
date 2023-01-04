RDEV=/data/gannet/ripley/R/R-gcc13/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-dev

include ../Makefile.common
bayes4psy-VARS = MAKE=make MAKEFLAGS=
rmumps-VARS = MAKE=make MAKEFLAGS=


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@echo ... $* done

dummy:
	@echo "dummy first target"

all:
	@make unpack
	@./script
	@make summary0

check: $(OUTS)

backup:
	mkdir -p ../tests-gcc13-keep
	@cp -p Makefile pkgdiff script unpack.R *.out *.log ../tests-gcc13-keep

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R

unpackall:
	@/data/gannet/ripley/R/R-devel/bin/Rscript ../tests-devel/unpack.R

summary:
	@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R | less

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R

summary0:
	-@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R

