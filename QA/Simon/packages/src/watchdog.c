#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>

static int external_abort = 0;

static void sig_stop(int sig) {
    external_abort = 1;
}

int main(int ac, char **av) {
    FILE *logf = 0;
    char **cav = (char**) malloc((ac + 4) * sizeof(char*));
    char *lfn = 0;
    int i = 0, base = 1, verb = 0, help = 0, tout = 60, last_status = 0;
    int did_timeout = 1;
    pid_t cid, pid;
    time_t start_time, current_time;
    
    while (++i < ac && av[i][0] == '-')
	switch(av[i][1]) {
	case 'v': verb++; break;
	case 'h': help = 1; break;
	case 't': if (++i < ac) tout = atoi(av[i]); else { fprintf(stderr, "ERROR: missing argument for -%c\n", av[i][1]); return 1; } break;
	case 'f': if (++i < ac) lfn = av[i]; else { fprintf(stderr, "ERROR: missing argument for -%c\n", av[i][1]); return 1; } break;
	}
    
    if (help) {
	printf("\n Usage: %s [-v] [-t <timeout>] [-f <log file>] command [...]\n\n", av[0]);
	return 0;
    }

    base = i;
    if (base == ac) {
	fprintf(stderr, "ERROR: missing command, see %s -h if in doubt.\n", av[0]);
	return 1;
    }

    if (tout < 1) {
	fprintf(stderr, "ERROR: invalid timeout (%d s)\n", tout);
	return 1;
    }

    pid = getpid();
    cid = fork();
    if (cid == 0) { /* child - the launching process */
	/* create a new process group -- the parent knows the id since it spawned us */
	cid = getpid();
	if (setpgid(cid, cid)) {
	    perror("(watchdog) ERROR: cannot create process group:");
	    return 1;
	}
	if (verb) fprintf(stderr, "(watchdog:%d) EXEC: ", cid);
	if (lfn) logf = fopen(lfn, "a");
	if (logf) fprintf(logf, "(watchdog[%d:%d]) %d 0 EXEC: ", pid, cid, (int)time(NULL));
	/* copy arguments for the subprocess */
	for (i = base; i < ac; i++) {
	    cav[i - base] = av[i];
	    if (verb) fprintf(stderr, "'%s' ", av[i]);
	    if (logf) fprintf(logf, "'%s' ", av[i]);
	}
	cav[ac - base] = 0; /* add the sentinel */
	if (verb) fprintf(stderr, "\n");
	if (logf) {
	    fprintf(logf, "\n");
	    fclose(logf);
	}
	
	execvp(av[base], cav);
	perror("(watchdog) ERROR: exec failed: ");
	return 1;
    }
    if (cid == -1) {
	perror("(watchdog) ERROR: cannot fork: ");
	return 1;
    }
    /* parent with cid child which is also the process group that the child will create */
    if (verb) fprintf(stderr, "(watchdog:%d) INFO: forked child %d\n", getpid(), cid);
    signal(SIGINT, sig_stop);
    start_time = time(NULL);
    sleep(1); /* give the child time to establish */
    while (!external_abort && (current_time = time(NULL)) <= start_time + tout) {
	int status = 0;
	pid_t n = waitpid(-cid, &status, WNOHANG);
	if (verb > 1) fprintf(stderr, "(watchdog:%d) INFO: wait = %d\n", getpid(), n);
	if (n > 0 && verb)
	    fprintf(stderr, "(watchdog:%d) INFO: child %d terminated (0x%04x)\n", getpid(), n, status);
	if (n == cid)
	    last_status = status;
	if (n < 0) {
	    /* this means all children are done - no timeout */
	    if (errno == ECHILD) {
		did_timeout = 0;
		break;
	    }
	    if (verb) {
		fprintf(stderr, "(watchdog:%d) INFO: ", getpid());
		perror("wait");
	    }
	}
	if (n != cid) sleep(1);
    }
    
    /* timeout - need to kill */
    if (did_timeout) {
	pid_t n;
	int status = 0;
	/* try sigkill first */
	if (verb) fprintf(stderr, "(watchdog:%d:%d) %s - sending SIGINT\n", getpid(), (int) (current_time - start_time), external_abort ? "ABORT" : "TIMEOUT");
	kill(-cid, SIGINT);
	while ((n = waitpid(-cid, &status, WNOHANG)) > 0) if (verb > 1) fprintf(stderr, "(watchdog:%d) INFO: n = %d\n", getpid(), n);
	if (n == 0) {
	    sleep(1); /* give it more time */
	    while ((n = waitpid(-cid, &status, WNOHANG)) > 0) if (verb > 1) fprintf(stderr, " - INFO: n = %d\n", n);
	    if (n == 0) {
		if (verb) fprintf(stderr, "(watchdog:%d:%d) TIMEOUT - no response, sending SIGTERM\n", getpid(), (int) (time(NULL) - start_time));
		if (n == 0) { /* more drastic measures */
		    kill(-cid, SIGTERM);
		    while ((n = waitpid(-cid, &status, WNOHANG)) > 0) if (verb > 1) fprintf(stderr, " - INFO: n = %d\n", n);
		    if (n == 0) {
			sleep(1);
			while ((n = waitpid(-cid, &status, WNOHANG)) > 0) if (verb > 1) fprintf(stderr, " - INFO: n = %d\n", n);
			if (n == 0 && verb) fprintf(stderr, "(watchdog:%d:%d) TIMEOUT - no response, giving up\n", getpid(), (int) (time(NULL) - start_time));
		    }
		}
	    }
	}
	/* it had to be killed, so mark a failure */
	if (verb) fprintf(stderr, "(watchdog:%d:%d) INFO: terminating with status code %d (terminated due to timeout)\n", getpid(), (int) (time(NULL) - start_time), 120);
	if (lfn) logf = fopen(lfn, "a");
	if (logf) {
	    fprintf(logf, "(watchdog[%d:%d]) %d %d KILL due to %s\n", pid, cid, (int) time(NULL), (int) (time(NULL) - start_time), external_abort ? "SIGINT" : "TIMEOUT");
	    fclose(logf);
	}
	return 120;
    }

    /* for EXITED we return the exit code, for SIGNALLED or
       STOPPED we pass it as 127 which should be enough for a failure */
    last_status = WIFEXITED(last_status) ? WEXITSTATUS(last_status) : 127;
    if (verb) fprintf(stderr, "(watchdog:%d:%d) INFO: terminating with status code %d\n", getpid(), (int) (time(NULL) - start_time), last_status);
    if (lfn) logf = fopen(lfn, "a");
    if (logf) {
	fprintf(logf, "(watchdog[%d:%d]) %d %d DONE (exit code %d)\n", pid, cid, (int) time(NULL), (int) (time(NULL) - start_time), last_status);
	fclose(logf);
    }
    return last_status;
}
