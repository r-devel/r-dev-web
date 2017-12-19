RDEV=/data/gannet/ripley/R/R-gcc8/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-3.5

include ../Makefile.common
prc-OPTS=--no-tests


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $*
	@echo ... $* done

dummy:
	@echo "dummy first target"

all:
	@make unpack
	@./script

check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript ../tests-devel/unpack.R
