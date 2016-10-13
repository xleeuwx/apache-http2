#!/usr/bin/env bash

root_check() {
    if [[ $EUID -ne 0 ]];
    then
        echo "ERROR: This script must be run as root"
        exit 1;
    fi
}
version_check() {
    if [[ "$(lsb_release -r -s)" != "16.04" ]]
    then
        echo "ERROR: This script must be run on Ubuntu 16.04 or 16.04.1"
        exit 1;
    fi
    exit 1;
}
enable_src_in_sources_lists() {
    sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list
    sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list
    apt-get update
}
install_dependencies() {
    apt-get install -y  devscripts build-essential fakeroot
    apt-get install -y  apache2
    apt-get install -y  libnghttp2-dev
}
get_apache_build() {
    cd /tmp
    mkdir apache2-build
    cd apache2-build
    apt-get source apache2
    apt-get build-dep apache2
    cd apache-2.4.18
    fakeroot debian/rules binary
}
copy_http2_modules() {
    cp debian/apache2-bin/usr/lib/apache2/modules/mod_http2.so /usr/lib/apache2/modules/
    echo LoadModule userdir_module /usr/lib/apache2/modules/mod_userdir.so > /etc/apache2/mods-available/http2.load
}
reload_apache2() {
    a2enmod http2
    service apache2 restart
}
run_installer() {
    root_check
    version_check
    enable_src_in_sources_lists
    install_dependencies
    get_apache_build
    copy_http2_modules
    reload_apache2
}

run_installer
