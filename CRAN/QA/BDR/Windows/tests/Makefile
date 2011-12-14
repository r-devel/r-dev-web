R_OPTS = --multiarch 
RLIBS = "c:/R/test-2.14;c:/R/BioC-2.9"
RDEV = c:/R/Rduo/bin/i386/Rcmd.exe
RLIB = c:/R/test-2.14

# because of gdsfmt
SNPRelate-OPTS = --no-multiarch


include Makefile.common

%.out: %.log
	@echo $* ...
	@rm -rf $*.Rcheck
	+@R_LIBS=$(RLIBS) R_BROWSER=false R_PDFVIEWER=false time -f "Time %E" $(RDEV) check $(R_OPTS) $($*-OPTS) -l $(RLIB) --install=check:$*.log $* > $@ 2>&1
	@echo ... $* done

backup:
	cp -p Makefile Makefile.common manip.R exceptions.R reinstall.R *.out *.log ../tests-keep

