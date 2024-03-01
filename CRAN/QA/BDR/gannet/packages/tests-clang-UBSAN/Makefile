RDEV=Rclang
R_OPTS=--check-subdirs=yes-maybe --extra-arch --no-stop-on-test-error
RLIBS=~/R/test-clang
R_MAKEVARS=~/.R/Makevars.UBSAN

include ../Makefile.common

crmPack-OPTS = --no-vignettes
rmetasim-OPTS = --no-vignettes
skm-OPTS = --no-vignettes
walker-OPTS = --no-vignettes

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) R_MAKEVARS_USER=$(R_MAKEVARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
	-@cp -p $*.Rcheck/00install.out $*.log
	@rm -rf $* $*.Rcheck/$*
	@/bin/echo ... $* done

dummy:
	@/bin/echo "dummy first target"

all:
	-@make backup
	@make unpack
	@./RunScript
	@make process

check: $(OUTS)

backup:
	@mkdir -p ../tests-clang-UBSAN-keep
	@-cp -p Makefile pkgdiff RunScript process.R process2.R unpack.R *.log *.out ../tests-clang-UBSAN-keep

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-UBSAN
	@/data/gannet/ripley/R/R-devel/bin/Rscript process2.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R
