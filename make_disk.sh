rm -f vm.raw

truncate -s 60G vm.raw

parted --script vm.raw \
  mklabel msdos \
  mkpart primary ext2 0% 90% \
  mkpart primary linux-swap 90% 100%

if [ -n "$newroot" ]; then
  # create hard link
  ln vm.raw ${newroot}vm.raw
fi
