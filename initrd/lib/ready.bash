#!/bin/bash

set -e

create_sysroot_dir() {
    section "Create directory structure in $ROOTFS"

    mkdir -pv "$ROOTFS"

    for i in bin cdrom dev etc proc sys mnt opt root run sbin tmp usr; do
        mkdir -p "${ROOTFS}"/$i
    done

    mkdir -p "$ROOTFS"/usr/bin
    mkdir -p "$ROOTFS"/usr/sbin
    mkdir -p "$ROOTFS"/usr/etc
    mkdir -p "$ROOTFS"/usr/lib
    mkdir -p "$ROOTFS"/usr/libexec
    mkdir -p "$ROOTFS"/usr/include
    mkdir -p "$ROOTFS"/usr/share

    ln -n -sf lib "$ROOTFS"/usr/lib64
    ln -n -sf usr/lib "$ROOTFS"/lib
    ln -n -sf . "$ROOTFS"/usr/local
    ln -n -sf lib "$ROOTFS"/lib64
}

