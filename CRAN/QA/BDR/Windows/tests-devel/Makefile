R_OPTS = --force-multiarch
RLIBS = "c:/R/test-2.15;c:/R/BioC-2.10"
RDEV = c:/R/R-devel/bin/x64/Rcmd.exe
RLIB = c:/R/test-2.15

include ../tests/Makefile.common


%.out: %.log
	@echo $* ...
	@rm -rf $*.Rcheck
	+@R_LIBS=$(RLIBS) R_BROWSER=false R_PDFVIEWER=false time -f "Time %E" $(RDEV) check $(R_OPTS) $($*-OPTS) -l $(RLIB) --install=check:$*.log $* > $@ 2>&1
	@echo ... $* done

backup:
	cp -p Makefile manip.R reinstall.R *.out *.log ../tests-devel-keep
