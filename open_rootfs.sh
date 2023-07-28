mkdir rootfs
mount ${loopdev}p1 rootfs

close_rootfs () {
  umount rootfs
  losetup -d $loopdev
  rm -r rootfs
}

#
# from this point onward, we have to make sure we unmount the root filesystem
# and delete the loopback device we allocated before exiting
#
on_error () {
  errorCode=$?
  close_rootfs
  exit $errorCode
}

trap on_error ERR
