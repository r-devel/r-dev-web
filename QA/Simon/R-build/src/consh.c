#include <pthread.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

FILE *lf;

const char *prefix[3] = { "", "   ", "** " };
const char *suffix[3] = { "", "", "" };

int closing=0;
int done=0;

struct tis {
  int fd;
  int id;
};

pthread_mutex_t write_mutex = PTHREAD_MUTEX_INITIALIZER;

void *wt(void *arg) {
  struct tis *a = (struct tis*) arg;
  int fd = a->fd;
  int id = a->id;

  while (1) {
    char buf[1024];
    struct timeval timv;
    fd_set readfds;
    int ro = 0;
    timv.tv_sec=0;
    timv.tv_usec=200000;
    FD_ZERO(&readfds);
    FD_SET(fd,&readfds);
    select(fd+1,&readfds,0,0,&timv);
    if (FD_ISSET(fd,&readfds)) {
      int n = read(fd, buf+ro, 1023-ro);
      if (n<1) break;
      {
	char *c = buf, *d = buf;
	while (*c) {
	  while (*c && *c!='\r' && *c!='\n') c++;
	  if (*c) {
	    *c=0;
	    if (lf) {
	      pthread_mutex_lock(&write_mutex);
	      fprintf(lf, "%s%s%s\n", prefix[id], d, suffix[id]);
	      pthread_mutex_unlock(&write_mutex);
	    }
	    c++; d=c;
	  }
	}
	if (*d && d!=buf) {
	  ro=strlen(d)+1;
	  memmove(buf, d, ro);	  
	}
      }
    } else if (closing) break;
  }
  done|=id;
}

int main(int ac, char **av) {
  int px[2], py[2];
  pthread_attr_t ta;
  pthread_t pt;

  struct tis tx={0,1}, ty={0,2};
  int rv;

  if (ac<3) {
    fprintf(stderr, "\n Usage: consh <command> <logfile> [-a]\n\n");
    return 1;
  }

  lf = fopen(av[2], (ac>3 && !strcmp(av[3],"-a"))?"a":"w");
  if (!lf)
    fprintf(stderr, "*** ERROR: consh unable to create %s, all output will be lost\n", av[2]); 

  pipe(px);
  pipe(py);
  dup2(px[1], STDOUT_FILENO); tx.fd=px[0];
  dup2(py[1], STDERR_FILENO); ty.fd=py[0];
  
  pthread_attr_init(&ta);
  pthread_attr_setdetachstate(&ta, PTHREAD_CREATE_DETACHED);
  pthread_create(&pt, &ta, wt, &tx);
  pthread_create(&pt, &ta, wt, &ty);
  rv=system(av[1]);
  closing=1;
  fflush(stderr);
  fflush(stdout);
  fclose(stderr);
  fclose(stdout);
  if (lf) fclose(lf);
  while (done!=3) ;
  return rv;
}
