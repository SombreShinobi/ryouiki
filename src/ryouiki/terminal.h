#ifndef TERMINAL_H
#define TERMINAL_H

enum mode {
    normal,
    command
};

enum mode curr_mode;
void normalMode(void);
void commandMode(void);
void resetMode(void);
char readKey(void);
void resetScreen(void);
void fail(const char *c);

#endif
