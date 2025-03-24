## Release scheduler
prefix <- "$HOME/scripts"
crontabline <- function(T, hr, min, prg, ...)
{
  lT <- as.POSIXlt(T)
  m <- lT$mon+1
  d <- lT$mday
  timing <- paste(min, hr, d, m, "*")
  prg <- paste(prefix, prg, sep="/")
  cmd <- paste(prg, paste(shQuote(c(...)), collapse=" "))
  paste(timing, cmd)
}

Sc <- function(what, when) cat(what, strftime(when, "%a %F\n"))
Dt <- function(when) strftime(when, "%A %F")
Dt_ <- function(when) strftime(when, "%F")

DoSubst <- function(blurb, ...)
{
  l <- list(...)
  patterns <- sprintf("@%s@", names(l))
  for (i in seq_along(l))
    blurb <- gsub(patterns[[i]], l[[i]], blurb, fixed=TRUE)
  blurb
}

SchedulePatchRelease <- function(date, Version, Nick, fast=FALSE)
{
  T <- as.Date(date)
  
  T_remind <- T - if (fast) 8 else 12
  T_beta <- T - if (fast) 7 else 10
  T_RC <- T - if (fast) 3 else 7

  cat("\nKey Dates:\n")
  Sc("START\t\t\t", T_beta)
  Sc("CODE FREEZE\t\t", T_RC)
  Sc("RELEASE\t\t\t", T)
  
  remind <- crontabline(T_remind, "00", "02", 
                      "R-remind-CRAN", 
                      paste("Update directory for version", Version))
  beta <- crontabline(T_beta, "00", "02", 
                      "R-set-version", paste(Version, "beta"), Nick)
  fixNEWS <- crontabline(T_beta, "00", "04", 
                      "R-fixup-NEWS", Version)
  RC <- crontabline(T_RC, "00", "02", 
                    "R-set-version", paste(Version, "RC"))
  final <- crontabline(T, "09", "00", "R-build-dist", Version)
  cat("\nCrontab Entries:\n")
  cat(remind, beta, fixNEWS, RC, final, sep="\n")
  
  cat("\nEntry for R-dev-web index.html\n")
  blurb <- "
<p>The release of @VERSION@ (\"@NICK@\") is 
scheduled for @RELEASE@.
Release candidate tarballs will be made available
during the week up to the release.

<p> Please refer to the 
<a href=\"release-checklist.html\">generic checklist</a> for details
  <ul>
  <li>@START@: <i>START</i> (@VERSION@ beta)
  <li>@CODEFREEZE@: <i>CODE FREEZE</i> (@VERSION@ RC)
  <li>@RELEASE@: <i>RELEASE</i> (@VERSION@)
  </ul>
  "
  cat(DoSubst(blurb, 
              VERSION=Version, 
              NICK=Nick, 
              START=Dt(T_beta),
              CODEFREEZE=Dt(T_RC),
              RELEASE=Dt(T)
  ))
  
cat("\nEntry for R-project web md/index.md\n")
  blurb <- "
-   [**R version @VERSION@ (@NICK@) prerelease versions**](http://cran.r-project.org/src/base-prerelease) will appear starting @START@. Final release is scheduled for @RELEASE@. 
"
  cat(DoSubst(blurb, 
              VERSION=Version, 
              NICK=Nick, 
              START=Dt(T_beta),
              CODEFREEZE=Dt(T_RC),
              RELEASE=Dt(T)
  ))
  
  cat("\nEntries for ~/R-release/VERSION-INFO.dcf\n")
  cat("Edit file, then:\n")
  cat("rsync -aOvuz --no-p --exclude='*~' ~/R-release/ cran.r-project.org:/srv/ftp/pub/R/src/base\n")
  blurb <- "
Next-release: @VERSION@
Next-nick: @NICK@
Next-date: @RELEASE@
"
  cat(DoSubst(blurb, 
              VERSION=Version, 
              NICK=Nick, 
              RELEASE=Dt_(T)
  ))
  
  
  
}
ScheduleRegularRelease <- function(date, Version, Nick)
{
  T <- as.Date(date)
  
  cat("\nKey Dates:\n")

  Sc("START\t\t\t", T-31)
  Sc("GRAND-FEATURE FREEZE\t", T - 28)
  Sc("FEATURE FREEZE\t\t", T - 14)
  Sc("CODE FREEZE\t\t", T - 7)
  Sc("RELEASE\t\t\t", T)
  
  Version0 <- gsub("\\.0$", "", Version)
  VersionP <- gsub("\\.0$", "-patched", Version)
  remind <- crontabline(T-31, "00", "02", 
                        "R-remind-CRAN", 
                        "Set up directories for the new R-devel")
  remindSimon <- crontabline(T-28, "00", "02", 
                        "R-send-reminder",
                        "simon.urbanek@R-project.org",
                        "Update RSS and Bugzilla")
  branch <- crontabline(T-28, "00", "02", "R-create-branch", Version0)
  fixNEWS <- crontabline(T-28, "00", "10", 
                      "R-fixup-NEWS", Version)
  beta <- crontabline(T-14, "00", "02", 
                      "R-set-version", paste(Version, "beta"), Nick)
  RC <- crontabline(T-7, "00", "02", 
                    "R-set-version", paste(Version, "RC"))
  remind2 <- crontabline(T-3, "00", "02", 
                        "R-remind-CRAN", 
                        paste("Set up directory for", VersionP))
  final <- crontabline(T, "09", "00", "R-build-dist", Version)
  cat("\nCrontab Entries:\n")
  cat(remind, branch, remindSimon, fixNEWS, beta, RC, remind2, final, sep="\n")
  
  cat("\nEntry for R-dev-web index.html\n")
  blurb <- "
  <p>The release of @VERSION@ (\"@NICK@\") is 
  scheduled for @RELEASE@. Prerelease
  source tarballs (and binaries for some platforms) are being made
  available during the 4 weeks until the release.

<p>The schedule for @VERSION@ is as follows
<ul>
<li>@START@:  <i>START</i> 
<li>@GRANDFEATUREFREEZE@: <i>GRAND-FEATURE FREEZE</i> (@VERSION@ alpha) </li> 
<li>@FEATUREFREEZE@: <i>FEATURE FREEZE</i> (@VERSION@ beta) </li>
<li>@CODEFREEZE@: <i>CODE FREEZE</i> (@VERSION@ RC) </li>
<li>@PRERELEASE@: <i>PRERELEASE</i></li>
<li>@RELEASE@: <i>RELEASE</i> (@VERSION@) </li>
</ul>
  "
  cat(DoSubst(blurb, 
              VERSION=Version, 
              NICK=Nick, 
              START=Dt(T-31),
              GRANDFEATUREFREEZE=Dt(T-28),
              FEATUREFREEZE=Dt(T-14),
              CODEFREEZE=Dt(T-7),
              PRERELEASE=Dt(T-3),
              RELEASE=Dt(T)
              ))
  
  cat("\nEntry for R-project web md/index.md\n")
  blurb <- "
-   [**R version @VERSION@ (@NICK@) prerelease versions**](http://cran.r-project.org/src/base-prerelease) will appear starting @START@. Final release is scheduled for @RELEASE@. 
  "
  cat(DoSubst(blurb, 
              VERSION=Version, 
              NICK=Nick, 
              START=Dt(T-31),
              GRANDFEATUREFREEZE=Dt(T-28),
              FEATUREFREEZE=Dt(T-14),
              CODEFREEZE=Dt(T-7),
              RELEASE=Dt(T)
  ))
  
  cat("\nEntries for ~/R-release/VERSION-INFO.dcf\n")
  cat("Edit file, then:\n")
  cat("rsync -aOvuz --no-p --exclude='*~' ~/R-release/ cran.r-project.org:/srv/ftp/pub/R/src/base\n")
  blurb <- "
Next-release: @VERSION@
Next-nick: @NICK@
Next-date: @RELEASE@
"
  cat(DoSubst(blurb, 
              VERSION=Version, 
              NICK=Nick, 
              RELEASE=Dt_(T)
  ))
  
  
}

SchedulePatchRelease("2025-02-28", "4.4.3", "Trophy Case", fast=FALSE)
ScheduleRegularRelease("2025-04-11", "4.5.0", "How About a Twenty-Six")
