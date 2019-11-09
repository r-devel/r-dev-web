#### Do all you need before blogging    --->>> see `./README`
#### ===============                                  ^^^^^^   conveniently run this in shell :
"
   R --no-save < Startup.R
"

### "Bootstrap" for finding correct directory

if(!dir.exists("Blog")) {

    user <- Sys.getenv("USER")
    dirRdev <-
        switch(user,
               "maechler" = "~/R/D/R-dev-web",
               ## add your username (and correct path!)  here (and commit this file!)
               stop("user", user, "not yet listed .."))

    if(!dir.exists(dirRdev))
        stop(dirRdev, " is not a valid directory.
   You must have a local checkout of  https://svn.r-project.org/R-dev-web/trunk")

    setwd(dirRdev)
    if(!dir.exists("Blog")) stop("'Blog' must be a valid subdirectory of 'dirRdev'")

    setwd("Blog")
}

##' Install package if needed, "needed" := cannot requireNamespace(.) correctly
install.pkgifNeeded <- function(pkg, ...) {
    stopifnot(is.character(pkg), length(pkg) == 1)
    if(pkg %in% loadedNamespaces()) {
    } else if(requireNamespace(pkg)) {
        unloadNamespace(pkg) # revert to previous state
    } else {
        cat(sprintf("Did not find (a valid) '%s' package.  Trying to install it .. \n", pkg))
        install.packages(pkg, ...) # or fail
    }
}

requireStrongly <- function(pkg, ...) {
    install.pkgifNeeded(pkg, ...)
    require(pkg, character.only=TRUE)
}

requireStrongly("blogdown") # -> library(blogdown)

## 5. {README}
for(pkg in c("dplyr", "MASS")) {
    install.pkgifNeeded(pkg)
}

## 6. {README}
system("svn update")

cat("Ideally you don't see anything here (unneeded local files may harm later, when you add new):\n")
system("svn status")

## In preparation to   build_site()   {needed, e.g. for MM}

attachedPkgs <- sub("^package:","", grep("^package:", search(), value=TRUE))
basePkgs <- tools:::.get_standard_package_names()[["base"]]
if(length(xtrPkgs <- setdiff(attachedPkgs, c(basePkgs,"blogdown")))) {
    cat("Have extra packages in search() - may \"harm\" the search conflicts blog:\n")
    print(xtrPkgs)
    cat("Tring to detach(.) them now .. \n")
    for(p in xtrPkgs) {
        cat(p,": "); detach(paste0("package:",p), character.only=TRUE)
        cat("[Ok]\n")
    }
}


## 7. {README}
build_site()
##
## Rendering content/post/2018-03-23-dll-limit.Rmd
## Rendering content/post/2018-10-12-if-cond-length.Rmd
## ....

## 8. {README}
serve_site()


