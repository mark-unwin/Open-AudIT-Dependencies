#!/bin/bash

# NOTE - Redhat 9 only

echo "Enabling CodeReadyBuilder packages."

subscription-manager repos --enable codeready-builder-for-rhel-9-x86_64-rpms

echo "Installing Fedora Repo."

dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

echo "Enabling Fedora Repo."

/usr/bin/crb enable

echo "Updating packages."

dnf -y update

echo "Installing createrepo."

yum -y install createrepo_c

echo "Creating directories."

mkdir -p /var/tmp/installroot

mkdir -p /var/tmp/packages

echo "Defining package list."

MAIN_PKGLIST="curl httpd ipmitool libnsl libsodium logrotate \
mariadb-server mysql-selinux net-snmp nmap perl-Crypt-CBC perl-Time-ParseDate php \
php-cli php-intl php-ldap php-mbstring php-mysqlnd php-process php-snmp \
php-sodium php-xml samba-client screen sshpass wget zip"

MAIN_PKGLIST=($(echo "${MAIN_PKGLIST[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

echo "Downloading packages."

dnf install -y --allowerasing --downloadonly --installroot=/var/tmp/installroot --releasever=9 --downloaddir=/var/tmp/packages "${MAIN_PKGLIST[@]}"

echo "Creating repo."

cd /var/tmp/packages

createrepo /var/tmp/packages

cd ~/

echo "Removing installroot."

sudo rm -rf /var/tmp/installroot

echo "Compressing repo."

sudo tar -czvf packages.tar.gz /var/tmp/packages

# ./makeself.sh --gzip /root/open-audit_dependencies/ /tmp/Open-AudIT_dependencies.run "Open-AudIT Dependencies" "/root/open-audit_dependencies/install_packages.sh"

echo "Done."
