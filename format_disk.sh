loopdev=$(losetup -f | tr -cd '/a-z0-9')

losetup $loopdev vm.raw

#
# from this point onward, we have to make sure we delete the loopback device we
# allocated before exiting
#
on_error_0 () {
  errorCode=$?
  losetup -d $loopdev
  exit $errorCode
}

trap on_error_0 ERR

partprobe $loopdev

mkfs.ext2 ${loopdev}p1
mkswap ${loopdev}p2
