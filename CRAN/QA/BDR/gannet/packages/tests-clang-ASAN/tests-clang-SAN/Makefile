RDEV=/data/gannet/ripley/R/R-clang-SAN/bin/R
R_OPTS=--check-subdirs=yes-maybe --extra-arch --no-stop-on-test-error
RLIBS=~/R/test-clang-SAN:~/R/test-clang

include ../Makefile.common

crmPack-OPTS = --no-vignettes
rmetasim-OPTS = --no-vignettes
skm-OPTS = --no-vignettes
walker-OPTS = --no-vignettes

%.out: %.in
	@/bin/echo $* ...
	@rm -f $*/src/*.[s]o $*/src/*.a $*/src/*/*.o $*/src/*/*/*.o $*/src/symbols.rds
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1 
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
	@mkdir -p ../tests-clang-SAN-keep
	@-cp -p Makefile pkgdiff RunScript process.R process2.R unpack.R *.out ../tests-clang-SAN-keep

process:
	@/data/gannet/ripley/R/R-devel/bin/Rscript process.R
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-ASAN
	@cp -p /data/ftp/pub/bdr/memtests/README.txt /data/ftp/pub/bdr/memtests/clang-UBSAN
	@/data/gannet/ripley/R/R-devel/bin/Rscript process2.R

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out check_log

unpack:
	@/data/gannet/ripley/R/R-clang/bin/Rscript unpack.R
