#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

struct termios default_termios;

void fail(const char *s) {
    perror(s);
    exit(1);
}

void disablerawMode(void) {
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &default_termios) == -1) {
        fail("tcsetattr");
    }
}

void enableRawMode(void) {
    if (tcgetattr(STDIN_FILENO, &default_termios) == -1) {
        fail("tcgetattr");
    }

    atexit(disablerawMode);

    struct termios raw = default_termios;
    raw.c_iflag &= ~(BRKINT | INPCK | ICRNL | ISTRIP | IXON);
    raw.c_oflag &= ~(OPOST);
    raw.c_cflag |= (CS8);
    raw.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN);
    raw.c_cc[VMIN] = 0;
    raw.c_cc[VTIME] = 1;

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1) {
        fail("tcsetattr");
    }
}
