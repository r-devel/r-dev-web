RDEV=/data/gannet/ripley/R/gcc-trunk/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.3:~/R/test-Omegahat

include ../Makefile.common

crmPack-OPTS = --no-vignettes
prc-OPTS=--no-tests


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@mkdir -p ../tests-60-keep
	@cp -p Makefile pkgdiff script unpack.R *.out ../tests-60-keep

process:
	@-rm -rf /data/ftp/pub/bdr/memtests/gcc-*/*
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/gcc-ASAN
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/gcc-UBSAN

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@Rscript unpack.R
