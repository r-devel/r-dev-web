## CRAN package build system

This directory contains the package build system used by CRAN on the
macOS platform to check, build and manage CRAN package builds.

The CRAN machines use a dedicated AFS volume `/Volumes/Builds` so the
default setup would be

    cd /Volumes/Builds
    svn co https://svn.r-project.org/R-dev-web/trunk/QA/Simon/packages

However, the location is configurable with the environment variable
`BASE` which defaults to `/Volumes/Builds/packages` if not set. It is
highly recommneded to use a dedicated volume such that mds can be
disabled for performance reasons, e.g. via
`sudo mdutils -i off /Volumes/Builds`.

One-time setup functions (compiling tools etc.) is performed by
running `make` in this directory.

The CRAN package sources are assumed to live in
`$BASE/CRAN/src/contrib/`. A local cache can be used to speed up look
up of the `DESCRIPTION` files (important if you work on full CRAN, but
not required for smaller repos). The cache is updated using
`make cache`.

The builds are located in a directory that is specific to the OS and
architecture. For example, macOS 11 (Big Bur) build on arm64 will use
`big-sur-arm64` as the target directory. See the `common` script for
the name definitions. The target directory contains following
subdirectories:

 * `Rlib` - target library (installed packages) 
 * `bin` - binary package repository
 * `results` - checks and logs
 * `extralib` (optional) - additional library (read-only), on CRAN
   machines we use this for Bioconductor packages

Each of the directories has version subdirectories of the form `x.y`
which is specific to a particular R version used. The version is
automatically detected at run-time from R version `x.y.z` so, for
example, R 4.1.1 will place `tgz` binaries in `bin/4.1`.

A single package can be checked with `mk.chk <name>`. If `mk.chk` is
run without a package name, it will construct a dependency graph and
check + build all packages sequentially. Note that by default apckage
must check successfully otherwise it is not built.

Note: the checks require a running X11 server. `mk.chk` will check for
servers using `DISPLAY` settings `:0` ... `:4` and will exit with an
error if none is working.

Optional environment variables affecting the check process:

 * `SKIP_CHK=1` if set no check is performed and the package(s) are
   built unconditionally
 * `UPDATE=1` skip any packages that already have a current binary tar
   ball present (this is the default for nightly runs)
 * `ERRONLY=1` only check packages that have ERROR or WARN check
   result (note: this will NOT build any new packages, only those that
   have been checked before)

The `mk.chk` process is serial. It is, however, possible to build a
parallel dependency schedule using the `multi-run.R` script (note
check top of the file for paths) which creates a `Makefile` with all
packages and calls `mk.chk` for each package individually while
defining dependencies and thus can be parallelized using `make -j8` or
similar.

--

by Simon Urbanek <simon.urbanek@R-project.org>
Last updated: 2021-09-23
