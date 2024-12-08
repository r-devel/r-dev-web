RDEV=/data/gannet/ripley/R/gcc15/bin/R
#R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-dev:~/R/test-BioCdata

include ../Makefile.common

Rserve-OPTS ='--configure-args=--without-server'

%.out: %.in
	@/bin/echo $* ...
	 @rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	@mkdir -p ~/R/packages/tests-strict/Libs/$*-lib
	-+@R_LIBS=$(RLIBS) MAKE=make MAKEFLAGS= time -f "Time %E, %U + %S" $(RDEV) CMD INSTALL -l ~/R/packages/tests-strict/Libs/$*-lib $(R_OPTS) $($*-OPTS) $* >$@ 2>&1
	@rm -rf $*
	@rm -rf ~/R/packages/tests-strict/Libs/$*-lib
	@/bin/echo ... $* done

all:
	@make unpack
	@RunScript
	@make summary process

check: $(OUTS)


clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-m]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [n-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R

summary::
	@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R
#	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
