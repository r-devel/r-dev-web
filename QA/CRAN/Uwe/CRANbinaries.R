CRANbinaries <- function(srcdir = "d:\\Rcompile\\CRANpkg\\sources",
    cran.url = "http://cran.r-project.org/src/contrib",
    localdir = "d:\\Rcompile\\CRANpkg\\local",
    checkdir = "d:\\Rcompile\\CRANpkg\\check", 
    libdir = "d:\\Rcompile\\CRANpkg\\lib",
    windir = "d:\\Rcompile\\CRANpkg\\win",
    donotcheck = "d:\\Rcompile\\CRANpkg\\make\\DoNotCheck", 
    donotcompile = "d:\\Rcompile\\CRANpkg\\make\\DoNotCompile",
    check = TRUE, check.only = FALSE, upload = TRUE, 
    install.only = FALSE, rebuild = FALSE,
    putty.PKK = "ThePKKFile",
    server = "TheWebServer",
    serverdir = "TheServerDir",
    maj.version = maj.version,
    username = "TheUserName",
    mailMaintainer = FALSE,
    email = NULL){

############################################################################################
## Requisites:
# - Installation of current version of R, preferrably compiled on this machine
# - Complete compiler set, perl, Help Workshop, ..., and tools as mentioned in the docs
# - PuTTY (including pscp and plink!) for uploads and removals
# - blat (command line e-mail send tool) if(!is.null(email))
############################################################################################
## Arguments:
# srcdir:          CRAN sources, required to check for changes on CRAN 
#               (new / updated / withdrawn packages)
# cran.url:     location CRAN source packages can be mirrored from
# localdir:     later working directory for compilation etc.
# checkdir:     directory that contains the checks
# libdir:       directory that conatins the library
# windir:       directory used to store CRAN binaries locally
# donotcheck:   Packages forced to "R CMD check --install=no"
# donotcompile: do not compile Packages listed in here
# check:        Whether R CMD check should be executed for each package
# check.only:   Installs and checks all packages from *local* repository, 
#               but uploads check data only.
# upload:       Whether changes should affect CRAN (both upload and removal)
# install.only: only installs locally in order to set up an appropriate environment;
#               forces check=FALSE and upload=FALSE
# putty.PKK:    PuTTY PKK file for automatical authentication
# server:       Server from which the CRAN binaries are mirrored
# serverdir:    Directory on "server" from which the CRAN binaries are mirrored
# maj.version:  We are building binaries for this major R version 
#               (and name of corresponding subdirectory)
# username:     Username for "server"
# mailMaintainer: If TRUE, notification of failed R CMD check will be send to the 
#               corresponding package maintainer; requires "email" to be specified
# email:        Address used to send results of compiling from *and* to
############################################################################################
    subject <- paste("ERROR", "CRANpkgAUTO", maj.version, sep=".")
    if(!is.null(email))
        on.exit(print(shell(
                paste("blat", Infofile, "-to", email, "-subject", subject, "-f", email), 
            intern = TRUE)))

    library(utils)
    library(tools)
    # Hard-coding fields (we are indexing by number, so hard-coding is important here!)
    fields <- c("Package", "Bundle", "Priority", "Version", "Depends", "Suggests", "Imports", "Contains")
    if(install.only){
        check <- FALSE
        upload <- FALSE
    }
    if(check.only) check <- TRUE
    libdir <- file.path(libdir, maj.version, fsep = "\\")
    if(!file.exists(libdir)) shell(paste("mkdir", libdir))
    localdir <- file.path(localdir, maj.version, fsep = "\\")
    if(!file.exists(localdir)) shell(paste("mkdir", localdir))
    windir <- file.path(windir, maj.version, fsep = "\\")
    if(!file.exists(windir)) shell(paste("mkdir", windir))
    srcdir <- file.path(srcdir, maj.version, fsep = "\\")
    if(!file.exists(srcdir)) shell(paste("mkdir", srcdir))
    if(check){
        checkpath <- file.path(checkdir, maj.version, fsep = "\\")
        checklogpath <- file.path(checkpath, "log", fsep = "\\")
        if(!file.exists(checklogpath)) shell(paste("mkdir", checklogpath))    
    }
    if(upload){
        pscp.command <- paste("pscp -q -l", username, "-i", putty.PKK, "-batch")
        pscp.dir <- paste(server, ":", serverdir, "/", maj.version, sep = "")
    }
    Infofile <- file.path(windir, "_Info.txt", fsep = "\\")    
    donotcompile <- 
        if(file.exists(donotcompile)){
            scan(donotcompile, what = character(0)) 
        }else ""
    donotcheck <- 
        if(file.exists(donotcheck)){
            scan(donotcheck, what = character(0)) 
        }else ""
    setwd(srcdir)



    ## Function, looking for source packages and their version numbers
    ##  in local CRAN mirror
    p.local <- function(){
        files <- dir()
        files <- files[grep("tar.gz", files)]
        if(length(files)){
            splitted <- strsplit(files, "_")
            packages <- sapply(splitted, "[", 1)
            versno <- unlist(strsplit(sapply(splitted, "[", 2), ".tar.gz"))
            temp <- order(packages) # need Unix sorting for later CRAN comparisons
            return(list(packages = packages[temp], versno = versno[temp]))
        }else return(NULL)
    }
    p.local.res <- p.local()
    packages <- p.local.res$packages
    versno <- p.local.res$versno

    ## Looking for source packages and their version numbers on CRAN
    packcon <- url(file.path(cran.url, "PACKAGES"))
    cranpackages <- read.dcf(packcon, fields = fields)
    close(packcon)
    rownames(cranpackages) <- cranpackages[,1]
    cranpackages <- cranpackages[order(cranpackages[,1]), ]
    cran.packages <- cranpackages[,1]
    cran.versno <- cranpackages[,4]
    
    if(check.only || rebuild){
        brandnew <- paste(packages, "_", versno, ".tar.gz", sep = "")
        for(i in brandnew)
            shell(paste("cp", i, localdir))
        setwd(localdir) # Change WD!!!
        write(c(paste("Version:", maj.version, "\tDate/Time:", 
            format(Sys.time(), "%A, %d.%m.%Y / %H:%M")), 
            " ", "CHECKING:", "====", brandnew), file = Infofile)
    }else{
        ## Brandnew packages on CRAN (detecting, downloading, copying to later WD)
        brandnew <- !(cran.packages %in% packages)
        brandnew <- paste(cran.packages, "_", cran.versno, ".tar.gz", sep = "")[brandnew]
        if(length(brandnew)){
            from <- file.path(cran.url, brandnew)
            for(i in seq(along = brandnew)){
                download.file(from[i], destfile = brandnew[i], mode ="wb")
                shell(paste("cp", brandnew[i], localdir))
            }
        }
    
    
    
        ## Generating an information file that will collect all interesting changes and problems
        write(c(paste("Version:", maj.version, "\tDate/Time:", 
                format(Sys.time(), "%A, %d.%m.%Y / %H:%M")), 
                " ", "NEW:", "====", brandnew), file = Infofile)
    
        ## Withdrawn from CRAN (and deleting on local mirror)
        old <- !(packages %in% cran.packages)
        old <- paste(packages, "_", p.local.res$versno, ".tar.gz", sep = "")[old]
        for(i in seq(along = old))
            file.rename(old[i], paste("old/", old[i], sep = ""))
        write(c(" ", "WITHDRAWN:", "==========", old), file = Infofile, append = TRUE)
    
        ## After downloading, we need to check the local mirror again
        p.local.res <- p.local()
        packages <- p.local.res$packages
        versno <- p.local.res$versno
    
        ## Downloading updates from CRAN, 
        ## as well as sorting out replaced files on local mirror
        temp <- as.logical(abs(mapply(compareVersion, versno, cran.versno)))
        updates.old <- paste(packages, "_", versno, ".tar.gz", sep = "")[temp]
        for(i in seq(along = updates.old))
            file.rename(updates.old[i], paste("old/", updates.old[i], sep = ""))
        write(c(" ", "UPDATES REPLACED:", "=================", updates.old), 
            file = Infofile, append = TRUE)
        updates <- paste(cran.packages, "_", cran.versno, ".tar.gz", sep = "")[temp]
        if(length(updates)){
            from <- file.path(cran.url, updates)
            for(i in seq(along = updates)){
                download.file(from[i], destfile = updates[i], mode ="wb")
                shell(paste("cp", updates[i], localdir))
            }
        }
        setwd(localdir) ### Change WD!!!
        write(c(" ", "UPDATES:", "========", updates), file = Infofile, append = TRUE)
    
        ## These files have to be removed:
        oldzip <- sub(".tar.gz", ".zip", c(old, updates.old))
    
        ## New packages and updates can be handled equally from now on:
        brandnew <- c(brandnew, updates)
    }
    
    ## Sort out packages that is on the exclude list
    sdn <- sapply(strsplit(brandnew, "_"), "[", 1) %in% donotcompile
    write(c(" ", "DoNotCompile:", "=============", brandnew[sdn]), 
        file = Infofile, append = TRUE)
    brandnew <- brandnew[!sdn]

    ## These packages have not been checked:
    write(c(" ", "R CMD check --install:no", "========================", 
            brandnew[sapply(strsplit(brandnew, "_"), "[", 1) %in% donotcheck]), 
        file = Infofile, append = TRUE)


    ## We only need more action if new packages have been downloaded from CRAN
    if(length(brandnew)){
        status <- character(0)
        insttime <- checktime <- numeric(0)
        buildcommand <- 
            if(install.only || check.only){
                paste("R CMD INSTALL -l", libdir)
            }else 
                paste("R CMD INSTALL --build -l", libdir)
        
        ## The following four lines specify the correct installation order given there are depedencies.
        ## We do not need to care about it for checking, if everything is installed.
        brandnewResorted <- sapply(strsplit(brandnew, "_"), "[", 1)
        names(brandnew) <- brandnewResorted
        dependencies <- utils:::.make_dependency_list(brandnewResorted, cranpackages)
        brandnewResorted <- utils:::.find_install_order(brandnewResorted, dependencies)
        brandnewInstall <- if(is.null(brandnewResorted)) brandnew else brandnew[brandnewResorted]
        for(i in brandnewInstall){
            insttime <- c(insttime, system.time({
                shell(paste("tar xfz", i))
                temp <- strsplit(i, "_")[[1]][1]
                system(paste(buildcommand, temp, ">", 
                    paste(temp, "-install.out", sep = ""), "2>&1"), invisible = TRUE)
                #system(paste(buildcommand, temp), invisible = TRUE)
            })[3])
        }
        for(i in brandnew){        
            temp <- strsplit(i, "_")[[1]][1]
            instoutfile <- paste(temp, "-install.out", sep = "")
            if(check){
                checklog <- file.path(localdir,
                    paste(temp, ".Rcheck", sep = ""), "00check.log", fsep = "\\")
                checktime <- c(checktime, system.time({                    
                    if(temp %in% donotcheck){
                        checkerror <- system(paste('R CMD check --install=no', temp), 
                            invisible = TRUE)
                    }else
                        checkerror <- system(paste('R CMD check --install="check:', 
                            instoutfile, '" --library="', libdir, '" ', temp, sep = ""), 
                            invisible = TRUE)
                    ## checkerror <- system(paste('R CMD check', temp), invisible = TRUE)
                })[3]) 
                checklines <- readLines(checklog)
                checklogfile <- paste(temp, "-check.log", sep = "")
                tempstatus <- if(checkerror || any(grep("ERROR$", checklines))){
                        "ERROR"
                    }else
                        if(any(grep("WARNING$", checklines))) "WARNING" else "OK"

                status <- c(status, tempstatus)
                if(any(grep("^Installation failed.$", checklines)))
                    writeLines(c(checklines[1:(length(checklines)-1)], 
                        "The installation logfile:",
                        readLines(file.path(localdir, paste(temp, ".Rcheck", sep = ""), 
                            "00install.out", fsep = "\\"))
                        ), checklog)
                shell(paste("cp", checklog, 
                    file.path(checklogpath, checklogfile, fsep = "\\")))
               
                if(upload)
                    shell(paste(pscp.command, 
                        file.path(checklogpath, checklogfile, fsep = "\\"),
                        file.path(pscp.dir, "check")))
            
                ## Sending an e-mail to the maintainer if a packages fails R CMD check
                if((tempstatus == "ERROR") && mailMaintainer && !is.null(email)){
                    write(c("Dear package maintainer,", " ",
                        "this notification has been generated automatically.",
                        paste("Your package", i, "did not pass 'R CMD check' on"),
                        "Windows and will be omitted from the corresponding CRAN directory",
                        paste("(CRAN/bin/windows/contrib/", maj.version, "/).", sep = ""),
                        "Please check the attached log-file and consider to resubmit a",
                        "version that passes R CMD check on Windows.", 
                        R.version.string,
                        " ", "All the best,", "Uwe Ligges", 
                        "(Maintainer of binary packages for Windows)"),
                      file = "mailfile.tmp")
                    ## package maintainer's e-mail address
                    maintainer <- packageDescription(temp, getwd(), fields = "Maintainer")
                    maintainer <- strsplit(strsplit(maintainer, "<")[[1]][2], ">")[[1]]
                    shell(paste("blat mailfile.tmp",
                         "-to", maintainer,
                         "-cc", email,
                         "-subject \"Package", i, "did not pass R CMD check\"",
                         "-attacht", checklog, 
                         "-f", email))
                }
            }
            ## cleanup:
            shell(paste("rm -r -f", temp, instoutfile, 
                if(check) paste(temp, ".Rcheck", sep = ""))) 
        }
        if(check){
            write(c(" ", "STATUS:", "=======", paste(status, brandnew, sep = ":\t")), 
                file = Infofile, append = TRUE)

            ## Writing Status Information-File
            packages <- sapply(strsplit(brandnew, "_"), "[", 1)
            statusfile <- file.path(windir, "Status", fsep = "\\")
            if(file.exists(statusfile)){
                statusdata <- read.table(statusfile, as.is = TRUE, header = TRUE)
                if((!check.only) && (!rebuild))
                    statusdata <- statusdata[(statusdata[ , 1] %in% cran.packages), ]
                statusdata <- statusdata[!(statusdata[ , 1] %in% packages), ]
                statusdata <- rbind(statusdata, 
                    cbind(packages = packages, status = status, 
                        insttime = round(insttime), checktime = round(checktime)))
            }else
                statusdata <- data.frame(packages = packages, status = status, 
                    insttime = round(insttime), checktime = round(checktime))

            statusdata <- as.matrix(statusdata)
            
            cat(format(t(rbind(colnames(statusdata), 
                    statusdata[order(statusdata[,1]), ]))), 
                file = statusfile, sep = c(rep(" ", ncol(statusdata) - 1), "\n"))
            brandnew <- brandnew[status != "ERROR"]
        }

        ## Copy all relevant files and packages to the local binary mirror:
        if((!install.only) && (!check.only)){
            brandnewzip <- sub(".tar.gz", ".zip", brandnew)
            for(i in brandnewzip)
                shell(paste("cp", i, windir))
            ## successfully build packages (at least an existing zip file):
            managed <- grep("[.]zip", dir(), value = TRUE) 
            ## Determine new binary packages: 
            # packages <- sapply(strsplit(brandnew, "_"), function(x) x[1])
            # Upload
            if(upload) 
                for(i in brandnewzip)
                    print(shell(paste(pscp.command, i, pscp.dir), intern = TRUE))
        }
    }


    ## (Re)moving "oldzip" packages 
    if((!check.only) && (!rebuild) && length(oldzip)){
        oldzip.split <- sapply(strsplit(oldzip, "_"), "[", 1)
        oldzip.split <- oldzip.split %in% 
            c(donotcompile, if(length(brandnew)) packages[status == "ERROR"])
        for(i in seq(along = oldzip)){
            if(oldzip.split[i]){
                file.rename(file.path(windir, oldzip[i], fsep = "\\"), 
                    file.path(windir, "last", oldzip[i], fsep = "\\"))
            }else 
                file.rename(file.path(windir, oldzip[i], fsep = "\\"), 
                    file.path(windir, "old", oldzip[i], fsep = "\\"))
        }
            ## ... and write a new PACKAGES file for the "last" directory
        write_PACKAGES(dir = file.path(windir, "last"), fields = fields,
               type = "win.binary")
        if(file.exists(file.path(windir, "last", "PACKAGES")))
            shell(paste("gzip -c", file.path(windir, "last", "PACKAGES"), 
                        ">", file.path(windir, "last", "PACKAGES.gz")))

        ## applying changes on server as well:
        if(upload){
            if(length(oldzip[!oldzip.split]))
                print(shell(paste("plink -l", username, "-batch -i", putty.PKK, server, "rm", 
                    file.path(serverdir, maj.version, oldzip[!oldzip.split], collapse = " ")), 
                    intern = TRUE))
            if(length(oldzip[oldzip.split]))
                print(shell(paste("plink -l", username, "-batch -i", putty.PKK, server, "mv", 
                    file.path(serverdir, maj.version, c(oldzip[oldzip.split], "last"), 
                        collapse = " ")), 
                    intern = TRUE))
            if(file.exists(file.path(windir, "last", "PACKAGES")))
                print(shell(paste(pscp.command, 
                    file.path(windir, "last", c("PACKAGES", "PACKAGES.gz"), fsep = "\\", collapse = " "), 
                    file.path(pscp.dir, "last")), intern=TRUE))
        }
    }
    

    ## Determine existing packages:
    if((!install.only) && (!check.only) && (length(oldzip) || length(brandnew))){
        ## Write a new PACKAGES file
        write_PACKAGES(dir = windir, fields = fields, type = "win.binary")
        shell(paste("gzip -c", file.path(windir, "PACKAGES"), 
                    ">", file.path(windir, "PACKAGES.gz")))
        if(upload)
            print(shell(paste(pscp.command, file.path(windir, 
                c("PACKAGES", "PACKAGES.gz", "ReadMe", if(check) "Status"), 
                fsep = "\\", collapse = " "), pscp.dir), intern=TRUE))
    }      
    if(check.only)
        print(shell(paste(pscp.command, 
            file.path(windir, "Status", fsep = "\\"), 
            pscp.dir), 
          intern = TRUE))
        
    shell("rm -f *.zip *.tar.gz") # clean up
        
    ## Finally, let's get the Info file by e-mail
    subject <- paste("CRANpkgAUTO", maj.version, "OK", sep=".")
    return("finished!")        
}
