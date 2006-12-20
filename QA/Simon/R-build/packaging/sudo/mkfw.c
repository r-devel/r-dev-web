#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int ac, char **av) {
  char buf[512];
  buf[511]=0;

  if (!getenv("FWPATH") || !getenv("RRPATH")) {
    fprintf(stderr, "Invalid environment.\n");
    exit(1);
  }
  setgid(80);
  setuid(0);
  snprintf(buf, 511, "tar fc - \"%s\"|tar fx - -C  \"%s/R-fw/cont\"; chmod 41775 \"%s/R-fw/cont/Library\"",
	   getenv("FWPATH"),getenv("RRPATH"),getenv("RRPATH"));
  return execlp("/bin/sh","sh","-c",buf,0);
}
