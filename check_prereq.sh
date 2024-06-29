#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

#
# losetup. if we have chroot, find it in there.
#
_losetup=""
if [ -z "$newroot" ]; then
  _losetup="$(which losetup)"
else
  newroot="${newroot}/"
  _newroot_path_to_losetup="$(chroot $newroot which losetup)"
  _losetup="chroot $newroot $_newroot_path_to_losetup"
fi

# confirm we have losetup
$_losetup --version

function checkBin() {
  local _binary="$1" _full_path

  # Checks if the binary is available.
  _full_path=$( command -v "$_binary" )
  commandStatus=$?
  if [ $commandStatus -ne 0 ]; then
    echo >&2 "$1 required."

    return 1
  else
    # Checks if the binary has "execute" permission.
    [ -x "$_full_path" ] && return 0

    echo >&2 "$1 required."

    return 1
  fi
}

checkBin make
checkBin git
checkBin debootstrap
checkBin parted
checkBin losetup
checkBin blkid
#checkBin ${cross_prefix}gcc
