cat > rootfs/root/prepare_rootfs_aarch64.sh <<EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get install --no-install-recommends -y linux-image-arm64
EOF

arch-chroot rootfs /bin/bash /root/prepare_rootfs_aarch64.sh
#rm rootfs/root/prepare_rootfs_mips64el.sh
