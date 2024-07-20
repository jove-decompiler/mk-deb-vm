cp -L rootfs/vmlinux .
cp -L rootfs/initrd.img .

cat >> run.sh <<EOF
qemu-system-mips64el -M malta \\
                     -cpu 5KEf \\
                     \$kvm \\
                     -kernel vmlinux \\
                     -initrd initrd.img \\
                     -m 2048 \\
                     -drive if=ide,format=raw,file=vm.raw,media=disk \\
                     -netdev user,id=net0,hostfwd=tcp::$ssh_port-:22 \\
                     -device e1000,netdev=net0 \\
                     -append "nokaslr norandmaps nosmp root=/dev/sda1 rootwait console=ttyS0,115200" \\
                     "\$@" \\
                     -nographic
EOF
