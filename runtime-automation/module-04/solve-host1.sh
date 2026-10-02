#!/bin/bash
set -euo pipefail

# Task 1 - indentation fixed
cat > /home/rhel/ansible-lab/broken1.yml << 'EOF'
---
- name: Fixed indentation example
  hosts: webservers
  tasks:
    - name: This task is properly indented
      ansible.builtin.ping:

    - name: This task also has correct indentation
      ansible.builtin.debug:
        msg: "Correct indent"
EOF

# Task 2 - case sensitivity fixed
cat > /home/rhel/ansible-lab/broken2.yml << 'EOF'
---
- name: Case sensitivity fixed
  hosts: webservers
  vars:
    http_port: 80
  tasks:
    - name: Use the port variable
      ansible.builtin.debug:
        msg: "Port is {{ http_port }}"
EOF

# Task 3 - quotes added around the variable
cat > /home/rhel/ansible-lab/broken3.yml << 'EOF'
---
- name: Quote problems fixed
  hosts: webservers
  vars:
    package_name: httpd
  tasks:
    - name: Install package with quotes
      ansible.builtin.package:
        name: "{{ package_name }}"
        state: present
EOF

# Task 4 - missing colon added after tasks
cat > /home/rhel/ansible-lab/broken4.yml << 'EOF'
---
- name: Missing colon fixed
  hosts: webservers
  tasks:
    - name: Ping hosts
      ansible.builtin.ping:
EOF

echo "Solved module-04: fixed broken1.yml through broken4.yml"
