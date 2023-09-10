build:
	$(CC) rcmd.m -framework Carbon -framework Cocoa -framework CoreServices -o rcmd

default: build

.PHONY: build default
