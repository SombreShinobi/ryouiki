#include "terminal.h"
#include <stdlib.h>
#include <unistd.h>

#define CTRL_KEY(k) ((k) & 0x1f)

void processCommand(char c) {
    switch (c) {
    case CTRL_KEY('c'):
        normalMode();
        break;
    case 'q':
        resetScreen();
        resetMode();
        exit(0);
        break;
    }
}

void processNormalInput(char c) {
    switch (c) {
    case ':':
        commandMode();
        break;
    }
}

void processKeypress(void) {
    char c = readKey();

    switch (curr_mode) {
    case normal:
        processNormalInput(c);
        break;
    case command:
        processCommand(c);
        break;
    }
}

void drawRows(void) {
    int y;

    for (y = 0; y < 24; y++) {
        write(STDOUT_FILENO, "~\r\n", 3);
    }
}

void refreshScreen(void) {
    resetScreen();
    drawRows();

    write(STDOUT_FILENO, "\x1b[H", 3);
}

int main(void) {
    normalMode();

    while (1) {
        refreshScreen();
        processKeypress();
    }

    return 0;
}
