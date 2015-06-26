RDEV=/data/gannet/ripley/R/R-clang/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-clang:~/R/test-Omegahat

include ../Makefile.common

## C++ interfaces
RProtoBuf-OPTS = --install=fake
RQuantLib-OPTS = --install=fake
RVowpalWabbit-OPTS = --install=fake

## parallel install mucks up output
Boom-VARS = MAKE=make MAKEFLAGS=
OpenMx-VARS = MAKE=make MAKEFLAGS=
RcppMLPACK-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
pcalg-VARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=
rgdal-VARS = MAKE=make MAKEFLAGS=



%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	@echo ... $* done

all:
	@make backup unpack
	@script
	@make package

check: $(OUTS)

backup:
	@mkdir -p ../tests-clang-keep
	@cp -p Makefile pkgdiff script unpack.R *.out ../tests-clang-keep

package: summary timing
	@chmod 644 */DESCRIPTION
	@for f in *.in; do \
	  cp `basename $$f .in`/DESCRIPTION `basename $$f .in`.Rcheck/00package.dcf; \
	done
	@tar jcf clang.tar.bz2 *.Rcheck/00*
	@cp -p clang.tar.bz2 /data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/clang-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	@cp -p timings.tab /data/gannet/Rlogs/clang-times.tab


clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R
