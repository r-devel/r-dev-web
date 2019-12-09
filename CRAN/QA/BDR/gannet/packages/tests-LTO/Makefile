RDEV=/data/gannet/ripley/R/LTO9/bin/R
RLIBS=~/R/test-4.0

include ../Makefile.common
Rserve-OPTS = '--configure-args=--without-server'
udunits2-OPTS = '--configure-args=--with-udunits2-include=/usr/include/udunits2'


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	@mkdir -p ~/R/packages/tests-LTO/Libs/$*-lib
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= R_MAKEVARS_USER=$(R_MAKEVARS) time -f "Time %E, %U + %S" $(RDEV) CMD INSTALL -l ~/R/packages/tests-LTO/Libs/$*-lib $($*-OPTS) $* >$@ 2>&1
	@rm -rf $*
	@rm -rf ~/R/packages/tests-LTO/Libs/$*-lib
	@echo ... $* done

dummy:
	@echo "dummy first target"

all:
	@make unpack
	@./script
	@make process

check: $(OUTS)

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in
	rm -rf Libs

veryclean: clean
	rm -f *.out check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R
