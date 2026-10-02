#!/bin/sh
echo "Starting module called module-04" >> /tmp/progress.log


vim /home/rhel/ansible-lab/broken1.yml << EOF

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

echo "created broken1.yml with intentional YAML errors" >> /tmp/progress.log