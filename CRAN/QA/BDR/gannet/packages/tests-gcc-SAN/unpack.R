source('../common.R')
## forensim infinite-loops in tcltk
## BayesXsrc was killed using 31Gb for a compile, rmatio 12.5GB
## mpMap2 uses over 1h CPU time
## RcppSMC used 50GB for an R process.
stoplist <- c(stoplist, 'sanitizers', 'BayesXsrc', 'crs', 'forensim', "rmatio",'mpMap2', 'icamix', 'fdaPDE', 'gllvm', 'glmmTMB', 'RcppSMC', 'mlpack')
## blavaan uses 10GB, ctsem 19GB, rstanarm 8GB
stan <- c(stan0, tools::dependsOnPkgs('StanHeaders',,FALSE))
cgal <- tools::dependsOnPkgs('RcppCGAL', 'LinkingTo', FALSE)
stoplist <- c(stoplist, stan, cgal)
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
	"netmeta", "trust", "SurvMetrics", "boostmtree", "cjbart",
	"ggRandomForests", "survcompare", "survivalSL", "SIMMS", "PriceIndices",
	"AhoCorasickTrie", "CRMetrics", "ExpImage", "FD", "GRIN2", "ICAMS",
	"LoopRig","MatchIt", "MicroSEC", "OptimalGoldstandardDesigns",
	"PAMscapes", "PlasmaMutationDetector2", "ROI.plugin.highs", 
	"SeedMatchR", "SeuratObject", "SpatialDDLS", "TSDT", "TransProR",
	"binaryMM", "bioRad", "bioregion", "datetimeoffset", "describedata",
	"designmatch", "distributional", "ebvcube", "epoxy",
	"gasanalyzer", "gawdis", "ggpattern", "lava", "lavaSearch2",
	"lfe", "nimbleAPT", "ondisc", "phenofit", "plotthis", "priorCON", 
	"redist", "redistmetrics", "remap", "rnaCrosslinkOO", "seqmagick", 
	"simMP", "speakeasyR", "tidygenomics", "tidyllm", "cobalt", 'CoImp',
	'FeatureHashing', 'GiNA', 'PriceIndices', 'TSDI', "CRMetrics")
stoplist <- setdiff(stoplist, ex)
do_it(stoplist, TRUE, extras = ex)
