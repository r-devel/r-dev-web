RDEV=/data/gannet/ripley/R/LTO9c/bin/R
RLIBS=~/R/test-3.7

include ../Makefile.common

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	@mkdir -p ~/R/packages/tests-LTO2/Libs/$*-lib
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= R_MAKEVARS_USER=$(R_MAKEVARS) time -f "Time %E, %U + %S" $(RDEV) CMD INSTALL -l ~/R/packages/tests-LTO2/Libs/$*-lib $* >$@ 2>&1
	@rm -rf $*
	@rm -rf ~/R/packages/tests-LTO2/Libs/$*-lib
	@echo ... $* done

dummy:
	@echo "dummy first target"

all:
	@make unpack
	@./script
	@make process

check: $(OUTS)

summary:
	@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in
	rm -rf Libs

veryclean: clean
	rm -f *.out check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R
