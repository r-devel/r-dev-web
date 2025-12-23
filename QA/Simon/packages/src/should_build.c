/* this is a (hacky) performance shortcut tool:
   if UPDATE is set then this program finds the source file
   for the supplied package and based on its name checks whether
   the binary exists. Note that "oscode" as well as BASE
   are hard-coded below! Uses R.framework's Rversion.h to
   determine binary location as <base>/<oscode>-<arch>/bin/<ver>
   
   Usage: should_build <pkg>
          should_build <pkg> <program> [args..]

   - In the first usage only returns 0 if it should be built or
     1 if it should be skipped.
   - In the second usage returns 0 when skipped, otherwise runs
     <program> [args..] and returns its exit code.
   If UPDATE is not set, then acts as if binary doesn't exist.

   (C)2024 R-core, Author: Simon Urbanek, License: MIT */

static const char *os_code = "sonoma";
static const char *base = "/Volumes/Builds/packages";
static const char *src_contrib = "/Volumes/Builds/packages/CRAN/src/contrib";

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <string.h>
#include <unistd.h>

#ifdef __x86_64__
#define R_ARCH "x86_64"
#elif defined __arm64__
#define R_ARCH "arm64"
#else
#error "Unsupported architecture"
#endif

int R_version() {
    char buf[512];
    FILE *f = fopen("/Library/Frameworks/R.framework/Headers/Rversion.h","r");
    if (f)
	while(!feof(f) && fgets(buf, sizeof(buf) - 1, f)) {
	    if (buf[0] == '#' && buf[1] == 'd') {
		char *c = strstr(buf, "R_VERSION");
		if (c[9] == ' ' || c[9] == '\t') {
		    int ver = atoi(c+10);
		    fclose(f);
		    return ver;
		}
	    }
	}
    return -1;
}

static char sbuf[1024];

char *find_pkg(const char *name) {
    int name_len = strlen(name);
    const char *where = src_contrib;
    DIR *d = opendir(where);
    if (!d) {
	fprintf(stderr, "** ERROR: cannot find CRAN sources in '%s'\n", where);
	return 0;
    }
    while(1) {
	struct dirent *e = readdir(d);
	if (!e) break;
	if (!strncmp(e->d_name, name, name_len) && e->d_name[name_len] == '_') {
	    /* use lstat to check that we are not looking at a symlink */
	    struct stat st;
	    snprintf(sbuf, sizeof(sbuf), "%s/%s", where, e->d_name);
	    if (!lstat(sbuf, &st) && (st.st_mode & S_IFREG)) {
		char *n = strdup(e->d_name);
		closedir(d);
		return n;
	    }
	}
    }
    closedir(d);
    return 0;
}

int main(int ac, char **av) {
    int ver, i;
    char *pkg_file, *UPDATE = getenv("UPDATE");
    if (ac < 2) {
	fprintf(stderr, "** ERROR: missing package specification.\n");
	return 1;
    }
    /* check only if UPDATE is requested */
    if (UPDATE && *UPDATE) {
	ver = R_version();
	if (ver < 0) {
	    fprintf(stderr, "** ERROR: no R found!\n");
	    return 1;
	}
	if (!(pkg_file = find_pkg(av[1]))) {
	    fprintf(stderr, "** ERROR: package '%s' not found!\n", av[1]);
	    return 1;
	}
	printf("package: %s\n", pkg_file);
	i = strlen(pkg_file);
	if (i > 8 && !strcmp(pkg_file + i - 7, ".tar.gz")) { /* must have at least _.tar.gz */
	    struct stat st;
	    pkg_file[i - 7] = 0; /* remove ext */
	    snprintf(sbuf, sizeof(sbuf), "%s/%s-%s/bin/%d.%d/%s.tgz",
		     base, os_code, R_ARCH, (ver >> 16), ((ver >> 8) & 255), pkg_file);
	    printf("binary: %s --- ", sbuf);
	    if (!lstat(sbuf, &st) && (st.st_mode & S_IFREG)) {
		printf("present, skip\n");
		/* in exec mode we have to return 0 as if the
		   build was run successfullly */
		return (ac > 2) ? 0 : 1;
	    }
	    printf("missing, build\n");
	}
    }
    if (ac > 2) { /* exec */
	av[ac] = 0; /* this may be illagal :P */
	return execv(av[2], av + 2);
    }
    return 0;
}
