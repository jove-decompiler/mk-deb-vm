cp -L rootfs/vmlinuz .
cp -L rootfs/initrd.img .

cat >> run.sh <<EOF
qemu-system-aarch64 -M virt \\
                    -cpu cortex-a57 \\
                    \$kvm \\
                    -kernel vmlinuz \\
                    -initrd initrd.img \\
                    -m 2048 \\
                    -drive if=none,format=raw,file=vm.raw,media=disk,id=hd0 \\
                    -device virtio-blk-device,drive=hd0 \\
                    -netdev user,id=net0,hostfwd=tcp::$ssh_port-:22 \\
                    -device virtio-net-device,netdev=net0 \\
                    -append "nokaslr nosmp root=/dev/vda1 rootwait console=ttyAMA0,115200" \\
                    "\$@" \\
                    -nographic
EOF
