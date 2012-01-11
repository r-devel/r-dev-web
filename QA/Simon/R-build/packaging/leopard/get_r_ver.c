#include <Rversion.h>
#include <stdio.h>
int main() { printf("%s.%s %s (%s-%s-%s r%s)\n", R_MAJOR, R_MINOR, R_STATUS, R_YEAR, R_MONTH, R_DAY, R_SVN_REVISION); return 0; }
