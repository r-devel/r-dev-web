RDEV=/data/gannet/ripley/R/gcc5/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.2:~/R/test-Omegahat

include ../Makefile.common
BRugs-OPTS = --install=fake

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
	@mkdir -p ../tests-50-keep
	@-cp -p Makefile pkgdiff script process.R *.out ../tests-50-keep

process:
	@-rm -rf /data/ftp/pub/bdr/memtests/UBSAN-gcc/*
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@ln -s /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/UBSAN-gcc

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@Rscript ../tests-49x/unpack.R
