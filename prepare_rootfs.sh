debootstrap --include=${deb_extra_packages}nano,iproute2,initramfs-tools,openssh-server,locales,xz-utils,zstd --arch=$deb_arch $deb_suite rootfs $deb_mirror || { echo >&2 "debootstrap failed." ; cat rootfs/debootstrap/debootstrap.log ; close_rootfs ; exit 1; }

root_uuid=$(blkid -s UUID -o value ${loopdev}p1)
swap_uuid=$(blkid -s UUID -o value ${loopdev}p2)

cat > rootfs/etc/fstab <<EOF
UUID=$root_uuid /    ext2 rw,relatime,noatime  0 1
UUID=$swap_uuid none swap defaults             0 0
EOF

echo "$hostname" > rootfs/etc/hostname

cat > rootfs/etc/hosts <<EOF
127.0.0.1       localhost

127.0.1.1       $hostname.mydomain.org $hostname

::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
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
export DEBIAN_FRONTEND=noninteractive

dpkg-reconfigure locales

rm -f /etc/resolv.conf && echo "nameserver 8.8.8.8" > /etc/resolv.conf

systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable systemd-timesyncd.service
systemctl enable sshd

echo 'root:root' | chpasswd
EOF

arch-chroot rootfs /bin/bash --login /root/prepare_rootfs.sh
rm rootfs/root/prepare_rootfs.sh

. "${source_path}/arch/${architecture}/prepare_rootfs.sh"

arch-chroot rootfs /bin/bash --login /root/prepare_rootfs_arch.sh
rm rootfs/root/prepare_rootfs_arch.sh

# do this last
ln -sf ../run/systemd/resolve/stub-resolv.conf rootfs/etc/resolv.conf
