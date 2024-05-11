all: help

ROOTDIR := $(realpath .)

##@
##@ Build commands
##@

.PHONY: build-wsl-rootfs-% build-applehv-rootfs-%  build-kernel-% build-initrd-% build-amd64 build-arm64 build

build-wsl-rootfs-amd64 build-wsl-rootfs-arm64: build-wsl-rootfs-%: ##@ Build wsl rootfs with specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/wsl_rootfs/$(_ARCH) all

build-applehv-rootfs-amd64 build-applehv-rootfs-arm64: build-applehv-rootfs-%: ##@ Build applehv rootfs with specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/applehv_rootfs/$(_ARCH) all

build-kernel-amd64 build-kernel-arm64: build-kernel-%: ##@ Build linux kernel with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@if [ $(_ARCH) = arm64 ]; then \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all; \
	else \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/amd64 all; \
	fi;

build-initrd-amd64 build-initrd-arm64: build-initrd-%: ##@ Build initrd with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) ROOTFS_CPIO_IMAGE_NAME=initrd all

build-amd64: ##@ Build all amd64
	$(MAKE) build-kernel-amd64
	$(MAKE) build-initrd-amd64
	$(MAKE) build-applehv-rootfs-amd64
	$(MAKE) build-wsl-rootfs-amd64

build-arm64: ##@ Build all arm64
	$(MAKE) build-kernel-arm64
	$(MAKE) build-initrd-arm64
	$(MAKE) build-applehv-rootfs-arm64
	$(MAKE) build-wsl-rootfs-arm64

build: ##@ Build all arch linux kernel and rootfs and initrd
	$(MAKE) build-amd64
	$(MAKE) build-arm64

##@
##@ Config commands
##@

.PHONY: nconfig-wsl-rootfs-% nconfig-applehv-rootfs-%  nconfig-initrd-% nconfig-kernel-%

nconfig-wsl-rootfs-amd64 nconfig-wsl-rootfs-arm64: nconfig-wsl-rootfs-%: ##@ Use nconfig configure wsl rootfs with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/wsl_rootfs/$(_ARCH) nconfig

nconfig-applehv-rootfs-amd64 nconfig-applehv-rootfs-arm64: nconfig-applehv-rootfs-%: ##@ Use nconfig configure applehv rootfs with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/applehv_rootfs/$(_ARCH) nconfig

nconfig-initrd-amd64 nconfig-initrd-arm64: nconfig-initrd-%: ##@ Use nconfig configure initrd with
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) nconfig

nconfig-kernel-amd64 nconfig-kernel-arm64: nconfig-kernel-%: ##@ Use nconfig configure linux kernel with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@if [ $(_ARCH) = arm64 ]; then \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nconfig; \
	else \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/amd64 nconfig; \
	fi;

.PHONY: defconfig-wsl-rootfs-% defconfig-applehv-rootfs-%  defconfig-initrd-% defconfig-kernel-%

defconfig-wsl-rootfs-amd64 defconfig-wsl-rootfs-arm64: defconfig-wsl-rootfs-%: ##@ Use defconfig configure wsl rootfs
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/wsl_rootfs/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external wsl_rootfs_$(_ARCH)_defconfig

defconfig-applehv-rootfs-amd64 defconfig-applehv-rootfs-arm64: defconfig-applehv-rootfs-%: ##@ Use defconfig configure applehv rootfs with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/applehv_rootfs/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external applehv_rootfs_$(_ARCH)_defconfig

defconfig-initrd-amd64 defconfig-initrd-arm64: defconfig-initrd-%: ##@ Use defconfig configure initrd with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external initrd_$(_ARCH)_defconfig

defconfig-kernel-amd64 defconfig-kernel-arm64: defconfig-kernel-%: ##@ Use defconfig configure linux kernel with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@if [ $(_ARCH) = arm64 ]; then \
		mkdir -p $(ROOTDIR)/out/kernel/$(_ARCH)/arch/arm64/configs/; \
		cp $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig $(ROOTDIR)/out/kernel/$(_ARCH)/arch/arm64/configs/; \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- kernel_$(_ARCH)_defconfig; \
	else \
		mkdir -p $(ROOTDIR)/out/kernel/$(_ARCH)/arch/x86/configs/; \
		cp $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig $(ROOTDIR)/out/kernel/$(_ARCH)/arch/x86/configs/; \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) kernel_$(_ARCH)_defconfig; \
	fi;

.PHONY: savedefconfig-wsl-rootfs-% savedefconfig-applehv-rootfs-% savedefconfig-initrd-% savedefconfig-kernel-%

savedefconfig-wsl-rootfs-amd64 savedefconfig-wsl-rootfs-arm64: savedefconfig-wsl-rootfs-%: ##@ Use savedefconfig configure wsl rootfs with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/wsl_rootfs/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external savedefconfig

savedefconfig-applehv-rootfs-amd64 savedefconfig-applehv-rootfs-arm64: savedefconfig-applehv-rootfs-%: ##@ Use savedefconfig configure applehv rootfs with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/applehv_rootfs/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external savedefconfig

savedefconfig-initrd-amd64 savedefconfig-initrd-arm64: savedefconfig-initrd-%: ##@ Use savedefconfig configure initrd with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external savedefconfig

savedefconfig-kernel-amd64 savedefconfig-kernel-arm64: savedefconfig-kernel-%: ##@ Use savedefconfig configure linux kernel with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@if [ $(_ARCH) = arm64 ]; then \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- savedefconfig; \
	else \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/amd64 savedefconfig; \
	fi;
	@mv $(ROOTDIR)/out/kernel/$(_ARCH)/defconfig $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig;

##@
##@ Custom commands
##@

.PHONY: wsl-rootfs-% applehv-rootfs-% initrd-% kernel-%

wsl-rootfs-amd64 wsl-rootfs-arm64: wsl-rootfs-%: ##@ Execute custom command in wsl wsl rootfs with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(CMD)" != "" ]; then \
		$(MAKE) -C buildroot O=$(ROOTDIR)/out/wsl_rootfs/$(_ARCH) $(CMD); \
	else \
		printf "Please specify a CMD param\n" \
		exit 1; \
	fi;

applehv-rootfs-amd64 applehv-rootfs-arm64: applehv-rootfs-%: ##@ Execute custom command in applehv rootfs with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(CMD)" != "" ]; then \
		$(MAKE) -C buildroot O=$(ROOTDIR)/out/applehv_rootfs/$(_ARCH) $(CMD); \
	else \
		printf "Please specify a CMD param\n" \
		exit 1; \
	fi;

initrd-amd64 initrd-arm64: initrd-%: ##@ Execute custom command in initrd with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(CMD)" != "" ]; then \
		$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) $(CMD); \
	else \
		printf "Please specify a CMD param\n" \
		exit 1; \
	fi;

kernel-amd64 kernel-arm64: kernel-%: ##@ Execute custom command in kernel with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(CMD)" != "" ]; then \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) $(CMD); \
	else \
		printf "Please specify a CMD param\n" \
		exit 1; \
	fi;

##@
##@ Clean build files commands
##@

.PHONY: clean-wsl-rootfs-% clean-applehv-rootfs-% clean-initrd-% clean-kernel-% clean-amd64 clean-arm64 clean

clean-wsl-rootfs-amd64 clean-wsl-rootfs-arm64: clean-wsl-rootfs-%: ##@ Clean wsl rootfs build files with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/wsl_rootfs/$(_ARCH) clean

clean-applehv-rootfs-amd64 clean-applehv-rootfs-arm64: clean-applehv-rootfs-%: ##@ Clean applehv rootfs build files with specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/applehv_rootfs/$(_ARCH) clean

clean-initrd-amd64 clean-initrd-arm64: clean-initrd-%: ##@ Clean initrd build files with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) clean

clean-kernel-amd64 clean-kernel-arm64: clean-kernel-%: ##@ Clean linux kernel build files with specified
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) clean

clean-amd64: ##@ Clean all amd64 build files
	$(MAKE) clean-kernel-amd64
	$(MAKE) clean-initrd-amd64
	$(MAKE) clean-applehv-rootfs-amd64
	$(MAKE) clean-wsl-rootfs-amd64

clean-arm64: ##@ Clean all arm64 build files
	$(MAKE) clean-kernel-arm64
	$(MAKE) clean-initrd-arm64
	$(MAKE) clean-applehv-rootfs-arm64
	$(MAKE) clean-wsl-rootfs-arm64

clean: ##@ Clean all build files
	$(MAKE) clean-amd64
	$(MAKE) clean-arm64

##@
##@ Misc commands
##@

.PHONY:print-outpath-wsl-rootfs-%  print-outpath-initrd-% print-outpath-kernel-% print-outpath-applehv-rootfs-% help

print-outpath-wsl-rootfs-amd64 print-outpath-wsl-rootfs-arm64: print-outpath-wsl-rootfs-%: ##@ Print out path of specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@echo -n $(ROOTDIR)/out/wsl_rootfs/$(_ARCH)/images/rootfs.ext4

print-outpath-initrd-amd64 print-outpath-initrd-arm64: print-outpath-initrd-%: ##@ Print out path of specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@echo -n $(ROOTDIR)/out/initrd/$(_ARCH)/images/initrd.gz

print-outpath-kernel-amd64 print-outpath-kernel-arm64: print-outpath-kernel-%: ##@ Print out path of specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@if [ $(_ARCH) = arm64 ]; then \
		echo -n $(ROOTDIR)/out/kernel/arm64/arch/arm64/boot/Image; \
	else \
		echo -n $(ROOTDIR)/out/kernel/amd64/arch/x86/boot/bzImage; \
	fi;

print-outpath-applehv-rootfs-amd64 print-outpath-applehv-rootfs-arm64: print-outpath-applehv-rootfs-%: ##@ Print out path of specified architecture
	$(eval _ARCH := $(firstword $(subst -, ,$*)))
	@echo -n $(ROOTDIR)/out/applehv_rootfs/$(_ARCH)/images/rootfs.erofs


help: ##@ (Default) Print listing of key targets with their descriptions
	@printf "\nUsage: make <command>\n"
	@grep -F -h "##@" $(MAKEFILE_LIST) | grep -F -v grep -F | sed -e 's/\\$$//' | awk 'BEGIN {FS = ":*[[:space:]]*##@[[:space:]]*"}; \
	{ \
		if($$2 == "") \
			pass; \
		else if($$0 ~ /^#/) \
			printf "\n%s\n", $$2; \
		else if($$1 == "") \
			printf "     %-20s%s\n", "", $$2; \
		else \
			printf "\n    \033[34m%-20s\033[0m %s\n", $$1, $$2; \
	}'
