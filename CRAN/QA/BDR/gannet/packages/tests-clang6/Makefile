RDEV=/data/gannet/ripley/R/R-clang-trunk/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-clang

include ../Makefile.common

## parallel install mucks up output
Boom-VARS = MAKE=make MAKEFLAGS=
OpenMx-VARS = MAKE=make MAKEFLAGS=
RcppMLPACK-VARS = MAKE=make MAKEFLAGS=
RcppShark-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
gaston-VARS = MAKE=make MAKEFLAGS=
mixedMem-VARS = MAKE=make MAKEFLAGS=
pcalg-VARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=
rgdal-VARS = MAKE=make MAKEFLAGS=

treeHFM-OPTS = --no-examples

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
	@/data/gannet/ripley/R/R-clang/bin/Rscript ../tests-clang/unpack.R
