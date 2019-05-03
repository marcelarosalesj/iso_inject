#!/bin/bash

set -x

update_debs(){
    pushd /usr/local/stxdebs
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
    popd
}

# Create Apt Local Repo for StarlingX packages
apt-get update -y
apt-get upgrade -y
apt-get install -y dpkg-dev
sed -i '1s/^/deb [trusted=yes] file:\/usr\/local\/stxdebs .\/\n/' /etc/apt/sources.list
update_debs
apt-get update -y

# Install StarlingX package
pushd /stxdebs

for i in $(ls); do
    echo "Installing... $i"
    apt install -y ./$i --allow-unauthenticated
done

popd
