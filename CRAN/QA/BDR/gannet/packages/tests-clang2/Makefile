RDEV=/data/gannet/ripley/R/R-clang2/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-clang:~/R/test-Omegahat

include ../Makefile.common

## parallel mucks up output
Boom-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	@echo ... $* done

all:
	@make unpack
	@./script
	@make process

backup:
	@mkdir -p ../tests-clang2-keep
	@-cp -p Makefile pkgdiff script unpack.R *.out ../tests-clang2-keep

process:
	@-rm -rf /data/ftp/pub/bdr/memtests/UBSAN/*
	@/data/gannet/ripley/R/R-clang2/bin/Rscript process.R

check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R
