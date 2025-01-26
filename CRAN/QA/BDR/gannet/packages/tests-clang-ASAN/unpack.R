source('../common.R')
## forensim infinite-loops in tcltk
## pdc takes forever to compile
## RcppSMC used 60GB
stoplist <- c(stoplist, noclang, "sanitizers", "pdc", "forensim", "rcss", "RcppSMC", "BRugs")
#do_it(stoplist, TRUE)
ex <- c("Evacluster", "corrplot", "dartR", "fdaPDE", "grainscape",
       "multilaterals", "plotmm", "shipunov",
       "stopdetection", "treeheatr", "simputation",
        "CAST","ChemoSpec", "CorMID", "DBpower", "DRviaSPCN",
        "HospitalNetwork", "MOCHA", "NMRphasing", "PVplr", "PieGlyph",
        "RCTS", "ROI.models.globalOptTests", "SNPfiltR", "STGS",
        "SlaPMEG", "cherry", "bigmds", "bullseye", "clam", "classmap",
        "coil", "confintROB", "dartR.base", "dartR.captive", "effectsize",
        "embed", "enviGCMS", "georob", "gamCopula", "glycanr", "grec",
        "lori", "mratios", "mregions2", "presmTP", "speaq", "tidyfit",
        "interactions", "jtools", "micEconDistRay", "multcomp", "orbital",
        "geomtextpath", "hasseDiagram", "recolorize", "SuperLearner",
	"netmeta")
stoplist <- setdiff(stoplist, ex)
do_it(stoplist, TRUE, extras = ex)

