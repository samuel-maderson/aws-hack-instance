#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log) 2>&1

while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo "Waiting for cloud-init..."
    sleep 2
done

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    python3-pip \
    snapd

apt-get install -y hashcat ocl-icd-libopencl1

snap install john-the-ripper

apt-get install -y hashid
pip3 install --upgrade hashid

cat << 'EOF' > /usr/local/bin/hash-identifier
#!/usr/bin/env python3
import sys
try:
    from hashid import HashID
    hid = HashID()
    if len(sys.argv) > 1:
        for hash_arg in sys.argv[1:]:
            print(f"\nHash: {hash_arg}")
            results = hid.identify_hash(hash_arg)
            for result in results:
                print(f"  Type: {result.type}, Name: {result.name}")
    else:
        print("Usage: hash-identifier <hash1> <hash2> ...")
except ImportError:
    print("hashid module not found. Install with: pip3 install hashid")
EOF
chmod +x /usr/local/bin/hash-identifier

ln -sf /snap/bin/john-the-ripper /usr/local/bin/john 2>/dev/null || true

echo "=== Verification ==="
which hashcat && hashcat --version | head -1
which john && john --help | head -2
which hashid && hashid --version
which hash-identifier && echo "hash-identifier installed"

echo 'export PATH="$PATH:/snap/bin"' >> /etc/profile

echo "=== Installation Complete ==="