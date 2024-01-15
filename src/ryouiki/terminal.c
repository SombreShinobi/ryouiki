#include "terminal.h"
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

enum mode curr_mode;
struct termios default_termios;

void fail(const char *s) {
    perror(s);
    exit(1);
}

void disableRawMode(void) {
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &default_termios) == -1) {
        fail("tcsetattr");
    } else {
        curr_mode = command;
    }
}

void enableRawMode(void) {
    if (tcgetattr(STDIN_FILENO, &default_termios) == -1) {
        fail("tcgetattr");
    }

    atexit(disableRawMode);

    struct termios raw_termios = default_termios;
    raw_termios.c_iflag &= ~(BRKINT | INPCK | ICRNL | ISTRIP | IXON);
    raw_termios.c_oflag &= ~(OPOST);
    raw_termios.c_cflag |= (CS8);
    raw_termios.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN);
    raw_termios.c_cc[VMIN] = 0;
    raw_termios.c_cc[VTIME] = 1;

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw_termios) == -1) {
        fail("tcsetattr");
    } else {
        curr_mode = raw;
    }
}
