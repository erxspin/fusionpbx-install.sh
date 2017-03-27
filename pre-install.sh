#!/bin/sh

# Exit codes
#	1	general error
#	2	unsupported OS
#	3	unsupported CPU/OS bits
#	4	unsupported package manager

#try to find and use package manager

#rpm/yum for RHEL, CentOS, Fedora
which yum && { export pkgmgr='yum' ; export pkgmgr_install=$pkgmgr' -y install' ; export pkgmgr_upgrade_all=$pkgmgr' -y update' ; export pkgmgr_remove=$pkgmgr' -y --nodeps remove' ; }

#rpm/dnf for RHEL 7, CentOS 7, Fedora 23
which dnf && { export pkgmgr='dnf' ; export pkgmgr_install=$pkgmgr' -y install' ; export pkgmgr_upgrade_all=$pkgmgr' -y upgrade' ; export pkgmgr_remove=$pkgmgr' -y remove' ; }

#?/pacman for Arch
which pacman && { export pkgmgr='pacman' ; export pkgmgr_install=$pkgmgr' --noconfirm -S' ; export pkgmgr_upgrade_all=$pkgmgr' --noconfirm -Syu' ; export pkgmgr_remove=$pkgmgr' --noconfirm -R' ; }

#portage/emerge for Gentoo
which emerge && { export pkgmgr='emerge' ; export pkgmgr_install=$pkgmgr' --ask=n' ; export pkgmgr_upgrade_all=$pkgmgr' --ask=n --update --deep --with-bdeps=y @world' ; export pkgmgr_remove=$pkgmgr' --ask=n --unmerge --nodeps' ; }

#?/zypper for SLES/openSUSE
which zypper && { export pkgmgr='zypper' ; export pkgmgr_install=$pkgmgr' --non-interactive install' ; export pkgmgr_upgrade_all=$pkgmgr' --non-interactive refresh && '$pkgmgr' --non-interactive update' ; export pkgmgr_remove=$pkgmgr' --non-interactive remove' ; }

#dpkg/apt for Debian, Ubuntu
which apt-get && { export pkgmgr='apt-get' ; export pkgmgr_install=$pkgmgr' -y install' ; export pkgmgr_upgrade_all=$pkgmgr' update && '$pkgmgr' -y --force-yes upgrade' ; export pkgmgr_remove=$pkgmgr' -y remove' ; }

if [ ! -z "$pkgmgr" ]; then
	#upgrade the packages
	$pkgmgr_upgrade_all

	#install git
	$pkgmgr_install git

fi

#prepare dir
if [ ! -d /usr/src ]; then
	mkdir -vp /usr/src
fi

#get the install script
which git && cd /usr/src && git clone https://github.com/fusionpbx/fusionpbx-install.sh.git
