cp -L rootfs/vmlinuz .
cp -L rootfs/initrd.img .

cat > run.sh <<EOF
#!/bin/bash
qemu-system-aarch64 -M virt \\
                    -cpu cortex-a57 \\
                    -kernel vmlinuz \\
                    -initrd initrd.img \\
                    -m 2048 \\
                    -drive if=none,format=raw,file=vm.raw,media=disk,id=hd0 \\
                    -device virtio-blk-device,drive=hd0 \\
                    -netdev user,id=net0,hostfwd=tcp::10022-:22 \\
                    -device virtio-net-device,netdev=net0 \\
                    -append "nokaslr root=/dev/vda1 rootwait console=ttyAMA0,115200" \\
                    -serial pty \\
                    -nographic
EOF
