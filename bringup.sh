#!/bin/bash

# Reset in case getopts has been used previously in the shell.
OPTIND=1

function usage() {
    echo "usage: $0 -o output [-a architecture] [-u username] [-h hostname]"
    echo "    -o directory     Path to output directory."
    echo "    -a architecture  Architecture of guest."
    echo "    -u username      Username to create. Default: \"user\"."
    echo "    -h hostname      Hostname of VM."
}

out=""
username="user"
hostname="linux-emulation"
architecture=""

while getopts ":o:u:a:h:" opt; do
 case $opt in
    o) out=$OPTARG
       ;;
    a) architecture=$OPTARG
       ;;
    u) username=$OPTARG
       ;;
    h) hostname=$OPTARG
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
  echo "List of valid architectures: mipsel,mips,mips64el,aarch64"
  exit 0
;;
esac

cross_prefix=""

case $architecture in
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

source_path=$(cd "$(dirname -- "$0")"; pwd)

. "$source_path/arch/$architecture/vars.sh"
. "$source_path/check_prereq.sh"

mkdir -p $out && cd $out

. "$source_path/make_disk.sh"
. "$source_path/format_disk.sh"
. "$source_path/open_rootfs.sh"
. "$source_path/prepare_rootfs.sh"
. "$source_path/prepare_output.sh"
. "$source_path/close_rootfs.sh"
