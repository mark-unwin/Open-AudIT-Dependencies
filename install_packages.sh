#!/bin/bash

# NOTE - Redhat 9 only

echo "Extracting packages."

tar -xvf packages.tar.gz 

echo "Moving packages to /var/tmp/packages."

mv var/tmp/packages /var/tmp/

echo "Adding local repo."

echo -e "[var_tmp_packages]\nname=Local Repository\nbaseurl=file:///var/tmp/packages\nenabled=1\ngpgcheck=0" | sudo tee /etc/yum.repos.d/var_tmp_packages.repo

echo "Defining package list."

packages=(curl httpd ipmitool libnsl libsodium logrotate \
mariadb-server net-snmp nmap perl-Crypt-CBC perl-Time-ParseDate php \
php-cli php-intl php-ldap php-mbstring php-mysqlnd php-process php-snmp \
php-sodium php-xml samba-client screen sshpass wget zip)

echo "Installing packages."

for package in "${packages[@]}"; do
    echo "Installing $package from the local repository"
    dnf --allowerasing --disablerepo="*" --enablerepo=var_tmp_packages install -y "$package"
done

echo "Ensuring MySQL, PHP and Apache are enabled and running"

for srv in php-fpm mariadb httpd; do
    if type systemctl >/dev/null 2>&1; then
        $(systemctl enable "$srv")
    else
        $(chkconfig "$srv")
    fi;
done

echo "Restarting MySQL, PHP and Apache."

systemctl restart php-fpm

systemctl restart httpd

systemctl restart mariadb

echo "Setting SUID on Nmap binary"

chmod u+s /usr/bin/nmap

echo "Done."
