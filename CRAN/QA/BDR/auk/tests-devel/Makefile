RDEV = Rdev
RLIBS=~/R/test-3.1

include ../Makefile.common

%.out: %.in
	@echo $* ...
	-@rm -f $*/src/*o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup
	@make unpack
	@script

check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

backup:
	@cp -p Makefile script unpack.sh unpack.R *.out ../tests-devel-keep

unpack:
	@Rscript unpack.R
