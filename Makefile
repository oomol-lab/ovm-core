.PHONY: %-clean clean help

##@
##@ Clean build files commands
##@

%-clean: ##@ Clean linux kernel or rootfs build files with specified architecture
         ##@ e.g. rootfs-amd64-clean / rootfs-arm64-clean / kernel-amd64-clean / kernel-arm64-clean
	$(eval _DIR := $(firstword $(subst -, ,$*)))
	$(eval _ARCH := $(word 2, $(subst -, ,$*)))
	$(MAKE) -C arch/$(_DIR)/$(_ARCH) clean

clean: ##@ Clean all build files
	$(MAKE) kernel-amd64-clean
	$(MAKE) kernel-arm64-clean
	$(MAKE) rootfs-amd64-clean
	$(MAKE) rootfs-arm64-clean

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
