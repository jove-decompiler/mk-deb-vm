debootstrap --include=${deb_extra_packages}nano,binutils,xfsprogs,iproute2,initramfs-tools,openssh-server,locales,xz-utils,zstd,systemd-coredump --arch=$deb_arch bookworm --extra-suites=bookworm-updates rootfs $deb_mirror || { echo >&2 "debootstrap failed." ; cat rootfs/debootstrap/debootstrap.log ; close_rootfs ; exit 1; }

root_uuid=$(blkid -s UUID -o value ${newroot}${loopdev}p1)
swap_uuid=$(blkid -s UUID -o value ${newroot}${loopdev}p2)

cat > rootfs/etc/fstab <<EOF
UUID=$root_uuid /    xfs  defaults  0 1
UUID=$swap_uuid none swap defaults  0 0
EOF

echo "$hostname" > rootfs/etc/hostname

rm -f rootfs/etc/motd

#
# get home directory of current user, or the user that ran sudo
#
home_dir="$HOME"
if [ -n "$SUDO_USER" ]; then
  home_dir=$(eval echo ~$SUDO_USER)
fi

#
# if ssh public key exists, mark it as authorized under guest
#
if [ -e ${home_dir}/.ssh/id_rsa.pub ] ; then
  mkdir -p rootfs/root/.ssh
  chmod 0755 rootfs/root/.ssh
  cp ${home_dir}/.ssh/id_rsa.pub rootfs/root/.ssh/authorized_keys
  chmod 0600 rootfs/root/.ssh/authorized_keys
fi

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
