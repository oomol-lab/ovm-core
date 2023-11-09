.PHONY: %-build clean

# In initrd, we use the make command to build other dependencies.
# At this point, it is necessary to ensure that MAKEOVERRIDES does not contain the O variable,
# otherwise the sub-make will use the incorrect value of the O variable.
# Ref: https://stackoverflow.com/a/24251579/6596777
MAKEOVERRIDES := $(filter-out O=%,$(MAKEOVERRIDES))
unexport O

err_if_empty = $(if $(strip $($(1))),$(strip $($(1))),$(error Required variable $(1) value is undefined, whitespace, or empty))

override O := $(call err_if_empty,O)

%-build:
	./bootstrap.sh $* $(O)

clean:
	rm -rf $(O)/states
	rm -rf $(O)/crosstmp
	rm -rf $(O)/work
	rm -rf $(O)/output
	rm -rf $(O)/toolchain
	rm -rf $(O)/sources
	rm -rf $(O)/context.log

	@printf "\nClean workspace finish!\n"
