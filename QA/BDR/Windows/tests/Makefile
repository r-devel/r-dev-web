.SUFFICES:
.SUFFICES: .out .log
R_OPTS=
RLIBS = "c:/R/test-2.14;c:/R/BioC-2.9"
R32 = c:/R/Rduo/bin/i386/Rcmd.exe
RLIB = c:/R/test-2.14

BB-OPTS = --no-tests
Bergm-OPTS = --no-examples
IsoGene-OPTS = --no-examples
NCBI2R-OPTS = --no-examples
Rook-OPTS = --no-examples
# because of gdsfmt
SNPRelate-OPTS = --no-multiarch
TSMySQL-OPTS = --no-vignettes
TSPostgreSQL-OPTS = --no-vignettes
TSfame-OPTS = --no-vignettes
TSodbc-OPTS = --no-vignettes
VGAM-OPTS = --no-examples
abc-OPTS = --no-vignettes
amei-OPTS = --no-vignettes
anchors-OPTS = --no-rebuild-vignettes
atmi-OPTS = --no-examples
celsius-OPTS = --no-examples
crimCV-OPTS = --no-examples
demography-OPTS = --no-examples
dynGraph-OPTS = --no-examples
fractal-OPTS = --no-examples
gdata-OPTS = --no-examples --no-tests
lossDev-OPTS = --no-vignettes
mcmc-OPTS = --no-vignettes
misc3d-OPTS = --no-examples
mixtools-OPTS = --no-examples
mlmRev-OPTS = --no-examples
rWMBAT-OPTS = --no-examples
rebmix-OPTS = --no-vignettes
speff2trial-OPTS = --no-examples
spikeSlabGAM-OPTS = --no-vignettes
surveillance-OPTS = --no-examples
tgp-OPTS = --no-examples --no-vignettes

## crash and remain running.
glmpath-OPTS = --no-examples
seewave-OPTS = --no-examples

all:
	@make --no-print-directory update install
	@make --no-print-directory -j4 -k check

LOGS=${shell ls *.log}
check: $(LOGS:.log=.out)

install:
	@Rscript.exe manip.R LC_COLLATE=C

reinstall:
	@Rscript.exe reinstall.R LC_COLLATE=C

%.out: %.log
	@echo $* ...
	@rm -rf $*.Rcheck
	+@R_LIBS=$(RLIBS) R_BROWSER=false R_PDFVIEWER=false time -f "Time %E" $(R32) check --multiarch $(R_OPTS) $($*-OPTS) -l $(RLIB) --install=check:$*.log $* > $@ 2>&1
	@echo ... $* done

backup:
	cp -p Makefile manip.R exceptions.R *.out *.log ../tests-keep

clean:
	find * -maxdepth 0 -type d -exec rm -rf {} \;
	rm -f *.in

veryclean: clean
	rm -f *.out

update:
	@(cd ../packages; sh update)
