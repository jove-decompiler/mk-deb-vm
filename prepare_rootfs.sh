debootstrap --include=dbus,sudo,nano,iproute2,make,gcc,initramfs-tools,systemd-resolved,systemd-timesyncd,openssh-server,locales,xz-utils,zstd --arch=$deb_arch bookworm rootfs http://ftp.us.debian.org/debian/

root_uuid=$(blkid -s UUID -o value ${loopdev}p1)
swap_uuid=$(blkid -s UUID -o value ${loopdev}p2)

cat > rootfs/etc/fstab <<EOF
UUID=$root_uuid /    ext4 rw,relatime 0 1
UUID=$swap_uuid none swap defaults    0 0
EOF

cat > rootfs/etc/systemd/network/enp.network <<EOF
[Match]
Name=enp*

[Network]
DHCP=yes
EOF

cat > rootfs/etc/systemd/network/eth.network <<EOF
[Match]
Name=eth*

[Network]
DHCP=yes
EOF

sed -Ei 's,^# (en_US\.UTF-8 .*)$,\1,' rootfs/etc/locale.gen
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' rootfs/etc/ssh/sshd_config

cat > rootfs/root/prepare_rootfs.sh <<EOF
#!/bin/bash
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable systemd-timesyncd.service
systemctl enable sshd

echo 'root:root' | chpasswd

export DEBIAN_FRONTEND=noninteractive

dpkg-reconfigure locales
EOF

arch-chroot rootfs /bin/bash -l /root/prepare_rootfs.sh
#rm rootfs/root/prepare_rootfs.sh

. "${source_path}/arch/${architecture}/prepare_rootfs.sh"

arch-chroot rootfs /bin/bash -l /root/prepare_rootfs_arch.sh
#rm rootfs/root/prepare_rootfs_arch.sh

# do this last
ln -sf ../run/systemd/resolve/stub-resolv.conf rootfs/etc/resolv.conf
