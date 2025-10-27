#include <stdio.h>
#include <stdlib.h>
#include <pty.h>
#include <assert.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>

#include <termios.h>
#include <sys/ioctl.h>

#define BUFFER_SIZE 4096

int pid = -1;
int master_fd = -1;

void slave() {
    setenv("TERM", "xterm-256color", 1);
    execlp("bash", "bash", "-i", NULL);
    printf("We shouldn't be here");
    exit(EXIT_FAILURE);
}

void master() {
    char buffer[BUFFER_SIZE];

    while(1) {
        ssize_t n = read(master_fd, buffer, sizeof(char)*(BUFFER_SIZE-1));
        if (n > 0) {
            buffer[n] = '\0';

            fwrite(buffer, sizeof(char), n, stdout);
            fflush(stdout);
        } else {
            break;
        }
    }

    close(master_fd);
    waitpid(pid, NULL, 0);
}

int main(void) {
    pid = forkpty(&master_fd, NULL, NULL, NULL);
    if (pid == -1) {
        printf("forkpty failed (pid): %d\n", errno);
        return EXIT_FAILURE;
    }

    if (pid == 0) {
        slave();
    } else {
        master();
    }

    return EXIT_SUCCESS;
}