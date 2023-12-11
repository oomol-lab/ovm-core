################################################################################
#
# vsock-guest-exec
#
################################################################################

VSOCK_GUEST_EXEC_VERSION = 0.0.1
VSOCK_GUEST_EXEC_SITE = $(call github,oomol-lab,vsock-guest-exec,v$(VSOCK_GUEST_EXEC_VERSION))

VSOCK_GUEST_EXEC_LICENSE = MIT
VSOCK_GUEST_EXEC_LICENSE_FILES = LICENSE

VSOCK_GUEST_EXEC_AUTORECONF = YES

$(eval $(autotools-package))
