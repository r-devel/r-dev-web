#include <Rversion.h>
#include <stdio.h>
int main() {
  if (sizeof(R_SVN_REVISION) < 6)
    printf("%s.%s %s (%s-%s-%s r%d)\n", R_MAJOR, R_MINOR, R_STATUS, R_YEAR, R_MONTH, R_DAY, (int) R_SVN_REVISION);
  else
    printf("%s.%s %s (%s-%s-%s r%s)\n", R_MAJOR, R_MINOR, R_STATUS, R_YEAR, R_MONTH, R_DAY, (char*) R_SVN_REVISION);
  return 0;
}
