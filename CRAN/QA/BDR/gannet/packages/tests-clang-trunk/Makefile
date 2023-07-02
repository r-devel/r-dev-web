RDEV=/data/gannet/ripley/R/R-flang/bin/R
R_OPTS=--check-subdirs=yes-maybe --no-stop-on-test-error
RLIBS=~/R/test-clang

include ../Makefile.common

## parallel install mucks up output
Boom-VARS = MAKE=make MAKEFLAGS=
OpenMx-VARS = MAKE=make MAKEFLAGS=
RcppMLPACK-VARS = MAKE=make MAKEFLAGS=
RcppShark-VARS = MAKE=make MAKEFLAGS=
dplyr-VARS = MAKE=make MAKEFLAGS=
gaston-VARS = MAKE=make MAKEFLAGS=
mixedMem-VARS = MAKE=make MAKEFLAGS=
pcalg-VARS = MAKE=make MAKEFLAGS=
psrwe-VARS = MAKE=make MAKEFLAGS=
qlcalVARS = MAKE=make MAKEFLAGS=
rPref-VARS = MAKE=make MAKEFLAGS=
rgdal-VARS = MAKE=make MAKEFLAGS=
textTinyR-VARS = MAKE=make MAKEFLAGS=
## or fails sometimes
cubature-VARS = MAKE=make MAKEFLAGS=

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	-@cp -p $*.Rcheck/00install.out $*.log
	@chmod 644 $*/DESCRIPTION
	@cp $*/DESCRIPTION $*.Rcheck/00package.dcf
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

dummy:
	@/bin/echo "dummy first target"

all:
	@make unpack
	@./RunScript
	@make process
check: $(OUTS)

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out *.log check_log

process:
	@@/data/gannet/ripley/R/R-devel/bin/Rscript process.R

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R

unpackall:
	@/data/gannet/ripley/R/R-clang/bin/Rscript ../tests-clang/unpack.R

summary:
	@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R | less
summary0:
	-@/data/gannet/ripley/R/R-devel/bin/Rscript summary.R
