.SUFFICES:
.SUFFICES: .out .log
R_OPTS=
RLIBS = "c:/R/test-2.14;c:/R/BioC-2.9"
R32 = c:/R/Rduo/bin/i386/Rcmd.exe
RLIB = c:/R/test-2.14

# because of gdsfmt
SNPRelate-OPTS = --no-multiarch


%.out: %.log
	@echo $* ...
	@rm -rf $*.Rcheck
	+@R_LIBS=$(RLIBS) R_BROWSER=false R_PDFVIEWER=false time -f "Time %E" $(R32) check --multiarch $(R_OPTS) $($*-OPTS) -l $(RLIB) --install=check:$*.log $* > $@ 2>&1
	@echo ... $* done

backup:
	cp -p Makefile Makefile.common manip.R exceptions.R *.out *.log ../tests-keep

