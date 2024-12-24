rm -f vm.raw

truncate -s 60G vm.raw

parted --script vm.raw \
  mklabel msdos \
  mkpart primary xfs 0% 90% \
  mkpart primary linux-swap 90% 100%

vm_disk="vm.raw"
if [ -n "$newroot" ]; then
  vm_disk="vm.${architecture}.raw"

  # create hard link
  ln vm.raw ${newroot}${vm_disk}
fi
