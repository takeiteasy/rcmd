build:
	$(CC) rcmd.m -framework Carbon -framework Cocoa -o rcmd

default: build

.PHONY: build default
