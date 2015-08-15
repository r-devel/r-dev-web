RDEV=Rdev
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/test-3.3

include ../Makefile.common

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script
	@make package

check: $(OUTS)

backup:
	@mkdir -p ../tests-devel-keep
	@cp -p Makefile script unpack.R *.out ../tests-devel-keep

package: summary timing
	@chmod 644 */DESCRIPTION
	@for f in *.in; do \
	  cp `basename $$f .in`/DESCRIPTION `basename $$f .in`.Rcheck/00package.dcf; \
	done
	@tar cf mavericks.tar [A-Z]*.Rcheck/00check.log
	@tar rf mavericks.tar [a-z]*.Rcheck/00check.log
	@tar rf mavericks.tar [A-Z]*.Rcheck/00install.out
	@tar rf mavericks.tar [a-z]*.Rcheck/00install.out
	@tar rf mavericks.tar [A-Z]*.Rcheck/00package.dcf
	@tar rf mavericks.tar [a-z]*.Rcheck/00package.dcf
	@rm -f mavericks.tar.bz2
	@bzip2 mavericks.tar
	@scp -pq mavericks.tar.bz2 gannet:/data/gannet/Rlogs

summary:
	@/Users/ripley/R/R-devel/bin/Rscript ../summary.R
	@scp -pq check.csv gannet:/data/gannet/Rlogs/mavericks-check.csv

timing:
	@/Users/ripley/R/R-devel/bin/Rscript ../check_times.R
	@scp -pq timings.tab gannet:/data/gannet/Rlogs/mavericks-times.tab


clean:
	-@rm -f *.in
	-@rm -r *.Rcheck
	@find * -maxdepth 0 -type d -exec rm -rf {} \;

veryclean:
	-@rm -f *.in
	-@rm -f *.out
	-@rm -r *.Rcheck
	@find * -maxdepth 0 -type d -exec rm -rf {} \;


unpack:
	@Rscript unpack.R

