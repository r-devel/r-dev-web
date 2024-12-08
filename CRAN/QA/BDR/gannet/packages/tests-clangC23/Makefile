RDEV=~/R/C23/bin/R
R_OPTS = 
RLIBS=~/R/test-clang:~/R/test-BioCdata

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

dummy:
	@/bin/echo "dummy first target"

all:
	@make unpack
	-@./RunScript
#	@make summary
	@make process

check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in
	rm -rf Libs

veryclean: clean
	rm -f *.out check_log

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R

summary:
	@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R

