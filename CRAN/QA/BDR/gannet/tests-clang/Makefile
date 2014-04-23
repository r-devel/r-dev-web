RDEV=/data/gannet/ripley/R/R-clang/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-clang:~/R/test-Omegahat

include ../Makefile.common

## crash etc
ptinpoly-OPTS = --no-examples

RProtoBuf-OPTS = --install=fake
RQuantLib-OPTS = --install=fake


%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
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
	@Rscript unpack.R
