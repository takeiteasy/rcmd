build:
	$(CC) rcmd.m -framework Carbon -framework Cocoa -o rcmd

app: build
	sh appify.sh -s rcmd -n rcmd

install: build
	mv rcmd /usr/local/bin

install-app: app
	mv rcmd.app /Applications

default: build
all: app

.PHONY: build default
