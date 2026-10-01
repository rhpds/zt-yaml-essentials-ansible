#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup vm host1" > /tmp/progress.log

# Create the ansible-lab working directory
echo "Creating ansible-lab directory" >> /tmp/progress.log
mkdir -p /home/rhel/ansible-lab

# Set proper ownership
echo "Setting ownership" >> /tmp/progress.log
chown -R rhel:rhel /home/rhel/ansible-lab

# Set permissions
chmod 755 /home/rhel/ansible-lab

# Verify ansible and yamllint are installed (devtools-ansible image should have these)
echo "Verifying tools" >> /tmp/progress.log
if ! command -v ansible &> /dev/null; then
    echo "Warning: ansible not found" >> /tmp/progress.log
fi

if ! command -v yamllint &> /dev/null; then
    echo "Warning: yamllint not found" >> /tmp/progress.log
fi

chmod 666 /tmp/progress.log

echo "Setup complete" >> /tmp/progress.log
