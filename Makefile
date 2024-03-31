SHELL=/bin/bash

USR              ?= /usr/local
INSTALL_DIR_NAME ?= pmt
INSTALL_BIN_NAME ?= $(INSTALL_DIR_NAME)
INSTALL_DIR 	   ?= $(USR)/share/$(INSTALL_DIR_NAME)
INSTALL_BIN_DIR  ?= $(USR)/bin
BUILD_DIR        ?= ./build

EXECUTABLE_PATH = $(INSTALL_DIR)/main.sh
BIN_EXECUTABLE_PATH = $(INSTALL_BIN_DIR)/$(INSTALL_BIN_NAME)

SOURCE_DIR := ./app
SOURCE_SERVER_DIR := ./server

all: help

help:
	cat Makefile.help

fedora:
	mkdir -p $(BUILD_DIR)
	bash $(SOURCE_SERVER_DIR)/fedora.sh $(BUILD_DIR)

watcher:
	watcher --clear --cmd "make --always-make build" $(SOURCE_DIR)/*

install:
	install -d $(INSTALL_DIR)
	cp -r $(SOURCE_DIR)/* $(INSTALL_DIR)
	chmod +x $(EXECUTABLE_PATH)
	mkdir -p $(INSTALL_BIN_DIR)
	ln -s $(EXECUTABLE_PATH) $(BIN_EXECUTABLE_PATH)

uninstall:
	rm -r $(INSTALL_DIR)
	rm $(BIN_EXECUTABLE_PATH)

clean:
	rm -rf $(BUILD_DIR)
