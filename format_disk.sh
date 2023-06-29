loopdev=$(losetup -f | tr -cd '/a-z0-9')

losetup $loopdev vm.raw
partprobe $loopdev

mkfs.ext4 ${loopdev}p1
mkswap ${loopdev}p2

losetup -d $loopdev
