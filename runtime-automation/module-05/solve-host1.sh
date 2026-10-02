#!/bin/bash
set -euo pipefail

cat > /home/rhel/ansible-lab/debug-challenge.yml << 'EOF'
---
- name: Final Debugging Challenge
  hosts: webservers
  vars:
    package_name: httpd
    service_port: 80
  tasks:
    - name: Check connectivity
      ansible.builtin.ping:

    - name: Show the package name
      ansible.builtin.debug:
        msg: "{{ package_name }}"

    - name: Show port number
      ansible.builtin.debug:
        msg: "Running on {{ service_port }}"

    - name: Final message
      ansible.builtin.debug:
        msg: "Congratulations - you fixed all the errors!"
EOF

echo "Solved module-05: fixed debug-challenge.yml"
