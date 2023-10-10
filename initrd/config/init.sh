#!/bin/sh

trap 'exec /sbin/init' INT EXIT

is_empty_disk=0

_boot_to_shell() {
        setsid -c /bin/sh
        umount -a 2>/dev/null
        poweroff -f
}

# use blockdev to return the disk with the biggest size
_blockdev_report() {
	# always ignore "zram" (compressed RAM / swap)
	blockdev --report "$@" | awk 'NR > 1 && $7 ~ /^\/dev\// { print $6, $7 }' \
		| sort -nr | cut -d' ' -f2 | grep -vE '^/dev/(zram[0-9]*|loop|ram[0-9]*)'
}

_find_device_to_format() {
	local devices device deviceData

	# get a list of all attached storage (excluding CDs like sr0 and partitions like sda1 and xvda3)
	# listed in order from biggest to smallest
	devices="$(_blockdev_report | grep -vE '^/dev/(sr[0-9]+|(s|v|xv)d[a-z]+[0-9]+|nvme[0-9]n[0-9]p[0-9]+)$' || :)"
	[ -n "$devices" ] || return

	# otherwise, return first unpartitioned disk
	for device in $devices; do
		deviceData="$(blkid "$device" 2>/dev/null || :)"
		[ -z "$deviceData" ] || continue
		echo "$device"
		return
	done
}

_find_cdrom() {
	local device

	device="$(_blockdev_report | grep -E '/dev/sr[0-9]+')"
	[ -n "$device" ] || return

	if blkid -o device "$device" >/dev/null; then
		echo >&2 "Found CD-ROM: $device"
		echo "$device"
    else
        echo ""
	fi

	return
}

_find_device() {
	local device

	# check for an existing data partition (with the right label)
	device="$(blkid -o device -l -t TYPE=btrfs || :)"
	if [ -n "$device" ]; then
		echo "$device"
		return
	fi

	# not found any ext4 or btrfs partion, then find a empty disk and format disk
	device="$(_find_device_to_format || :)"
	[ -n "$device" ] || return

	echo >&2 "=> Formatting ${device} (btrfs)"
	mkfs.btrfs -q "${device}" > /dev/null

	is_empty_disk=1

	echo "$device"
	return
}

_mount_device() {
	local device partName cdrom

	device="$(_find_device || :)"
	[ -n "$device" ] || return

	partName=$(basename "$device")

	echo >&2 "=> Mounting $device to /mnt"
	mount -n -t btrfs "$device" "/mnt" >&2 || return

	cdrom="$(_find_cdrom || :)"
	[ -n "$cdrom" ] && mount -n "$cdrom" /cdrom >&2

	if [ -f /cdrom/rootfs.tar.xz ]; then
		echo >&2 "=> Trying extract rootfs to dist"
		if [ $is_empty_disk -eq 1 ]; then
			tar -xzf /cdrom/rootfs.tar.gz -C /mnt
			sync
			sleep 2
			umount /cdrom
		fi
	fi

	echo "$device"
	return
}

##################################
# Begin boot device
##################################

PATH=/usr/sbin:/usr/bin:/sbin:/bin

mount -n -t proc proc /proc
mount -n -t sysfs sysfs /sys
mount -n -t devtmpfs devtmpfs /dev

set -- $(cat /proc/cmdline)

rootwait=true

for arg; do
    case "$arg" in
    root=LABEL=*)
        if [ x"$root_type" != x ]; then
            echo "Warning, multiple root= specified, using latest."
        fi
        root_type=label
        root="${arg#root=LABEL=}"
        ;;
    root=UUID=*)
        if [ x"$root_type" != x ]; then
            echo "Warning, multiple root= specified, using latest."
        fi
        root_type=uuid
        root="${arg#root=UUID=}"
        ;;
    root=*)
        if [ x"$root_type" != x ]; then
            echo "Warning, multiple root= specified, using latest."
        fi
        root_type=disk
        root="${arg#root=}"
        ;;
    rootflags=*)
        if [ x"$rootflags" != x ]; then
            echo "Warning, multiple rootflags= specified, using latest."
        fi
        rootflags=",${arg#rootflags=}"
        ;;
    rootfstype=*)
        if [ x"$rootfstype" != x ]; then
            echo "Warning, multiple rootfstype= specified, using latest."
        fi
        rootfstype="${arg#rootfstype=}"
        ;;
    rootdelay=*)
        if [ x"$rootdelay" != x ]; then
            echo "Warning, multiple rootdelay= specified, using latest."
        fi
        rootdelay="${arg#rootdelay=}"
        ;;
    rootwait)
        rootwait=true
        ;;
    norootwait)
        rootwait=false
        ;;
    ro)
        ro=ro
        ;;
    rw)
        ro=rw
        ;;
    init=*)
        init="${arg#init=}"
        ;;
    esac
done

if [ x"$rootdelay" != x ]; then
    sleep "$rootdelay"
fi

if [ x"$rootfstype" = x ]; then
    rootfstype=btrfs
fi

while true; do
    case "$root_type" in
    disk)
        if mount -n -t "${rootfstype}" -o "${ro-rw}""$rootflags" "$root" /mnt; then
            break
        else
            echo disk $root not found
            blkid
        fi
        ;;
    label)
        disk="$(findfs LABEL="$root")"
        if [ x"$disk" = x ]; then
            echo disk with label $root not found
            blkid
        else
            mount -n -t "${rootfstype}" -o "${ro-rw}""$rootflags" "$disk" /mnt && break
        fi
        ;;
    uuid)
        disk="$(findfs UUID="$root")"
        if [ x"$disk" = x ]; then
            echo disk with UUID $root not found
            blkid
        else
            mount -n -t "${rootfstype}" -o "${ro-rw}""$rootflags" "$disk" /mnt && break
        fi
        ;;
    '')
        mountDevice="$(_mount_device || :)"
        [ -n "$mountDevice" ] || exit 1
        ;;
    esac

    if df -hT | grep btrfs >/dev/null; then
	    echo >&2 "=> Reszie device $mountDevice ..."
            btrfs filesystem resize max /mnt >&2 || exit 1

	    break
    fi

    if "$rootwait"; then
        echo Trying again in 0.5 seconds
        sleep 0.5
    fi
done

if [ -f /mnt/sbin/init ] && [ -f /mnt/etc/hosts ] && [ -f /mnt/etc/hostname ] \
	&& [ -f /mnt/etc/passwd ] && [ -d /mnt/dev ] && [ -d /mnt/usr/lib ]; then
	umount -n /dev /sys /proc

	exec switch_root /mnt "${init:-/sbin/init}"
#else
#	umount /mnt
#   _boot_to_shell
fi

