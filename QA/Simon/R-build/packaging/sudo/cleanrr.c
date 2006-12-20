#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int ac, char **av) {
  if (!getenv("RRPATH")) {
    fprintf(stderr, "Invalid environment.\n");
    exit(1);
  }
  setgid(80);
  setuid(0);
  return execlp("/bin/rm","rm","-rf",getenv("RRPATH"),0);
}
