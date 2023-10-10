DEST ?= x86_64
TARGET := $(DEST)-linux-musl
MACHINE ?= $(shell uname -m)

CWD=$(shell pwd)


all: help


help:
	@echo	"This tool will build a micro rootfs as Initrd file"
	@echo	""
	@echo	"Usage: make DEST=[ x86_64 | aarch64 ]"
	@echo	""
	@echo	"It can be simplely writen like this:"
	@echo	""
	@echo	"make [ x86_64 | aarch64 ]"
	@echo	""
	@echo	"Supported make targets:"
	@echo	""
	@echo	"* bootstrap	-- default build all packages"
	@echo	"* toolchain	-- only build a arch-selected toolchain"
	@echo	"* download	-- download all dependency packages"
	@echo	"* rmstat	-- clean build progress status"


arm arm64 aarch64:
	make bootstrap DEST=aarch64


x86 x86_64 amd64:
	make bootstrap DEST=x86_64


bootstrap:
	@bash ./bootstrap.bash "$(DEST)"


download:
	@bash ./bin/batch-download


rmstat:
	@printf "\n"
	@printf "=> Remove $(DEST) progress state:\n"
	rm -rf "$(CWD)"/states/cross-*
	rm -rf "$(CWD)"/states/await-*
	rm -rf "$(CWD)"/states/box-*
	@printf "\n"


rmstat-aarch64:
	make rmstat DEST=aarch64


rmstat-x86_64:
	make rmstat DEST=x86_64


rmcross:
	@printf "=> Delete cross toolchain temp folders\n"
	rm -rf "$(CWD)"/crosstmp/archives/*
	rm -rf "$(CWD)"/crosstmp/stamps/*
	rm -rf "$(CWD)"/crosstmp/build/*
	rm -rf "$(CWD)"/crosstmp/src/*


clean: rmstat-aarch64 rmstat-x86_64 rmcross
	@printf "Current work dir $(CWD)\n\n"
	@printf "=> Delete work directory:\n"
	rm -rf "$(CWD)"/work/*

	@printf "=> Delete out sysroot files:\n"
	rm -rf "$(CWD)"/output/*

	@printf "=> Delete toolchain tmp files:\n"
	rm -rf "$(CWD)"/toolchain/*
	rm -f "$(CWD)"/context.log

	@printf "\nClean workspace finish!\n"
