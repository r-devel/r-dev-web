RDEV=/data/gannet/ripley/R/gcc-SAN/bin/R
R_OPTS=--check-subdirs=yes-maybe --extra-arch --no-stop-on-test-error
RLIBS=~/R/test-3.5

include ../Makefile.common

crmPack-OPTS = --no-vignettes
prc-OPTS=--no-tests

## parallel install use excessive memory
rstan-VARS = MAKE=make MAKEFLAGS=
rstanarm-VARS = MAKE=make MAKEFLAGS=
survHE-VARS = MAKE=make MAKEFLAGS=
trialr-VARS = MAKE=make MAKEFLAGS=

%.out: %.in
	@echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@rm -rf $*
	@echo ... $* done

dummy:
	@echo "dummy first target"

all:
	-@make backup
	@make unpack
	@./script
	@make process

check: $(OUTS)

backup:
	@mkdir -p ../tests-gcc-SAN-keep
	@cp -p Makefile pkgdiff script process.R process2.R unpack.R *.out ../tests-gcc-SAN-keep

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/gcc-ASAN
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/gcc-UBSAN
	@/data/gannet/ripley/R/R-devel/bin/Rscript process2.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	@/data/gannet/ripley/R/R-devel/bin/Rscript unpack.R