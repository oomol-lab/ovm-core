.PHONY: clean

SHELL := $(shell command -v bash;)

##@
##@ Clean build files commands
##@

kernel-%-clean: ##@ Clean kernel build files with specified architecture
                ##@ e.g. kernel-amd64-clean / kernel-arm64-clean
	$(MAKE) -C ./arch/kernel/$* clean

rootfs-%-clean: ##@ Clean rootfs build files with specified architecture
                ##@ e.g. rootfs-amd64-clean / rootfs-arm64-clean
	$(MAKE) -C ./arch/rootfs/$* clean

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
