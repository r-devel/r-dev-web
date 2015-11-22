RDEV=/data/blackswan/ripley/R/R-devel/bin/R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/R-devel/site-library

include ../Makefile.common

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile pkgdiff script unpack.R *.out ../tests-devel-keep

package: summary timing
	@chmod 644 */DESCRIPTION
	@for f in *.in; do \
	  cp `basename $$f .in`/DESCRIPTION `basename $$f .in`.Rcheck/00package.dcf; \
	done
	@tar jcf gcc.tar.bz2 *.Rcheck/00*
	@scp -pq gcc.tar.bz2 gannet:/data/gannet/Rlogs

summary:
	@/usr/local/bin/Rscript ../summary.R
	@scp -pq check.csv gannet:/data/gannet/Rlogs/gcc-check.csv

timing:
	@/usr/local/bin/Rscript ../check_times.R
	@scp -pq timings.tab gannet:/data/gannet/Rlogs/gcc-times.tab

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@Rscript unpack.R
