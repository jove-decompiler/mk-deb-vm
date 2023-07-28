rm -f vm.raw

truncate -s 60G vm.raw

parted --script vm.raw \
  mklabel msdos \
  mkpart primary ext4 0% 90% \
  mkpart primary linux-swap 90% 100%
