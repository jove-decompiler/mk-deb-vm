cp -L rootfs/vmlinuz .
cp -L rootfs/initrd.img .

cat >> run.sh <<EOF
qemu-system-x86_64 -M pc \\
                   -cpu qemu64 \\
                   \$kvm \\
                   -kernel vmlinuz \\
                   -initrd initrd.img \\
                   -m 4096 \\
                   -drive if=none,format=raw,file=vm.raw,media=disk,id=hd0 \\
                   -device virtio-blk-pci,drive=hd0 \\
                   -netdev user,id=net0,hostfwd=tcp::$ssh_port-:22 \\
                   -device virtio-net-pci,netdev=net0 \\
                   -append "nokaslr norandmaps nosmp root=/dev/vda1 rootwait console=ttyS0,115200" \\
                   "\$@" \\
                   -nographic
EOF
