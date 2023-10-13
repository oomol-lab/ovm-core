# OVM

The minimal virtual machine to run podman.

## Usage

### Get Source Code

```bash
git clone --recurse-submodules git@github.com:oomol-lab/ovm-core.git
```

### Dependencies

#### Fedora

```bash
sudo dnf install curl wget git make gcc gcc-c++ ncurses-devel patch perl-core netcat flex bison gcc-aarch64-linux-gnu gcc-c++-aarch64-linux-gnu binutils-aarch64-linux-gnu kernel-cross-headers
```

#### Debian

```bash
sudo apt-te install git build-essential wget curl ca-certificate automake gdb bc libncurses5-dev
sudo apt-get build-dep linux
```

### Build

```bash
make apply-all-patch
make build # or rootfs-amd64-build / rootfs-arm64-build / kernel-amd64-build / kernel-arm64-build
```

## Project Structure

```bash
├── kernel # Linux kernel source code (submodule)
│   └── ...
├── rootfs # Buildroot source code (submodule)
│   └── ...
├── initrd
│   └── ... # Initrd source code
├── patches
│   ├── kernel # Patches for kernel
│   │   ├── .patches # Patch list
│   │   └── *.patch
│   └── rootfs # Patches for rootfs
│       ├── .patches # Patch list
│       └── *.patch
├── arch
│   ├── kernel
│   │   ├── amd64
│   │   │   └── .config # Linux kernel amd64 config
│   │   └── arm64
│   │       └── .config # Linux kernel arm64 config
│   ├── rootfs
│   │   ├── amd64
│   │   │   └── .config # Buildroot amd64 config
│   │   └── arm64
│   │       └── .config # Buildroot arm64 config
│   └── initrd # Initrd build output
│       ├── amd64
│       │   └── initrd.gz
│       └── arm64
│           └── initrd.gz
└── tools
    └── patch.py # Patch tool (./tools/patch.py -help)
```

### Version

* Linux kernel: `v6.1.50`
* Buildroot: `2023.05.2`