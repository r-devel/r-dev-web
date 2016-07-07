RDEV=/data/gannet/ripley/R/gcc-trunk/bin/R
R_OPTS=--check-subdirs=yes-maybe --extra-arch
RLIBS=~/R/test-3.4

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
	@./script
	@make process

check: $(OUTS)

backup:
	@mkdir -p ../tests-70-keep
	@cp -p Makefile pkgdiff script unpack.R *.out ../tests-70-keep

process:
	@-rm -rf /data/ftp/pub/bdr/memtests/gcc7-*/*
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/gcc6-ASAN
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/gcc6-UBSAN

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@Rscript unpack.R
