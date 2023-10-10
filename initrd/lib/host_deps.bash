#!/bin/bash

set -e

apt_install_deps() {
	sudo apt update
	sudo apt install -y build-essential autoconf automake libgmp-dev libmpc-dev libmpfr-dev libc6-dev libncurses-dev libreadline-dev libpcre2-dev zlib1g-dev libzstd-dev gzip bzip2 xz-utils wget curl rsync texinfo libtool-bin libtool zip unzip
}

dnf_install_deps() {
	sudo dnf makecache
	sudo dnf update -y
	sudo dnf groupinstall -y "Development Tools"
	sudo dnf install -y wget curl gzip bzip2 xz gmp-devel libmpc-devel mpfr-devel ncurses-devel readline-devel zlib-devel libzstd-devel pcre2-devel rsync texinfo libtool zip unzip
}

check_os() {
	local ID
	local OS=$(uname -s | tr "[:upper:]" "[:lower:]")

	eval $(cat /etc/os-release | grep -E "^ID=") && OS=$ID

	echo "$OS"
	return
}

select_pm() {
        local pm
        local os="$(check_os)"

        case "$os" in
                debian|ubuntu) pm=apt        ;;
                fedora|rocky|centos) pm=dnf  ;;
                *)
                        echo "Unsupport linux distro"
                        echo "You can use container run a Debian Linux environment to run this bootstrap"
                        return 1
        esac

        echo "$pm"
        return
}

resolve_deps() {
	local pmkit=$(select_pm)

	eval "${pmkit}_install_deps"
}

