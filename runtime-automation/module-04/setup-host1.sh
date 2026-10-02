#!/bin/sh
echo "Starting module called module-04" >> /tmp/progress.log

# Create broken1.yml with indentation errors
cat > /home/rhel/ansible-lab/broken1.yml << 'EOF'
---
- name: Broken indentation example
  hosts: webservers
  tasks:
  - name: This task is not properly indented
    ansible.builtin.ping:
   - name: This task has wrong indentation
     ansible.builtin.debug:
       msg: "Wrong indent"
EOF

echo "Created broken1.yml with indentation errors" >> /tmp/progress.log

# Create broken3.yml with case sensitivity error
cat > /home/rhel/ansible-lab/broken2.yml << 'EOF'
---
- name: Case sensitivity problem
  hosts: webservers
  vars:
    http_port: 80
  tasks:
    - name: Use the port variable
      ansible.builtin.debug:
        msg: "Port is {{ HTTP_PORT }}"
EOF

echo "Created broken2.yml with case sensitivity error" >> /tmp/progress.log

# Create broken4.yml with missing quotes
cat > /home/rhel/ansible-lab/broken3.yml << 'EOF'
---
- name: Quote problems
  hosts: webservers
  vars:
    package_name: httpd
  tasks:
    - name: Install package without quotes
      ansible.builtin.package:
        name: {{ package_name }}
        state: present
EOF

echo "Created broken3.yml with missing quotes" >> /tmp/progress.log

# Create broken5.yml with missing colon
cat > /home/rhel/ansible-lab/broken4.yml << 'EOF'
---
- name: Missing colon
  hosts: webservers
  tasks
    - name: Ping hosts
      ansible.builtin.ping:
EOF

echo "Created broken4.yml with missing colon" >> /tmp/progress.log
echo "All broken files created for module-04" >> /tmp/progress.log