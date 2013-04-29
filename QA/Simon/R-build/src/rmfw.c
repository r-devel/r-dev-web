#include <unistd.h>

int main(int argc, char **argv) {
  setuid(0);
  system("/bin/rm -rf /Library/Frameworks/R.framework");
  return 0;
}
