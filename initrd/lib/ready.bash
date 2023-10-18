#!/bin/bash

set -e

create_sysroot_dir() {
    section "Create directory structure in $ROOTFS"

    mkdir -p "${ROOTFS}"/{bin,cdrom,dev,etc,proc,sys,mnt,opt,root,run,sbin,tmp,usr}
    mkdir -p "$ROOTFS"/usr/{bin,sbin,etc,lib,libexec,include,share}

    ln -n -sf lib "$ROOTFS"/usr/lib64
    ln -n -sf usr/lib "$ROOTFS"/lib
    ln -n -sf . "$ROOTFS"/usr/local
    ln -n -sf lib "$ROOTFS"/lib64
}

