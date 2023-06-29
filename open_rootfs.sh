loopdev=$(losetup -f | tr -cd '/a-z0-9')
losetup $loopdev vm.raw

partprobe $loopdev

mkdir rootfs
mount ${loopdev}p1 rootfs
