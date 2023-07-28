cat > rootfs/root/prepare_rootfs_arch.sh <<EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get install --no-install-recommends -y linux-image-686
EOF
