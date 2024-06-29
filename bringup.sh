#!/bin/bash

# Reset in case getopts has been used previously in the shell.
OPTIND=1

function usage() {
    echo "usage: $0 -o output -a architecture [-u username] [-h hostname] [-s suite]"
    echo "    -o directory     Path to output directory."
    echo "    -a architecture  Architecture of guest."
    echo "    -u username      Username to create. Default: \"user\"."
    echo "    -h hostname      Hostname of VM."
    echo "    -s suite         release code or symbolic name (see debootstrap(8))"
    echo "    -p port          port # to access guest ssh"
    echo "    -X NEWROOT       root directory with /dev/loop* to chroot into"
}

out=""
username="user"
hostname=""
architecture=""
deb_suite="testing"

ssh_port="10022"
newroot=""

while getopts ":o:u:a:h:s:p:X:f" opt; do
 case $opt in
    o) out=$OPTARG
       ;;
    a) architecture=$OPTARG
       ;;
    u) username=$OPTARG
       ;;
    h) hostname=$OPTARG
       ;;
    s) deb_suite=$OPTARG
       ;;
    p) ssh_port=$OPTARG
       ;;
    X) newroot=$OPTARG
       ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

if [ -z "$out" ]; then
  echo "output directory must be specified." >&2
  exit 1
fi

if [ -z "$architecture" ]; then
  echo "architecture must be specified." >&2
  exit 1
fi

case $architecture in
?)
  echo "List of valid architectures: i386,x86_64,mipsel,mips,mips64el,aarch64"
  exit 0
;;
esac

cross_prefix=""

case $architecture in
i386)
  cross_prefix="i686-linux-gnu-"
;;
x86_64)
  cross_prefix="x86_64-linux-gnu-"
;;
mipsel)
  cross_prefix="mipsel-linux-gnu-"
;;
mips)
  cross_prefix="mips-linux-gnu-"
;;
mips64el)
  cross_prefix="mips64el-linux-gnuabi64-"
;;
aarch64)
  cross_prefix="aarch64-linux-gnu-"
;;
esac

if [ -z "$cross_prefix" ]; then
  echo "unknown architecture." >&2
  exit 1
fi

if [ -z "$hostname" ]; then
  hostname="deb-$architecture-vm"
fi

source_path=$(cd "$(dirname -- "$0")"; pwd)

trap 'exit' ERR

. "$source_path/check_prereq.sh"
. "$source_path/vars.sh"

mkdir -p $out && cd $out

. "$source_path/make_disk.sh"
. "$source_path/format_disk.sh"
. "$source_path/open_rootfs.sh"
. "$source_path/prepare_rootfs.sh"
. "$source_path/prepare_output.sh"
. "$source_path/close_rootfs.sh"
