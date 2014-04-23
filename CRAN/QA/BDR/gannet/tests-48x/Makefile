RDEV=/data/gannet/ripley/R/gcc48x/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.2:~/R/test-Omegahat

include ../Makefile.common
BRugs-OPTS = --install=fake

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@.tmp 2>&1 
	@cat $@.tmp | asan_symbolize.py | c++filt > $@
	-@rm -f $@.tmp
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@mkdir -p ../tests-48x-keep
	@cp -p Makefile pkgdiff script *.out ../tests-48x-keep

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@Rscript ../tests-devel/unpack.R
