.PHONY: %-build build %-nconfig %-menuconfig patch %-all-patch %-clean clean help

ROOTDIR := $(realpath .)

##@
##@ Build commands
##@

%-build: ##@ Build linux kernel or rootfs or initrd. e.g.
         ##@ rootfs-amd64-build / rootfs-arm64-build
         ##@ kernel-amd64-build / initrd-arm64-build
         ##@ initrd-amd64-build / initrd-arm64-build
	$(eval _DIR := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

	@case $(_DIR) in \
		rootfs) \
			$(MAKE) -C rootfs O=$(ROOTDIR)/arch/rootfs/$(_ARCH) all \
			;; \
		kernel) \
			if [ $(_ARCH) == arm64 ]; then \
				$(MAKE) -C kernel O=$(ROOTDIR)/arch/kernel/arm64 ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- build; \
			else \
				$(MAKE) -C kernel O=$(ROOTDIR)/arch/kernel/amd64 build; \
			fi; \
			;; \
		initrd) \
			$(MAKE) -C initrd O=$(ROOTDIR)/arch/initrd/$(_ARCH) $(_ARCH)-build \
			;; \
		*) \
			printf "Please specify a build command\n" \
			exit 1 \
			;; \
		esac \

build: ##@ Build all arch linux kernel and rootfs
	$(MAKE) kernel-amd64-build
	$(MAKE) kernel-arm64-build
	$(MAKE) rootfs-amd64-build
	$(MAKE) rootfs-arm64-build
	$(MAKE) initrd-amd64-build
	$(MAKE) initrd-arm64-build

##@
##@ Config commands
##@

%-nconfig: ##@ Use nconfig configure linux kernel or rootfs 
           ##@ e.g. rootfs-amd64-nconfig / rootfs-arm64-nconfig / kernel-amd64-nconfig / kernel-arm64-nconfig
	$(eval _DIR := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

ifeq ($(word 2, $(subst -, ,$*)),arm64)
	$(MAKE) -C $(_DIR) O=$(ROOTDIR)/arch/$(_DIR)/$(_ARCH) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- nconfig
else
	$(MAKE) -C $(_DIR) O=$(ROOTDIR)/arch/$(_DIR)/$(_ARCH) nconfig
endif

%-menuconfig: ##@ Use menuconfig configure linux kernel or rootfs
              ##@ e.g. rootfs-amd64-menuconfig / rootfs-arm64-menuconfig / kernel-amd64-menuconfig / kernel-arm64-menuconfig
	$(eval _DIR := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))

ifeq ($(word 2, $(subst -, ,$*)),arm64)
	$(MAKE) -C $(_DIR) O=$(ROOTDIR)/arch/$(_DIR)/$(_ARCH) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
else
	$(MAKE) -C $(_DIR) O=$(ROOTDIR)/arch/$(_DIR)/$(_ARCH) menuconfig
endif

##@
##@ Patch commands
##@

patch: ##@ Patch submodules projects
       ##@ e.g. make patch apply=rootfs / make patch export=rootfs / make patch reset=kernel
ifdef apply
	@./tools/patch.py --apply $(apply)
else
    ifdef export
		@./tools/patch.py --export $(export)
    else
        ifdef reset
			@./tools/patch.py --reset $(reset)
        else
			$(error Please specify a patch command)
        endif
    endif
endif

%-all-patch: ##@ Patch all submodules projects
           ##@ e.g. make apply-all-patch / make export-all-patch / make reset-all-patch
	@./tools/patch.py --$* kernel
	@./tools/patch.py --$* rootfs

##@
##@ Clean build files commands
##@

%-clean: ##@ Clean linux kernel or rootfs build files with specified architecture
         ##@ e.g. rootfs-amd64-clean / rootfs-arm64-clean / kernel-amd64-clean / kernel-arm64-clean
	$(eval _DIR := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))
	$(MAKE) -C $(_DIR) O=$(ROOTDIR)/arch/$(_DIR)/$(_ARCH) clean

clean: ##@ Clean all build files
	$(MAKE) kernel-amd64-clean
	$(MAKE) kernel-arm64-clean
	$(MAKE) rootfs-amd64-clean
	$(MAKE) rootfs-arm64-clean
	$(MAKE) initrd-arm64-clean
	$(MAKE) initrd-arm64-clean

##@
##@ Misc commands
##@

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
