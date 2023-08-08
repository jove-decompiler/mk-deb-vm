deb_arch="$architecture"
deb_mirror="http://ftp.us.debian.org/debian/"
deb_extra_packages="dbus,systemd-resolved,systemd-timesyncd,"

if [ -z "$serial_arg" ]; then
  serial_arg="pty"
fi

. "$source_path/arch/$architecture/vars.sh"
