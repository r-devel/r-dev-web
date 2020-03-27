/* On recent macOS we have to create R.framework
   as root since /Library/Frameworks is restricted.
   Then we change the ownership so it can be
   populated by $USER
   Note that for security we only allow user names with [a-z]
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static char *user = 0, buf[256];

int main(int argc, char **argv) {
  user = getenv("USER");
  if (!user) {
    fprintf(stderr, "ERROR: USER not set\n");
    return 1;
  }
  user = strdup(user);
  if (!user)
    return 1;
  {
    char *c = user;
    while (*c >= 'a' && *c <= 'z') c++;
    *c = 0;
  }
  snprintf(buf, sizeof(buf) - 1, "/usr/sbin/chown %s /Library/Frameworks/R.framework", user);
  buf[sizeof(buf) - 1] = 0;
  setuid(0);
  system("/bin/rm -rf /Library/Frameworks/R.framework");
  system("/bin/mkdir /Library/Frameworks/R.framework");
  system(buf);
  return 0;
}
