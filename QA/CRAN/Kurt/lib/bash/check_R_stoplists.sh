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

## Package RBloomberg depends on RDCOMClient (@Omegahat) which only
## works under Windows.
set_check_args RBloomberg	"--install=no"
## Packages glmmBUGS and tdm depend on BRugs which is no longer on CRAN
## (hosted in CRANextras now).
set_check_args glmmBUGS		"--install=no"
set_check_args tdm		"--install=no"

## Packages which depend on Windows.
## Packages with SystemRequirements 'windows' as of 2008-02-25:
##   RPyGeo RWinEdt RthroughExcelWorkbooksInstaller rcom tdm
## Reverse dependencies of these:
##   R2PPT RExcelInstaller mimR spectrino
## (Package gmvalid only suggests mimR as of 2008-07-21.)
set_check_args RPyGeo		"--install=fake"
## set_check_args RSAGA		"--install=fake"
set_check_args RWinEdt		"--install=fake"
set_check_args RthroughExcelWorkbooksInstaller \
				"--install=fake"
set_check_args rcom		"--install=fake"
set_check_args R2PPT		"--install=fake"
set_check_args R2wd		"--install=fake"
set_check_args RExcelInstaller	"--install=fake"
set_check_args mimR		"--install=fake"
set_check_args spectrino	"--install=fake"
## <FIXME>
## Not sure what happens when this encounters a fake install of mimR:
##   set_check_args gmvalid		"--install=fake"
## </FIXME>
## Packages which require Windows but do not say so in their
## SystemRequirements:
##   VhayuR xlsReadWrite
set_check_args VhayuR		"--install=fake"
set_check_args xlsReadWrite	"--install=fake"
## Package BiplotGUI cannot be checked via fake installs because the
## package code barfs on non-Windows systems.  We use no-install which
## would come automatically in a single-pass check setup.
## <FIXME>
## Still true?
set_check_args BiplotGUI	"--install=fake"
## </FIXME>

## <FIXME>
## Still true?
## Packages which require Windows but do not say so in their
## SystemRequirements:
##   tcltk2
## Reverse dependencies of these:
##   snpXpert
## set_check_args tcltk2	"--install=fake"
## set_check_args snpXpert	"--install=fake"
## </FIXME>

## Packages which depend on 64-bit Linux.
set_check_args cmprskContin	"--install=fake"

## Package which depend on external software packages.
## Package ROracle requires Oracle.
set_check_args ROracle		"--install=fake"
## Package Rcplex requires the CPLEX solvers.
set_check_args Rcplex		"--install=fake"
## Package Rlsf requires LSF.
set_check_args Rlsf		"--install=fake"
## Package caretLSF depends on Rlsf.
set_check_args caretLSF		"--install=fake"
## Package cudaBayesreg requires CUDA.
set_check_args cudaBayesreg	"--install=fake"
## Package gputools requires CUDA.
set_check_args gputools		"--install=fake"
## Package rsbml needs libsbml (no Debian package).
set_check_args rsbml		"--install=fake"

## Packages for which *loading* requires special system conditions.
## Loading package Rmpi calls lamboot (which it really should not as
## this is implementation specific).  However, fake installs seem to
## cause trouble for packages potentially using Rmpi ...
##   set_check_args Rmpi	"--install=fake"
## Loading package RScaLAPACK calls lamboot or mpdboot.
set_check_args RScaLAPACK	"--install=fake"

## Packages which take too long to install.
set_check_args RQuantLib	"--install=fake"

## Packages for which *running* requires special system conditions.
## Package caretNWS run-time depends on NWS.
set_check_args caretNWS		"${no_run_time_checks_args}"
## Package sound requires access to audio devices.
set_check_args sound		"${no_run_time_checks_args}"
## Package rpvm might call PVM.
set_check_args rpvm		"${no_run_time_checks_args}"

## Packages which (may) cause trouble when running their code as part of
## R CMD check.
## Package NORMT3 keeps exploding memory on linux/amd64.
set_check_args NORMT3		"${no_run_time_checks_args}"
## Package beanplot keeps leaving a pdf viewer behind.
set_check_args beanplot		"${no_run_time_checks_args}"
## Package brew (1.0-2) keeps hanging.
set_check_args brew		"${no_run_time_checks_args}"
## Package celsius (1.0.7) keeps hanging, most likely due to slow web
## access to http://celsius.genomics.ctrl.ucla.edu.
set_check_args celsius		"${no_run_time_checks_args}"
## Package dynGraph leaves a JVM behind.
set_check_args dynGraph		"${no_run_time_checks_args}"
## Package feature (1.1.9) kept hanging on at least one ix86 platform
## (late May 2007).
set_check_args feature		"${no_run_time_checks_args}"
## Package httpRequest kept causing internet access trouble.
##   set_check_args httpRequest	"${no_run_time_checks_args}"
## Package hwriter keeps hanging the browser.
## Apparently (2009-02-11) not any more ...
##   set_check_args hwriter		"${no_run_time_checks_args}"
## Package meboot hung amd64 check processes in Jan 2010.
set_check_args meboot		"${no_run_time_checks_args}"
## Package multicore leaves child processes behind.
set_check_args multicore	"${no_run_time_checks_args}"
## Package titan requires interaction.
set_check_args titan		"${no_run_time_checks_args}"

## <FIXME>
## Commented on 2009-11-11 :-)
## Package minet (1.1.0, 2008-01-22) keeps hanging the daily check
## processes on linux/amd64.
## Still true?
##   set_check_args minet		"${no_run_time_checks_args}"
## These used to be on the run-time too long list:
##   set_check_args GLDEX		"${no_run_time_checks_args}"
##   set_check_args RJaCGH		"${no_run_time_checks_args}"
##   set_check_args animation	"${no_run_time_checks_args}"
##   set_check_args copula		"${no_run_time_checks_args}"
##   set_check_args gRain		"${no_run_time_checks_args}"
##   set_check_args gamlss		"${no_run_time_checks_args}"
## Keep this until we have solved the client/server puzzle ...
## Still?
##   set_check_args RFreak		"--no-examples"
## </FIXME>

## Package for which run-time checks take too long.
set_check_args BB		"${no_run_time_checks_args}"
set_check_args Bergm		"${no_run_time_checks_args}"
set_check_args GSM		"${no_run_time_checks_args}"
set_check_args GenABEL		"${no_run_time_checks_args}"
set_check_args IsoGene		"${no_run_time_checks_args}"
set_check_args PerformanceAnalytics \
				"${no_run_time_checks_args}"
set_check_args RBGL		"${no_run_time_checks_args}"
set_check_args STAR		"${no_run_time_checks_args}"
set_check_args SubpathwayMiner	"${no_run_time_checks_args}"
set_check_args amei		"${no_run_time_checks_args}"
set_check_args analogue		"${no_run_time_checks_args}"
set_check_args bark		"${no_run_time_checks_args}"
set_check_args degreenet	"${no_run_time_checks_args}"
set_check_args ensembleBMA	"${no_run_time_checks_args}"
set_check_args eqtl		"${no_run_time_checks_args}"
set_check_args fields		"${no_run_time_checks_args}"
set_check_args gamm4		"${no_run_time_checks_args}"
set_check_args geozoo		"${no_run_time_checks_args}"
set_check_args ggplot		"${no_run_time_checks_args}"
set_check_args ks		"${no_run_time_checks_args}"
set_check_args latentnet	"${no_run_time_checks_args}"
set_check_args latentnetHRT	"${no_run_time_checks_args}"
set_check_args mrdrc		"${no_run_time_checks_args}"
set_check_args mixtools		"${no_run_time_checks_args}"
set_check_args np		"${no_run_time_checks_args}"
set_check_args poplab		"${no_run_time_checks_args}"
set_check_args pscl		"${no_run_time_checks_args}"
set_check_args rWMBAT		"${no_run_time_checks_args}"
set_check_args sna		"${no_run_time_checks_args}"
set_check_args surveillance	"${no_run_time_checks_args}"
set_check_args tgp		"${no_run_time_checks_args}"
set_check_args twang		"${no_run_time_checks_args}"
case ${FQDN} in
  anduin.wu.ac.at|aragorn.wu.ac.at|eragon.wu.ac.at)
    set_check_args EMC		"${no_run_time_checks_args}"
    set_check_args FitAR	"${no_run_time_checks_args}"
    set_check_args GExMap	"${no_run_time_checks_args}"
    set_check_args MKLE		"${no_run_time_checks_args}"
    set_check_args PK		"${no_run_time_checks_args}"
    set_check_args RobRex	"${no_run_time_checks_args}"
    set_check_args SpherWave	"${no_run_time_checks_args}"
    set_check_args VGAM		"${no_run_time_checks_args}"
    set_check_args dprep	"${no_run_time_checks_args}"
    set_check_args dse		"${no_run_time_checks_args}"
    set_check_args geiger	"${no_run_time_checks_args}"
    set_check_args glmc		"${no_run_time_checks_args}"
    set_check_args lpc		"${no_run_time_checks_args}"
    set_check_args mlmRev	"${no_run_time_checks_args}"
    set_check_args monomvn	"${no_run_time_checks_args}"
    set_check_args poLCA	"${no_run_time_checks_args}"
    set_check_args spatstat	"${no_run_time_checks_args}"
    set_check_args timereg	"${no_run_time_checks_args}"
    set_check_args tossm	"${no_run_time_checks_args}"
    ;;
esac

## Packages for which some run-time checks take too long ...
set_check_args TSSQLite		"--no-vignettes"
set_check_args Zelig		"--no-vignettes"
set_check_args caret		"--no-vignettes"
set_check_args fCopulae		"--no-tests"
## or causes trouble (missing data base run time functionality):
set_check_args TSMySQL		"--no-vignettes"
set_check_args TSPostgreSQL	"--no-vignettes"
set_check_args TSfame		"--no-vignettes"
set_check_args TSodbc		"--no-vignettes"

## Done.

if test -n "${pkgs_install_fake_regexp}"; then
    pkgs_install_fake_regexp=`
        echo "${pkgs_install_fake_regexp}" | sed 's/^|/^(/; s/$/)$/;'`
fi    
if test -n "${pkgs_install_no_regexp}"; then
    pkgs_install_no_regexp=`
	echo "${pkgs_install_no_regexp}" | sed 's/^|/^(/; s/$/)$/;'`
fi    
