cp -L rootfs/vmlinux .
cp -L rootfs/initrd.img .

cat > run.sh <<EOF
#!/bin/bash
qemu-system-mipsel -M malta \\
                   -cpu 4KEc \\
                   -kernel vmlinux \\
                   -initrd initrd.img \\
                   -m 2048 \\
                   -drive if=ide,format=raw,file=vm.raw,media=disk \\
                   -netdev user,id=net0,hostfwd=tcp::10022-:22 \\
                   -device e1000,netdev=net0 \\
                   -append "nokaslr nr_cpus=1 root=/dev/sda1 rootwait console=ttyS0,115200" \\
                   -serial pty \\
                   -nographic
EOF
