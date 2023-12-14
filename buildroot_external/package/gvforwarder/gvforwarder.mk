################################################################################
#
# gvforwarder
#
################################################################################

GVFORWARDER_VERSION = 0.6.2
GVFORWARDER_SITE = $(call github,containers,gvisor-tap-vsock,v$(GVFORWARDER_VERSION))

GVFORWARDER_LICENSE = Apache-2.0
GVFORWARDER_LICENSE_FILES = LICENSE

GVFORWARDER_BUILD_TARGETS = cmd/vm
GVFORWARDER_LDFLAGS = -s -w

GVFORWARDER_PATCH = \
	https://patch-diff.githubusercontent.com/raw/containers/gvisor-tap-vsock/pull/215.patch

define GVFORWARDER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/bin/vm $(TARGET_DIR)/usr/bin/gvforwarder
	$(INSTALL) -D -m 644 $(GVFORWARDER_PKGDIR)/systemd/gvforwarder.service \
		$(TARGET_DIR)/etc/systemd/system/
endef

$(eval $(golang-package))
