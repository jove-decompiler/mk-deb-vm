loopdev=$($_losetup --find --show ${vm_disk} | tr -cd '/a-z0-9')

#
# from this point onward, we have to make sure we delete the loopback device we
# allocated before exiting
#
on_error_0 () {
  errorCode=$?
  $_losetup -d $loopdev
  exit $errorCode
}

trap on_error_0 ERR

partprobe ${newroot}$loopdev

mkfs.ext2 ${newroot}${loopdev}p1
mkswap ${newroot}${loopdev}p2
