RDEV=/data/gannet/ripley/R/R-clang37/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-clang:~/R/test-Omegahat

include ../Makefile.common

## parallel mucks up output
Boom-VARS = MAKE=make MAKEFLAGS=
RcppMLPACK-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	@echo ... $* done

all:
	@make backup unpack
	@./script
	@make process

check: $(OUTS)

backup:
	@mkdir -p ../tests-clang37-keep
	@-cp -p Makefile pkgdiff script process.R unpack.R *.out ../tests-clang37-keep

process:
	@-rm -rf /data/ftp/pub/bdr/memtests/clang-*/*
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-ASAN
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-UBSAN

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R
