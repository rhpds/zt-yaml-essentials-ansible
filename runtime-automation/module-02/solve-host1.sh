#!/bin/bash
set -euo pipefail

cat > /home/rhel/ansible-lab/site.yml << 'EOF'
---
- name: Configure web servers
  hosts: webservers
  tasks:
    - name: Ping all web servers
      ansible.builtin.ping:

    - name: Show server hostname
      ansible.builtin.debug:
        msg: "Running on {{ inventory_hostname }}"

    - name: Display welcome message
      ansible.builtin.debug:
        msg: "Welcome to the YAML Essentials lab!"
EOF

echo "Solved module-02: created site.yml"
