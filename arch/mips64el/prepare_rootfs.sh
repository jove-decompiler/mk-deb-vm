cat > rootfs/root/prepare_rootfs_mips64el.sh <<EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get install --no-install-recommends -y linux-image-5kc-malta
EOF

arch-chroot rootfs /bin/bash /root/prepare_rootfs_mips64el.sh
#rm rootfs/root/prepare_rootfs_mips64el.sh
