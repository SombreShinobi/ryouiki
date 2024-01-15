#ifndef TERMINAL_H
#define TERMINAL_H

enum mode {
    raw,
    command
};

enum mode curr_mode;
void enableRawMode(void);
void disableRawMode(void);
void fail(const char *c);

#endif
