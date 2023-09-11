build:
		$(CC) -Isrc/ src/rcmd.m -framework Carbon -framework Cocoa -o rcmd

default: build

.PHONY: build default
