#include "terminal.h"
#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

enum mode curr_mode;
struct termios default_termios;

void resetScreen(void) {
    write(STDOUT_FILENO, "\x1b[2J", 4);
    write(STDOUT_FILENO, "\x1b[H", 3);
}

void fail(const char *s) {
    resetScreen();

    perror(s);
    exit(1);
}

void resetMode(void) {
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &default_termios) == -1) {
        fail("tcsetattr");
    }
}

void commandMode(void) {
    if (tcgetattr(STDIN_FILENO, &default_termios) == -1) {
        fail("tcgetattr");
    }

    atexit(resetMode);

    struct termios raw_termios = default_termios;
    raw_termios.c_lflag &= ~(ISIG);

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw_termios) == -1) {
        fail("tcsetattr");
    }

    curr_mode = command;
}

void normalMode(void) {
    if (tcgetattr(STDIN_FILENO, &default_termios) == -1) {
        fail("tcgetattr");
    }

    atexit(resetMode);

    struct termios raw_termios = default_termios;
    raw_termios.c_iflag &= ~(BRKINT | INPCK | ICRNL | ISTRIP | IXON);
    raw_termios.c_oflag &= ~(OPOST);
    raw_termios.c_cflag |= (CS8);
    raw_termios.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN);
    raw_termios.c_cc[VMIN] = 0;
    raw_termios.c_cc[VTIME] = 1;

    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw_termios) == -1) {
        fail("tcsetattr");
    }

    curr_mode = normal;
}

char readKey(void) {
    int nread = 0;
    char c;

    while ((nread == read(STDIN_FILENO, &c, 1)) == 1) {
        if (nread == -1 && errno != EAGAIN) {
            fail("read");
        }
    }

    return c;
}
