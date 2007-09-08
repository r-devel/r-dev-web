## We know that we cannot "really" install some of the packages ...
## In addition, we try not to run code in packages which call lamboot
## (Rmpi, RScaLAPACK) to something similar (rpvm?).
## We currently use '--install=fake' for these.
## Finally, checking some of the packages (CoCo, dse, ...) takes too
## long.
## <FIXME>
## As of 2006-10-16, we had
##   pkgs_install_fake_too_long="MFDA|MarkedPointProcess|RGtk2|RandVar|aod|aster|distrEx|dprep|gWidgetsRGtk2|gamlss|hoa|ks|pscl|rattle|tgp|twang"
## and thus
##   gamlss.nl gamlss.tr tsfa
## in pkgs_install_fake_cannot_run as the latter depend on something
## which takes too long.
## Timings on an Intel(R) Pentium(R) M processor 1.80GHz gave:
##
##                                   Total    User System Status
## tgp_1.1-11.tar.gz               1886.61 1860.91  25.70     OK
## aster_0.6-2.tar.gz              1142.43 1051.26  91.17     OK
## RGtk2_2.8.6.tar.gz               608.58  586.68  21.90     OK
## hoa_1.1-0.tar.gz                 590.20  580.56   9.64     OK
## dprep_1.0.tar.gz                 386.69  379.19   7.50     OK
## gamlss_1.4-0.tar.gz              336.08  330.20   5.88     OK
## ks_1.4.3.tar.gz                  303.61  298.60   5.01     OK
## gWidgetsRGtk2_0.0-7.tar.gz       127.25  124.19   3.06     OK
## distrEx_0.4-3.tar.gz             121.21  117.58   3.63     OK
## RandVar_0.4-2.tar.gz              93.70   90.92   2.78  ERROR
## MarkedPointProcess_0.2.2.tar.gz   43.84   41.40   2.44     OK
## MFDA_1.1-0.tar.gz                 42.91   41.09   1.82     OK
## aod_1.1-13.tar.gz                 41.12   39.51   1.61     OK
## rattle_2.1.57.tar.gz              31.14   29.72   1.42     OK
##
## so it seems we can try only excluding aster/pscl/tgp for the time
## being ...
pkgs_install_fake_cannot_run="BRugs|ROracle|RmSQL|RScaLAPACK|RWinEdt|Rlsf|Rmpi|feature|httpRequest|prim|rcdd|rcom|rpvm|rsbml|snowFT|snpXpert|sound|spectrino|taskPR|tcltk2|tdm|titan|wnominate|xlsReadWrite"
## Reasons:
## * clustTool (1.0) hangs the whole daily check process (most likely
##   because installing it loads Rcmdr which attempts interaction about
##   installing additional required/suggested packages.
## * titan requires interaction.
## * gamlss.nl depends on gamlss (takes too long).
## * gamlss.tr depends on gamlss (takes too long).
## * feature (1.1.9) keeps hanging on at least one ix86 platform (late
##   May 2007).
## * prim depends on ks (takes too long).
## * rsbml needs libsbml (no Debian package).
## * snpXpert depends on tcltk2.
## * sound requires access to audio devices.
## * spectrino depends on rcom.
## * tcltk2 only works on Windows.
## * tdm depends on BRugs.
## * tsfa depends on dse (takes too long).
## * wnominate depends on pscl (takes too long).
## pkgs_install_fake_too_long="MFDA|MarkedPointProcess|RGtk2|RandVar|aod|aster|distrEx|dprep|gWidgetsRGtk2|gamlss|hoa|ks|pscl|rattle|tgp|twang"
pkgs_install_fake_too_long="GenABEL|RBGL|RJaCGH|RQuantLib|analogue|copula|ensembleBMA|ggplot|ks|np|pscl|sna|tgp|twang"
## Note that
## * RandVar depends on distrEx.
## * gWidgetsRGtk2 depends on RGtk2.
## * rattle depends on RGtk2.
## </FIXME>

## <NOTE>
## We really have a problem for check runs on beren, which take very
## close to a full day.  Try to save more time, but undo eventually ...
## Actually, it seems that also for more recent ix86 systems, we are
## getting very close to a full day now (2007-01-15).  Grrr.
case ${FQDN} in
  beren.wu-wien.ac.at)
    pkgs_install_fake_too_long="${pkgs_install_fake_too_long}|RandomFields|arules|dse|fields|svcR|feature|pvclust|mlmRev|mprobit|latentnet|plsgenomics|spatstat|ProbForecastGOP|SoPhy|verification"
    ## Note:
    ## * ProbForecastGOP and SoPhy depend on RandomFields
    ## * verification depends on fields
    ;;
  anduin.wu-wien.ac.at|aragorn.wu-wien.ac.at|eragon.wu-wien.ac.at)
    pkgs_install_fake_too_long="${pkgs_install_fake_too_long}|SpherWave|VGAM|dprep|dse|fields|glmc|hoa|mlmRev"
    ## These take too long.  Now add dependencies as well:
    pkgs_install_fake_too_long="${pkgs_install_fake_too_long}|Geneland|GeoXp|ProbForecastGOP|TIMP|VDCutil|WeedMap|Zelig|rflowcyt|tsfa|verification"
    ## Note offending reverse dependencies (including Suggests):
    ## * VGAM: Zelig
    ## * Zelig: VDCutil
    ## * dse: tsfa
    ## * fields: Geneland GeoXp ProbForecastGOP SpherWave TIMP verification
    ##           WeedMap rflowcyt
    ;;
esac
## </NOTE>

pkgs_install_fake_regexp="^(${pkgs_install_fake_cannot_run}|${pkgs_install_fake_too_long})\$"

## Also, packages may depend on packages not in CRAN (e.g., in BioC or
## CRAN/Devel).  For such packages, we really have to use
## '--install=no'.  (A fake install still assumes that top-level
## require() calls can be honored.)
pkgs_install_no_regexp='^(ADaCGH|CoCo|GOSim|LMGene|NORMT3|ProbeR|RBloomberg|RGrace|SAGx|SLmisc|bcp|caMassClass|celsius|classGraph|crosshybDetector|lsa|mimR|multtest|pcalg)$'
## Reasons:
## * ADaCGH depends on aCGH (@BioC).
## * CoCo takes "too long", but fails with --install=fake (at least on
##   when R CMD check is run from cron, as for the daily checking).
## * GOSim depends on GOstats (@BioC).
## * LMGene depends on Biobase (@BioC).
## * NORMT3 keeps exploding memory on x86_64.
## * ProbeR depends on affy (@BioC).
## * RBloomberg depends on RDCOMClient (@Omegahat).
## * RGrace depends on RGtk (@Omegahat).
## * SAGx depends on Biobase (@BioC).
## * SLmisc depends on geneplotter (@BioC).
## * bcp depends on DNAcopy (@BioC).
## * caMassClass depends on PROcess (@BioC).
## * celsius depends on Biobase (@BioC).
## * classGraph depends on Rgraphviz (@BioC).
## * crosshybDetector depends on marray (@BioC).
## * lsa depends on Rstem (@Omegahat).
## * mimR depends on Rgraphviz (@BioC).
## * multtest depends on Biobase (@BioC).
## * pcalg depends on Rgraphviz (@BioC).

## Note that packages with a non-CRAN Suggests can "fully" be tested as
## _R_CHECK_FORCE_SUGGESTS_=FALSE is used.  At some point of time, these
## packages were as follows.
## * DDHFm suggests vsn (@BioC).
## * DescribeDisplay depends on ggplot.
## * GeneNet suggests graph and Rgraphviz (@BioC).
## * GeneTS depends on GeneNet.
## * SciViews/svWidgets suggests tcltk2.
## * VDCutil depends on Zelig.
## * Zelig suggests VGAM ("nowhere").
## * accuracy suggests Zelig.
## * boolean suggests Zelig.
## * caTools suggests ROC (@BioC).
## * ggplot suggests hexbin (@BioC)
## * limma suggests vsn (@BioC).
## * proto suggests graph (@BioC).

## Also note that there are packages with examples/tests/vignettes
## taking so long that it makes the whole process take more than a day.
## Should really have separate lists for these ...
## Here's a start:

## Functions for a db with package specific check options.
## For portability reasons, we don't take advantage of Bash arrays.
set_check_args () {
    eval "check_args_db_${1}='${2}'" ;
}
get_check_args () {
    eval echo '${'check_args_db_${1}'}' ;
}
add_check_args () {
    args=`get_check_args ${1}`
    if test -n "${args}"; then
	set_check_args ${1} "${args} ${2}"
    else
	set_check_args ${1} ${2}
    fi
}

## Should we initialize db with package specific check options to
## "nothing"?  (Something like
##   for p in ${pkgs_install_yes}; do
##     eval "unset check_args_db_${p}"
##   done
## We prefer organizing these options by package rather than by option
## (may be harder to type, but certainly is easier to maintain).  If I
## change our mind again, we can use something like:
##   pkgs_install_yes_no_tests="aster"
##   pkgs_install_yes_no_vignettes="Zelig"
##   for p in ${pkgs_install_yes_no_tests}; do
##     add_check_args ${p} "--no-tests"
##   done
##   for p in ${pkgs_install_yes_no_vignettes}; do
##     add_check_args ${p} "--no-vignettes"
##   done

set_check_args Zelig	"--no-vignettes"
set_check_args aster	"--no-tests"
