#include <unistd.h>

int main (int argc, char **argv) {
  char *arg = 0;
  setuid(0);
  setgid(80);
  if (argc > 1) arg = argv[1];
  return execl("/Volumes/Builds/R4/pkg", "pkg", arg, 0);
}
