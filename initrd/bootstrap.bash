#!/bin/bash

set -o braceexpand

export PATH=$(pwd)/bin:/usr/sbin:/usr/bin:/sbin:/bin

DIR=$(pwd)

A=$(uname -m)
VM_HOST=$A
SKIP=no

try_catch() {
    local wait_pkg
    local log_path
    local arch="$A"
    local top="$DIR"

    printf "" > "$top"/context.log

    wait_pkg=$(cat "$top"/states/await-$arch)
    log_path=$(readlink -n -f "$top/work/${wait_pkg}"*/config.log)

    [ -z "${wait_pkg}" ] || log_error "Suspended location : ${wait_pkg}" >> "$top"/context.log
    [ -f "$log_path" ] && log_info "Error log path: $log_path\n" >> ${top}/context.log

    unset RED GREEN BLUE MAGENTA CYAN GRAY CLEAR A

    env | grep -Ev "^LS_*|^XDG_*|^SSH*|^DBUS*|^HIST*" | sort >> ${top}/context.log
    echo >> ${top}/context.log
}

if [ $# -lt 1 ]; then
    echo "Error: missing arguments!"
    exit 1
else
    arch=$1

    case $arch in
        amd64) A=x86_64; VM_HOST=x86_64;;
        arm64) A=aarch64; VM_HOST=aarch64;;
        *) echo "Error: Incorrect arch"; exit 1;;
    esac

    [ $# -eq 2 ] && [ "$2" = "ready" ] && SKIP=yes
fi


touch "${DIR}"/states/{await,box,cross}-$A

trap try_catch SIGINT SIGTERM SIGABRT SIGALRM SIGSTOP SIGQUIT ERR

ARCH=$VM_HOST

: ${TGT:="$VM_HOST-linux-musl"}
: ${ROOTFS:="${DIR}/output/$VM_HOST/boxroot"}
: ${STAGEFS:="${DIR}/output/$VM_HOST/tmproot"}
: ${CROSSTOOL:="${DIR}/toolchain/$VM_HOST"}

export A TGT ARCH STAGEFS ROOTFS CROSSTOOL

. "${DIR}"/lib/misc.bash
. "${DIR}"/lib/ready.bash
. "${DIR}"/lib/host_deps.bash

if [ "$SKIP" = "no" ]; then
    # resolve_deps && printf "\n$(log_info 'Check dependent pkgs ok !')\n\n" || \
    #     (log_error "Install toolchain's dependencies failed !" && exit 1)

    (
        set -e

        batch-download

        musl-toolchain "$VM_HOST"
    )
fi

# Set environment variables for cross-toolchains
export PATH="${CROSSTOOL}/bin:$PATH"

export CFLAGS="-O2"
export CC="$TGT"-gcc

mkdir -pv "${DIR}"/output/boot
touch "${DIR}"/states/{await,box,cross}-$A

create_sysroot_dir

build lib/box/musl

# Adjusting library paths and C/C++ header paths
export LDFLAGS="-L${ROOTFS}/usr/lib "
export CFLAGS="$CFLAGS -I${ROOTFS}/usr/include"
export CPPFLAGS="-O2 -I${ROOTFS}/usr/include"
export CXXFLAGS="-O2 -I${ROOTFS}/usr/include"

build lib/box/busybox
build lib/box/attr
build lib/box/acl
build lib/box/kbd
build lib/box/libxcrypt
build lib/box/zlib
build lib/box/lz4
build lib/box/lzo
build lib/box/xz
build lib/box/tar
build lib/box/ncurses
build lib/box/readline
build lib/box/zstd
build lib/box/util-linux
build lib/box/e2fsprogs
build lib/box/btrfs-progs

finally "$VM_HOST"

section "==> Finished all works !\n"

if [ -f "${DIR}"/context.log ]; then
    rm -fv "${DIR}"/context.log
fi

