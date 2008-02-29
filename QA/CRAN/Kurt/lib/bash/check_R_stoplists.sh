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
    eval "check_args_db_${1}='${2}'"
    case "${2}" in
      --install=fake)
        pkgs_install_fake_regexp="${pkgs_install_fake_regexp}|${1}" ;;
      --install=no)
        pkgs_install_no_regexp="${pkgs_install_no_regexp}|${1}" ;;
    esac
}
get_check_args () {
    eval echo '${'check_args_db_${1}'}' ;
}

## Package CoCo takes "too long", but fails with '--install=fake' (at
## least when R CMD check is run from cron, as for the daily checking).
set_check_args CoCo		"--install=no"
## Package RBloomberg depends on RDCOMClient (@Omegahat) which only
## works under Windows.
set_check_args RBloomberg	"--install=no"

## Packages which depend on Windows.
## Packages with SystemRequirements 'windows' as of 2008-02-25:
##   BRugs RPyGeo RSAGA RWinEdt rcom tdm
## Reverse dependencies of these:
##   mimR spectrino gmvalid
set_check_args BRugs		"--install=fake"
set_check_args RPyGeo		"--install=fake"
set_check_args RSAGA		"--install=fake"
set_check_args RWinEdt		"--install=fake"
set_check_args rcom		"--install=fake"
set_check_args tdm		"--install=fake"
set_check_args mimR		"--install=fake"
set_check_args spectrino	"--install=fake"
set_check_args gmvalid		"--install=fake"
## Packages which require Windows but do not say so in their
## SystemRequirements:
##   tcltk2 xlsReadWrite
## Reverse dependencies of these:
##   snpXpert
set_check_args tcltk2		"--install=fake"
set_check_args xlsReadWrite	"--install=fake"
set_check_args snpXpert		"--install=fake"

## Package which depend on external software packages.
## Package ROracle requires Oracle.
set_check_args ROracle		"--install=fake"
## Package Rcplex requires the CPLEX solvers.
set_check_args Rcplex		"--install=fake"
## Package Rlsf requires LSF.
set_check_args Rlsf		"--install=fake"
## Package caretLSF depends on Rlsf.
set_check_args caretLSF		"--install=fake"
## Package rsbml needs libsbml (no Debian package).
set_check_args rsbml		"--install=fake"

## Packages for which *loading* requires special system conditions.
## Loading package Rmpi calls lamboot.
set_check_args Rmpi		"--install=fake"
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
## Package snow


## Packages which (may) cause trouble when running their code as part of
## R CMD check.
## Package NORMT3 keeps exploding memory on linux/amd64.
set_check_args NORMT3		"${no_run_time_checks_args}"
## Package feature (1.1.9) kept hanging on at least one ix86 platform
## (late May 2007).
set_check_args feature		"${no_run_time_checks_args}"
## Package httpRequest kept causing internet access trouble.
##   set_check_args httpRequest	"${no_run_time_checks_args}"
## Package minet (1.1.0, 2008-01-22) keeps hanging the daily check
## processes on linux/amd64.
set_check_args minet		"${no_run_time_checks_args}"
## Package titan requires interaction.
set_check_args titan		"${no_run_time_checks_args}"

## Package for which run-time checks take too long.
## Might be more selective about the restrictions ...
set_check_args GLDEX		"${no_run_time_checks_args}"
set_check_args GSM		"${no_run_time_checks_args}"
set_check_args GenABEL		"${no_run_time_checks_args}"
set_check_args RBGL		"${no_run_time_checks_args}"
set_check_args RJaCGH		"${no_run_time_checks_args}"
set_check_args analogue		"${no_run_time_checks_args}"
set_check_args animation	"${no_run_time_checks_args}"
set_check_args copula		"${no_run_time_checks_args}"
set_check_args degreenet	"${no_run_time_checks_args}"
set_check_args ensembleBMA	"${no_run_time_checks_args}"
set_check_args gRain		"${no_run_time_checks_args}"
set_check_args gamlss		"${no_run_time_checks_args}"
set_check_args ggplot		"${no_run_time_checks_args}"
set_check_args ks		"${no_run_time_checks_args}"
set_check_args latentnet	"${no_run_time_checks_args}"
set_check_args latentnetHRT	"${no_run_time_checks_args}"
set_check_args np		"${no_run_time_checks_args}"
set_check_args poplab		"${no_run_time_checks_args}"
set_check_args pscl		"${no_run_time_checks_args}"
set_check_args sna		"${no_run_time_checks_args}"
set_check_args tgp		"${no_run_time_checks_args}"
set_check_args twang		"${no_run_time_checks_args}"
case ${FQDN} in
  anduin.wu-wien.ac.at|aragorn.wu-wien.ac.at|eragon.wu-wien.ac.at)
    set_check_args EMC		"${no_run_time_checks_args}"
    set_check_args MKLE		"${no_run_time_checks_args}"
    set_check_args RobRex	"${no_run_time_checks_args}"
    set_check_args SpherWave	"${no_run_time_checks_args}"
    set_check_args VGAM		"${no_run_time_checks_args}"
    set_check_args dprep	"${no_run_time_checks_args}"
    set_check_args dse		"${no_run_time_checks_args}"
    set_check_args fields	"${no_run_time_checks_args}"
    set_check_args geiger	"${no_run_time_checks_args}"
    set_check_args glmc		"${no_run_time_checks_args}"
    set_check_args hoa		"${no_run_time_checks_args}"
    set_check_args mixtools	"${no_run_time_checks_args}"
    set_check_args mlmRev	"${no_run_time_checks_args}"
    set_check_args poLCA	"${no_run_time_checks_args}"
    ;;
esac

## Packages for which some run-time checks take too long.
set_check_args TSMySQL		"--no-vignettes"
set_check_args Zelig		"--no-vignettes"
set_check_args caret		"--no-vignettes"
set_check_args aster		"--no-tests"
set_check_args fCopulae		"--no-tests"

## Done.


if test -n "${pkgs_install_fake_regexp}"; then
    pkgs_install_fake_regexp=`
        echo "${pkgs_install_fake_regexp}" | sed 's/^|/^(/; s/$/)$/;'`
fi    
if test -n "${pkgs_install_no_regexp}"; then
    pkgs_install_no_regexp=`
	echo "${pkgs_install_no_regexp}" | sed 's/^|/^(/; s/$/)$/;'`
fi    
