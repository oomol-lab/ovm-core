.PHONY: %-build build rootfs-%-defconfig rootfs-%-savedefconfig %-nconfig %-menuconfig %-clean clean help rootfs-% initrd-% kernel-% print-outpath-%

ROOTDIR := $(realpath .)

##@
##@ Build commands
##@

%-build: ##@ Build linux kernel or rootfs or initrd. e.g.
         ##@ rootfs-amd64-build / rootfs-arm64-build
         ##@ kernel-amd64-build / initrd-arm64-build
         ##@ initrd-amd64-build / initrd-arm64-build
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) all; \
			;; \
		initrd) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) ROOTFS_CPIO_IMAGE_NAME=initrd all; \
			;; \
		kernel) \
			if [ $(_ARCH) = arm64 ]; then \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- all; \
			else \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/amd64 all; \
			fi; \
			;; \
		*) \
			printf "Please specify a build command\n" \
			exit 1 \
			;; \
		esac \

build-amd64: ##@ Build all amd64
	$(MAKE) kernel-amd64-build
	$(MAKE) rootfs-amd64-build
	$(MAKE) initrd-amd64-build

build-arm64: ##@ Build all arm64
	$(MAKE) kernel-arm64-build
	$(MAKE) rootfs-arm64-build
	$(MAKE) initrd-arm64-build

build: ##@ Build all arch linux kernel and rootfs and initrd
	$(MAKE) build-amd64
	$(MAKE) build-amd64

##@
##@ Config commands
##@

%-defconfig: ##@ Use defconfig configure linux kernel or rootfs
             ##@ e.g. rootfs-amd64-defconfig / rootfs-arm64-defconfig / kernel-amd64-defconfig / kernel-arm64-defconfig
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external rootfs_$(_ARCH)_defconfig; \
			;; \
		initrd) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) BR2_EXTERNAL=$(ROOTDIR)/buildroot_external initrd_$(_ARCH)_defconfig; \
			;; \
		kernel) \
			if [ $(_ARCH) = arm64 ]; then \
				mkdir -p $(ROOTDIR)/out/kernel/$(_ARCH)/arch/arm64/configs/; \
				cp $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig $(ROOTDIR)/out/kernel/$(_ARCH)/arch/arm64/configs/; \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- kernel_$(_ARCH)_defconfig; \
			else \
				mkdir -p $(ROOTDIR)/out/kernel/$(_ARCH)/arch/x86/configs/; \
				cp $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig $(ROOTDIR)/out/kernel/$(_ARCH)/arch/x86/configs/; \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) kernel_$(_ARCH)_defconfig; \
			fi; \
			;; \
		*) \
			printf "Please specify a defconfig command\n" \
			exit 1 \
			;; \
		esac \


%-savedefconfig: ##@ Use savedefconfig configure linux kernel or rootfs
                 ##@ e.g. rootfs-amd64-savedefconfig / rootfs-arm64-savedefconfig / kernel-amd64-savedefconfig / kernel-arm64-savedefconfig
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) BR2_DEFCONFIG=$(ROOTDIR)/buildroot_external/configs/rootfs_$(_ARCH)_defconfig savedefconfig; \
			echo "generate $(ROOTDIR)/buildroot_external/configs/rootfs_$(_ARCH)_defconfig"; \
			;; \
		initrd) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) BR2_DEFCONFIG=$(ROOTDIR)/buildroot_external/configs/initrd_$(_ARCH)_defconfig savedefconfig; \
			echo "generate $(ROOTDIR)/buildroot_external/configs/initrd_$(_ARCH)_defconfig"; \
			;; \
		kernel) \
			if [ $(_ARCH) = arm64 ]; then \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- savedefconfig; \
			else \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) savedefconfig; \
			fi; \
			echo "generate $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig"; \
			mv $(ROOTDIR)/out/kernel/$(_ARCH)/defconfig $(ROOTDIR)/kernel_external/configs/kernel_$(_ARCH)_defconfig; \
			;; \
		*) \
			printf "Please specify a savedefconfig command\n" \
			exit 1 \
			;; \
		esac \

%-nconfig: ##@ Use nconfig configure linux kernel or rootfs 
           ##@ e.g. rootfs-amd64-nconfig / rootfs-arm64-nconfig / kernel-amd64-nconfig / kernel-arm64-nconfig
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) nconfig; \
			;; \
		initrd) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) nconfig; \
			;; \
		kernel) \
			if [ $(_ARCH) = arm64 ]; then \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nconfig; \
			else \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/amd64 nconfig; \
			fi; \
			;; \
		*) \
			printf "Please specify a nconfig command\n" \
			exit 1 \
			;; \
		esac \

%-menuconfig: ##@ Use menuconfig configure linux kernel or rootfs
              ##@ e.g. rootfs-amd64-menuconfig / rootfs-arm64-menuconfig / kernel-amd64-menuconfig / kernel-arm64-menuconfig
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) menuconfig; \
			;; \
		initrd) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) menuconfig; \
			;; \
		kernel) \
			if [ $(_ARCH) = arm64 ]; then \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig; \
			else \
				$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/amd64 menuconfig; \
			fi; \
			;; \
		*) \
			printf "Please specify a menuconfig command\n" \
			exit 1 \
			;; \
		esac \

##@
##@ Custom commands
##@

rootfs-amd64 rootfs-arm64: rootfs-%: ##@ Execute custom command in rootfs with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(ARGS)" != "" ]; then \
		$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) $(ARGS); \
	else \
		printf "Please specify a command\n" \
		exit 1; \
	fi;

initrd-amd64 initrd-arm64: initrd-%: ##@ Execute custom command in initrd with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(ARGS)" != "" ]; then \
		$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) $(ARGS); \
	else \
		printf "Please specify a command\n" \
		exit 1; \
	fi;

kernel-amd64 kernel-arm64: kernel-%: ##@ Execute custom command in kernel with specified architecture
	$(eval _ARCH := $(firstword $*))
	@if [ "$(ARGS)" != "" ]; then \
		$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) $(ARGS); \
	else \
		printf "Please specify a command\n" \
		exit 1; \
	fi;

##@
##@ Clean build files commands
##@

%-clean: ##@ Clean linux kernel or rootfs build files with specified architecture
         ##@ e.g. rootfs-amd64-clean / rootfs-arm64-clean / kernel-amd64-clean / kernel-arm64-clean
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/rootfs/$(_ARCH) clean; \
			;; \
		initrd) \
			$(MAKE) -C buildroot O=$(ROOTDIR)/out/initrd/$(_ARCH) clean; \
			;; \
		kernel) \
			$(MAKE) -C kernel O=$(ROOTDIR)/out/kernel/$(_ARCH) clean; \
			;; \
		*) \
			printf "Please specify a clean command\n" \
			exit 1 \
			;; \
		esac \

clean-amd64: ##@ Clean all amd64 build files
	$(MAKE) kernel-amd64-clean
	$(MAKE) rootfs-amd64-clean
	$(MAKE) initrd-amd64-clean

clean-arm64: ##@ Clean all arm64 build files
	$(MAKE) kernel-arm64-clean
	$(MAKE) rootfs-arm64-clean
	$(MAKE) initrd-arm64-clean

clean: ##@ Clean all build files
	$(MAKE) clean-amd64
	$(MAKE) clean-arm64

##@
##@ Misc commands
##@

print-outpath-%: ##@ Print out path of specified architecture
	$(eval _TARGET := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_TARGET) in \
		rootfs) \
			echo -n $(ROOTDIR)/out/rootfs/$(_ARCH)/images/rootfs.erofs; \
			;; \
		initrd) \
			echo -n $(ROOTDIR)/out/initrd/$(_ARCH)/images/initrd.gz; \
			;; \
		kernel) \
			if [ $(_ARCH) = arm64 ]; then \
				echo -n $(ROOTDIR)/out/kernel/arm64/arch/arm64/boot/Image; \
			else \
				echo -n $(ROOTDIR)/out/kernel/amd64/arch/x86/boot/bzImage; \
			fi; \
			;; \
		*) \
			printf "Please specify a print-outpath command\n" \
			exit 1 \
			;; \
		esac \

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
