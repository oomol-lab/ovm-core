#!/bin/bash

set -o braceexpand

export PATH=$(pwd)/bin:/usr/sbin:/usr/bin:/sbin:/bin

DIR=$(pwd)

A=$(uname -m)
VM_HOST=$A
SKIP=no

usage() {
    printf "Usage: $(basename $0) <architecture> [ready]

    support architectures include: x86_64, aarch64

    Example: $(basename $0) x86_64

    Notice: 'ready' argument for using extenal toolchain
    and host ready system requirements

    Need provide: bash, binutils, bison, bzip2, coreutils,
    diffutils, findutils, gawk, gcc, grep, gzip, m4, make,
    patch, perl, python, sed, tar, texinfo, xz
"
    exit 0
}

show_header() {
    eecho "${GREEN}"
    eecho "======================================"
    eecho "                                      "
    eecho "       Bootstrap mini GNU/Linux       "
    eecho "                                      "
    eecho "======================================"
    eecho "${CLEAR}"
    eecho ""
    eecho "${CYAN}"
    eecho "======================================"
    eecho " ► $1"
    eecho "======================================"
    eecho "${CLEAR}"
}

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
    usage
else
    arch=$1

    case $arch in
        x86|x86_64|amd64) A=x86_64; VM_HOST=x86_64;;
        arm|armv8|arm64|aarch64) A=aarch64; VM_HOST=aarch64;;
        *) usage;;
    esac

    [ $# -eq 2 ] && [ "$2" = "ready" ] && SKIP=yes
fi


touch "${DIR}"/states/{await,box,cross}-$A

# 捕获异常信号，把上下文信息打印到日志文件里面
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

show_header "Start bootstap"

if [ "$SKIP" = "no" ]; then
    resolve_deps && printf "\n$(log_info 'Check dependent pkgs ok !')\n\n" || \
        (log_error "Install toolchain's dependencies failed !" && exit 1)

    (
        set -e

        # 批量下载源码包
        batch-download

        # 从头编译工具链
        musl-toolchain "$VM_HOST"
    )
fi

# 设置交叉工具链的环境变量
export PATH="${CROSSTOOL}/bin:$PATH"

export CFLAGS="-O2"
export CC="$TGT"-gcc

mkdir -pv "${DIR}"/output/boot
touch "${DIR}"/states/{await,box,cross}-$A

create_sysroot_dir

# 标准库编译到目标机器程序
build lib/box/musl

# 调整链接库路径，和C/C++头路径
export LDFLAGS="-L${ROOTFS}/usr/lib "
export CFLAGS="$CFLAGS -I${ROOTFS}/usr/include"
export CPPFLAGS="-O2 -I${ROOTFS}/usr/include"
export CXXFLAGS="-O2 -I${ROOTFS}/usr/include"

# 用继承的build脚本中的函数编译剩余的依赖包
# 下面的依赖包是对其他库的依赖依次增加

build lib/box/busybox
build lib/box/attr
build lib/box/acl
build lib/box/kbd
build lib/box/libmd
build lib/box/libxcrypt
build lib/box/zlib
build lib/box/lz4
build lib/box/lzo
build lib/box/xz
build lib/box/tar
build lib/box/ncurses
build lib/box/readline
# build lib/box/nano
build lib/box/zstd
build lib/box/util-linux
build lib/box/e2fsprogs
build lib/box/btrfs-progs

finally "$VM_HOST"

section "==> Finished all works !\n"

if [ -f "${DIR}"/context.log ]; then
    rm -fv "${DIR}"/context.log
fi

