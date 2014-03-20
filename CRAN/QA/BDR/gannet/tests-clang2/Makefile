RDEV=/data/gannet/ripley/R/R-clang2/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-clang:~/R/test-Omegahat

include ../Makefile.common


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	@echo ... $* done

all:
	@make unpack
	@script
	@make process

process:
	@-rm /data/ftp/pub/bdr/memtests/UBSAN/*.Rout
	@/data/gannet/ripley/R/R-clang2/bin/Rscript process.R

check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@Rscript unpack.R
