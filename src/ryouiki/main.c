#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include "terminal.h"


int main(void) {
    enableRawMode();

    while (1) {
        char c = '\0';
        if (read(STDIN_FILENO, &c, 1) == -1 && errno != EAGAIN) {
            fail("read");
        }

        if (iscntrl(c)) {
            printf("%d\r\n", c);
        } else {
            printf("%d, ('%c')\r\n", c, c);
        }

        if (c == 'q')
            break;
    }

    return 0;
}
