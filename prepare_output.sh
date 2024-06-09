cat > run.sh <<EOF
#!/bin/bash

kvm=''
if qemu-system-$architecture -accel help | grep -q 'kvm' ; then
  kvm='-enable-kvm'
fi

EOF

. "${source_path}/arch/${architecture}/prepare_output.sh"

chmod +x run.sh
