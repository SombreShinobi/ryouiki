CC=gcc
CFLAGS=-Wall -Wextra -pedantic -std=c99
OUT=ryouiki

ryouiki: src/ryouiki/main.c src/ryouiki/terminal.c
	$(CC) src/ryouiki/main.c src/ryouiki/terminal.c -o $(OUT) $(CFLAGS)
