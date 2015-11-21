## Data base of special flags to be employed for CRAN package checking.

## Packages which depend on unavailable packages cannot be installed,
## and hence must be checked with '--install=no'.  (This used to include
## all packages depending on packages from Bioconductor or Omegahat.)
## The same applies to reverse dependencies of such packages, of course.
## For sake of simplicity, we also use --install=no for packages with
## non-CRAN depends which cannot fully be installed.
##
## Packages which can otherwise not fully be installed must be checked
## with '--install=fake'.  This includes
## * Packages  which depend on unavailable external software (as
##   hopefully recorded in the package DESCRIPTION SystemRequirements,
##   and checked for using the package configure scripts)
## * Packages for which installation takes too long
## * Packages for which *loading* requires special system conditions
## * Reverse dependencies of such packages.
## (This operates under the assumption that installation does not run
## package code.)
##
## Packages for which *running* requires special system conditions are
## fully installed (unless this takes too long), but all run-time checks
## are turned off.
##
## Package run time tests which take too long are selectively turned off.
##
## We control the flags via a simple flag data base which for reasons of
## portability does not take advantage of Bash arrays.  For convenience
## (to avoid iterating through the db) we record the fake/no install
## packages right away.

no_run_time_checks_args="--no-examples --no-tests --no-vignettes"

pkgs_install_fake_regexp=
pkgs_install_no_regexp=

set_check_args () {
    safe=`echo "${1}" | tr . _`
    eval "check_args_db_${safe}='${2}'"
    case "${2}" in
      --install=fake)
        pkgs_install_fake_regexp="${pkgs_install_fake_regexp}|${1}" ;;
      --install=no)
        pkgs_install_no_regexp="${pkgs_install_no_regexp}|${1}" ;;
    esac
}
get_check_args () {
    safe=`echo "${1}" | tr . _`
    eval echo '${'check_args_db_${safe}'}' ;
}

## Package excel.link depends on RDCOMClient (@Omegahat) which only
## works under Windows.
set_check_args excel.link		"--install=no"

## Package Rmosek requires MOSEK (hence needs at least a fake install)
## and exports shared object symbols into the namespace (hence, no).
set_check_args Rmosek			"--install=no"
## Packages cqrReg and REBayes depend on Rmosek.
set_check_args cqrReg			"--install=no"
set_check_args REBayes			"--install=no"
## Package RSAP needs SAP headers/libraries and exports shared object
## symbols into the namespace.
set_check_args RSAP			"--install=no"

## Packages which depend on Windows.
## Packages with OS_type 'windows' as of 2014-12-23:
##   BiplotGUI excel.link installr MDSGUI R2MLwiN R2PPT R2wd RPyGeo
##   RWinEdt 
## Packages which depend on these: none.
## There really is no need to special-case these as
## * Checking on Linux automatically switches to --install=no.
## * Regular CRAN checking skips these packages (using OS_type for
##   filtering available packages) [mostly to avoid false positives
##   when checking Windows-specific content (Rd xrefs)].

## Packages which depend on 64-bit Linux.
## (Archived in 2010.)
##   set_check_args cmprskContin	"--install=fake"

## Package which depend on external software packages.
## Package FEST requires merlin.
set_check_args FEST			"--install=fake"
## Package HiPLARM needs CUDA/PLASMA/MAGMA.
set_check_args HiPLARM			"--install=fake"
## Package R2OpenBUGS requires OpenBugs: this has Ubuntu binaries at
## http://www.openbugs.info/w/Downloads but no Debian binaries.
## Re-activated 2014-12-18: no longer true.
##   set_check_args R2OpenBUGS		"--install=fake"
## Package RMark requires MARK which is not open source.
set_check_args RMark			"--install=fake"
## Package RMongo requires MongoDB.
## Re-activated 2014-12-18.
##   set_check_args RMongo		"--install=fake"
## Package ROracle requires Oracle.
set_check_args ROracle			"--install=fake"
## Packages ROracleUI ora depend on ROracle.
set_check_args ROracleUI		"--install=fake"
set_check_args ora			"--install=fake"
## Packages Rcplex cplexAPI require the CPLEX solvers.
set_check_args Rcplex			"--install=fake"
set_check_args cplexAPI			"--install=fake"
## Package Rlsf requires LSF.
set_check_args Rlsf			"--install=fake"
## Package caretLSF depends on Rlsf.
set_check_args caretLSF			"--install=fake"
## Packages CARramps WideLM cudaBayesreg gmatrix gputools iFes magma
## permGPU rpud require CUDA.
set_check_args CARramps			"--install=fake"
set_check_args WideLM			"--install=fake"
set_check_args cudaBayesreg		"--install=fake"
set_check_args gmatrix			"--install=fake"
set_check_args gputools			"--install=fake"
set_check_args iFes			"--install=fake"
set_check_args magma			"--install=fake"
set_check_args permGPU			"--install=fake"
set_check_args rpud			"--install=fake"
## Package gcbd requires a lot (MKL, CUDA, ...)
set_check_args gcbd			"--install=fake"
## Package rLindo needs LINDO API 8.0 (no Debian package).
set_check_args rLindo			"--install=fake"
## Package rsbml needs libsbml (no Debian package).
## (Moved from CRAN to Bioconductor.)
##   set_check_args rsbml		"--install=fake"
## Package ndvits needs TISEAN executables from
## http://www.mpipks-dresden.mpg.de/~tisean/.
##   set_check_args ndvits		"--install=fake"
## Package ncdf4 requires libnetcdf 4.1 or better, which as of
## 2010-02-24 is only in Debian experimental, and breaks RNetCDF.
##   set_check_args ncdf4		"--install=fake"
## Package localsolver needs localsolver.
set_check_args localsolver		"--install=fake"

## Packages for which *loading* requires special system conditions.
## Loading package Rmpi calls lamboot (which it really should not as
## this is implementation specific).  However, fake installs seem to
## cause trouble for packages potentially using Rmpi ...
##   set_check_args Rmpi		"--install=fake"
## Loading package RScaLAPACK calls lamboot or mpdboot.
set_check_args RScaLAPACK		"--install=fake"
## Loading package taskPR calls lamnodes.
set_check_args taskPR			"--install=fake"

## Packages which take too long to install.
##   set_check_args RQuantLib		"--install=fake"

## Packages for which *running* requires special system conditions.
## Package caRpools needs MAGeCK.
set_check_args caRpools			"${no_run_time_checks_args}"
## Package caretNWS run-time depends on NWS.
set_check_args caretNWS			"${no_run_time_checks_args}"
## Package sound requires access to audio devices.
##   set_check_args sound		"${no_run_time_checks_args}"
## Package rpvm might call PVM.
set_check_args rpvm			"${no_run_time_checks_args}"
## Package npRmpi requires special MPI conditions.
set_check_args npRmpi			"${no_run_time_checks_args}"
## Package nbconvertR requires ipython (>= 3.0), but as of 2015-07-10
## Debian testing only has ipython 2.3.0.
set_check_args nbconvertR		"${no_run_time_checks_args}"

## Packages which (may) cause trouble when running their code as part of
## R CMD check.
## Package ElstonStewart keeps hanging.
set_check_args ElstonStewart		"${no_run_time_checks_args}"
## Package NORMT3 keeps exploding memory on linux/amd64.
## Re-activated 2010-11-03.
##   set_check_args NORMT3		"${no_run_time_checks_args}"
## Package OjaNP (0.9-4) keeps hanging.
## Re-activated 2011-12-13.
##   set_check_args OjaNP		"${no_run_time_checks_args}"
## Package RLastFM kept hanging on several platforms in Jan 2011.
## Re-activated 2011-12-13.
##   set_check_args RLastFM		"${no_run_time_checks_args}"
## Package Rlabkey had examples which require a LabKey server running on
## port 8080 of localhost.  No longer as of 2010-08-24.
##   set_check_args Rlabkey		"${no_run_time_checks_args}"
## Package SNPtools keeps hanging.
set_check_args SNPtools			"${no_run_time_checks_args}"
## Package TSjson keeps hanging.
set_check_args TSjson			"${no_run_time_checks_args}"
## Package beanplot keeps leaving a pdf viewer behind.
## Re-activated 2010-11-03.
##   set_check_args beanplot		"${no_run_time_checks_args}"
## Package brew (1.0-2) keeps hanging.
## Re-activated 2011-12-13.
##   set_check_args brew		"${no_run_time_checks_args}"
## Package celsius (1.0.7) keeps hanging, most likely due to slow web
## access to http://celsius.genomics.ctrl.ucla.edu.
## Archived on 2010-07-30.
##   set_check_args celsius		"${no_run_time_checks_args}"
## Package climdex.pcic (1.0-3) keeps segfaulting when running
## tests/bootstrap.R, which manages to hang the check process(es).
set_check_args climdex.pcic		"--no-tests"
## Package distrom kept hanging in early July 2015.
set_check_args distrom			"${no_run_time_checks_args}"
## Package dynGraph leaves a JVM behind.
set_check_args dynGraph			"${no_run_time_checks_args}"
## Package feature (1.1.9) kept hanging on at least one ix86 platform
## (late May 2007).
## Re-activated 2010-11-03.
##   set_check_args feature		"${no_run_time_checks_args}"
## Package fscaret (1.0) hangs on 2013-06-14.
## Re-activated 2013-06-17.
##   set_check_args fscaret		"${no_run_time_checks_args}"
## Package httpRequest kept causing internet access trouble.
##   set_check_args httpRequest		"${no_run_time_checks_args}"
## Package hwriter keeps hanging the browser.
## Apparently (2009-02-11) not any more ...
##   set_check_args hwriter		"${no_run_time_checks_args}"
## Package meboot hung amd64 check processes in Jan 2010.
## Re-activated 2011-12-13.
##   set_check_args meboot		"${no_run_time_checks_args}"
## Package multicore leaves child processes behind.
set_check_args multicore		"${no_run_time_checks_args}"
## Package ptinpoly (2.0) keeps hanging
set_check_args ptinpoly			"${no_run_time_checks_args}"
## Package titan requires interaction.
## Re-activated 2010-11-03.
##   set_check_args titan		"${no_run_time_checks_args}"

## As of 2012-03-03, package adegenet keeps hanging.
##   set_check_args adegenet		"${no_run_time_checks_args}"

## Package speedglm keeps failing its examples due to problems with web
## access to http://dssm.unipa.it/enea/data1.txt.
set_check_args speedglm			"--no-examples"

## Package DSL needs a working Hadoop environment for its vignette.
##   set_check_args DSL			"--no-vignettes"

## Package BACA keeps failing its vignette checks.
set_check_args BACA			"--no-vignettes"
## Package catnet keeps failing its vignette checks.
set_check_args catnet			"--no-vignettes"
## As of 2015-05-05, package raincpc keeps hanging in its vignettes
## checks.
set_check_args raincpc			"--no-vignettes"
## As of 2015-07-03, package rentrez keeps failing its tests.
set_check_args rentrez			"--no-tests"

## Goslate keeps getting HTTP Error 503: Service Unavailable.
set_check_args Goslate			"--no-examples"

## Packages for which run-time checks take too long.
set_check_args tgp			"${no_run_time_checks_args}"
##   set_check_args Bergm		"${no_run_time_checks_args}"
##   set_check_args GenABEL		"${no_run_time_checks_args}"
##   set_check_args IsoGene		"${no_run_time_checks_args}"
##   set_check_args SubpathwayMiner	"${no_run_time_checks_args}"
##   set_check_args degreenet		"${no_run_time_checks_args}"
##   set_check_args ensembleBMA		"${no_run_time_checks_args}"
##   set_check_args eqtl		"${no_run_time_checks_args}"
##   set_check_args expectreg		"${no_run_time_checks_args}"
##   set_check_args fields		"${no_run_time_checks_args}"
##   set_check_args gamm4		"${no_run_time_checks_args}"
##   set_check_args geozoo		"${no_run_time_checks_args}"
##   set_check_args ks			"${no_run_time_checks_args}"
##   set_check_args latentnet		"${no_run_time_checks_args}"
##   set_check_args mixtools		"${no_run_time_checks_args}"
##   set_check_args np			"${no_run_time_checks_args}"
##   set_check_args pscl		"${no_run_time_checks_args}"
##   set_check_args rWMBAT		"${no_run_time_checks_args}"
##   set_check_args sna			"${no_run_time_checks_args}"
##   set_check_args speff2trial		"${no_run_time_checks_args}"
##   set_check_args surveillance	"${no_run_time_checks_args}"
##   set_check_args ttime		"${no_run_time_checks_args}"

FQDN=`hostname -f`
case ${FQDN} in
  xmgyges.wu.ac.at)
    ## Package BRugs requires OpenBugs which currently is only
    ## available for amd64.
    ## [As of 2012-03-14, not any more ...]
    ## Packages BTSPAS and tdm depend on BRugs.
    ##   set_check_args BRugs		"--install=fake"
    ##   set_check_args BTSPAS		"--install=fake"
    ##   set_check_args tdm		"--install=fake"
    ## Package OpenCL requires OpenCL headers and libraries.
    ## Intel's SDK is only available for amd64.
    set_check_args OpenCL		"--install=fake"
    ## Package lokern keeps hanging in its tests.
    set_check_args lokern		"--no-tests"
    ;;
esac

## Packages for which some run-time checks take too long ...
set_check_args BB			"--no-vignettes"
set_check_args GSM			"--no-examples"
set_check_args GiANT			"--no-vignettes"
set_check_args MSIseq			"--no-vignettes"
set_check_args ModelMap			"--no-vignettes"
set_check_args RBrownie			"--no-vignettes"
set_check_args STAR			"--no-vignettes"
set_check_args TESS			"--no-vignettes"
set_check_args TilePlot			"--no-examples"
set_check_args TriMatch			"--no-vignettes"
set_check_args amen			"--no-vignettes"
set_check_args bark			"--no-examples"
set_check_args crmPack			"--no-vignettes"
set_check_args ctmm			"--no-vignettes"
set_check_args dismo			"--no-vignettes"
set_check_args fCopulae			"--no-tests"
set_check_args fxregime			"--no-vignettes"
set_check_args geiger			"--no-vignettes"
set_check_args iSubpathwayMiner		"--no-vignettes"
set_check_args laGP			"--no-vignettes"
set_check_args mcemGLM			"--no-vignettes"
set_check_args mediation		"--no-vignettes"
set_check_args micEconCES		"--no-vignettes"
set_check_args mrdrc			"--no-tests"
set_check_args ordinalgmifs		"--no-vignettes"
set_check_args phylosim			"--no-vignettes"
set_check_args portfolioSim		"--no-vignettes"
set_check_args psychomix		"--no-vignettes"
set_check_args spikeSlabGAM		"--no-vignettes"
set_check_args spatstat			"--no-tests"
set_check_args twang			"--no-vignettes"
## set_check_args PerformanceAnalytics	"--no-examples --no-vignettes"
## set_check_args Rcgmin		"--no-tests"
## set_check_args Rvmmin		"--no-tests"
## set_check_args Zelig			"--no-vignettes"
## set_check_args abc			"--no-vignettes"
## set_check_args amei			"--no-vignettes"
## set_check_args bcool			"--no-vignettes"
## set_check_args caret			"--no-vignettes"
## set_check_args catnet		"--no-vignettes"
## set_check_args crimCV		"--no-examples"
## set_check_args crs			"--no-vignettes"
## set_check_args dmt			"--no-vignettes"
## set_check_args fanplot		"--no-vignettes"
## set_check_args lossDev		"--no-vignettes"
## set_check_args mcmc			"--no-vignettes"
## set_check_args metaMA		"--no-vignettes"
## set_check_args pomp			"--no-tests"
## set_check_args rebmix		"--no-vignettes"
## set_check_args unmarked		"--no-vignettes"

## Packages for which some run-time checks cause trouble (e.g., missing data
## base run time functionality): 
set_check_args TSdata			"--no-vignettes"
## Package patchDVI contains a vignette with Japanese text which
## requires a localized version of LaTeX for processing.
##   set_check_args patchDVI			"--no-build-vignettes"

## Done.

if test -n "${pkgs_install_fake_regexp}"; then
    pkgs_install_fake_regexp=`
        echo "${pkgs_install_fake_regexp}" | sed 's/^|/^(/; s/$/)$/;'`
fi    
if test -n "${pkgs_install_no_regexp}"; then
    pkgs_install_no_regexp=`
	echo "${pkgs_install_no_regexp}" | sed 's/^|/^(/; s/$/)$/;'`
fi    

### Local Variables: ***
### mode: sh ***
### sh-basic-offset: 2 ***
### End: ***
