mkdir rootfs
mount ${newroot}${loopdev}p1 rootfs

close_rootfs () {
  umount rootfs
  $_losetup -d $loopdev
  rm -r rootfs

  if [ -n "$newroot" ]; then
    # delete hard link
    rm ${newroot}vm.raw
  fi
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
