RDEV=/data/gannet/ripley/R/clang22/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-clang22:~/R/test-clang:~/R/test-BioCdata

include ../Makefile.common

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	-@cp -p $*.Rcheck/00install.out $*.log
	@chmod 644 $*/DESCRIPTION
	@cp $*/DESCRIPTION $*.Rcheck/00package.dcf
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

all:
	@make unpack
	@RunScript

check: $(OUTS)

summary:
	@/usr/local/bin/Rscript ../summary.R
	@cp -p check.csv /data/gannet/Rlogs/gcc-check.csv

clean:
	find [A-Z]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [a-m]* -maxdepth 0 -type d -exec rm -rf {} \;
	find [n-z]* -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R

process:
	@/data/gannet/ripley/R/R-clang/bin/Rscript process.R
