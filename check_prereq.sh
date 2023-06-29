#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

if [ ! -f "/etc/debian_version" ]; then
  echo "debian environment required" >&2
  exit 1
fi

# usage: checkBin <binary name/path>
function checkBin() {
  local _binary="$1" _full_path

  # Checks if the binary is available.
  _full_path=$( command -v "$_binary" )
  commandStatus=$?
  if [ $commandStatus -ne 0 ]; then
    return 1
  else
    # Checks if the binary has "execute" permission.
    [ -x "$_full_path" ] && return 0

    return 1
  fi
}

checkBin make        || { echo >&2 "make required." ; exit 1; }
checkBin git         || { echo >&2 "git required." ; exit 1; }
checkBin debootstrap || { echo >&2 "debootstrap required." ; exit 1; }
checkBin parted      || { echo >&2 "parted required."; exit 1; }
checkBin losetup     || { echo >&2 "losetup required."; exit 1; }
checkBin blkid       || { echo >&2 "blkid required."; exit 1; }

checkBin ${cross_prefix}gcc || { echo >&2 "$cross_prefix-gcc compiler required."; exit 1; }
