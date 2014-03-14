SOURCES=`find * -maxdepth 0 -type d | grep -v \.Rcheck`

SOURCES=${shell ls *.in}
OUTS=$(SOURCES:.in=.out)

.SUFFICES:
.SUFFICES: .in .out
RDEV = R
R_OPTS=--check-subdirs=yes-maybe
RLIBS=~/R/BioC-2.13

AffyTiling-VARS = MAKE=make MAKEFLAGS=
ArrayExpress-OPTS=--no-examples --no-vignettes
BGmix-VARS = MAKE=make MAKEFLAGS=
ENVISIONQuery-OPTS = --no-vignettes
GSVA-OPTS = --no-build-vignettes
GenomicRanges-OPTS = --no-vignettes
RMAGEML-OPTS = --install=fake
Rsubread-OPTS = --install=fake
SJava-OPTS = --install=fake
affxparser-VARS = MAKE=make MAKEFLAGS=
annotate-OPTS=--no-examples --no-vignettes
baySeq-OPTS = --no-vignettes
gmapR-OPTS = --no-tests --no-vignettes
## takes > 6GB
methyAnalysis = --no-examples
rhdf5-VARS = MAKE=make MAKEFLAGS=
segmentSeq-OPTS = --no-vignettes
xps-OPTS = --install=fake

%.out: %.in
	@echo $* ...
	@rm -f `basename $< .in`/src/*o
	-+@R_LIBS=$(RLIBS) $($*-VARS) time -f "Time %E, %U + %S" $(RDEV) CMD check $(R_OPTS) $($*-OPTS) $* > $@ 2>&1
	@echo ... $* done

all:
	@make backup unpack
	@script

check: $(OUTS)

backup:
	@cp -p Makefile script unpack.sh ../tests-keep
	-@cp -p *.out ../tests-keep

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

unpack:
	-@sh unpack.sh
