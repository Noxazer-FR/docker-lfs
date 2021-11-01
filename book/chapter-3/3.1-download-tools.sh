#!/bin/bash -x

pushd $LFS/sources

echo "Downloading LFS packages.."
echo "Getting wget-list.."
wget --timestamping https://www.linuxfromscratch.org/lfs/view/r11.0-80-systemd/wget-list

echo "Getting packages.."
wget --timestamping --continue --input-file=wget-list

echo "Getting md5.."
wget --timestamping https://www.linuxfromscratch.org/lfs/view/r11.0-80-systemd/md5sums

echo "Check hashes.."
md5sum -c md5sums

popd
