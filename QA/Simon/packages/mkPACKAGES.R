ver = Sys.getenv("VER")
if (!isTRUE(nzchar(ver))) ver <- "4.1"
fn = Sys.glob(file.path("bin",ver,"*.DESCRIPTION"))
type <- "mac.binary"
fields <- unique(c(tools:::.get_standard_repository_db_fields(type), "SHA256sum", NULL))
l = parallel::mclapply(fn, function(p) {
## tools/R/packages.R L202:
                temp <- tryCatch(read.dcf(p, fields = fields)[1L, ],
                                 error = identity)

                if(!inherits(temp, "error")) {
                    if(!"NeedsCompilation" %in% fields ||
                       is.na(temp["NeedsCompilation"])) {
                        temp["NeedsCompilation"] <-
                            if(length(grep("/libs/",readLines(gsub("DESCRIPTION$", "content", p))))) "yes" else "no"
	            }
		    md5 <- tryCatch(gsub(".*= ","",readLines(gsub("DESCRIPTION$", "MD5", p))), error=function(e) NULL)
		    sha256 <- tryCatch(gsub(".*= ","",readLines(gsub("DESCRIPTION$", "SHA256", p))), error=function(e) NULL)
                    if (length(md5)) temp["MD5sum"] <- md5[1L]
                    if (length(sha256)) temp["SHA256sum"] <- sha256[1L]
                    temp
                } else {
                    message(gettextf("reading DESCRIPTION for package %s failed with message:\n  %s",
		                                 sQuote(basename(p)),
                                     conditionMessage(temp)),
                            domain = NA)
	            list()
                }
}, mc.cores=8)
ll = sapply(l, length)
if (any(ll < 1)) l = l[ll > 0]
r = do.call(rbind, l)
tools:::.write_repository_package_db(r, ".", "xz")
