RDEV=~/R/cxx20/bin/R
RLIBS = ~/R/Library

include ../Makefile.common
include ../Makefile.parallel
cubature-VARS = MAKE=make MAKEFLAGS=
sparsegl-VARS = MAKE=make MAKEFLAGS=

Rserve-OPTS = '--configure-args=--without-server'
udunits2-OPTS = '--configure-args=--with-udunits2-include=/usr/include/udunits2'


%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	@mkdir -p ~/R/packages/tests-CXX20/Libs/$*-lib
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time  $(RDEV) CMD INSTALL -l ~/R/packages/tests-CXX20/Libs/$*-lib $(R_OPTS) $($*-OPTS) $* >$@ 2>&1
	@rm -rf $*
	@rm -rf ~/R/packages/tests-CXX20/Libs/$*-lib
	@/bin/echo ... $* done

dummy:
	@/bin/echo "dummy first target"

all:
	@make unpack
	-@./RunScript

check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in
	rm -rf Libs

veryclean: clean
	rm -f *.out check_log

unpack:
	@Rscript unpack.R
