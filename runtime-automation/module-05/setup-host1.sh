#!/bin/sh
echo "Starting module called module-05" >> /tmp/progress.log

# Create debug-challenge.yml with MULTIPLE error types for the final challenge
# Errors included:
# 1. Missing --- at the beginning of the file
# 2. Missing colon after "tasks"
# 3. Wrong indentation on first task (only 2 spaces instead of 4)
# 4. Missing quotes around {{ package_name }}
# 5. Case mismatch: Package_Name defined, package_name used
# 6. Wrong indentation on second task (3 spaces instead of 4)
# 7. Tabs instead of spaces on third task
# 8. Case mismatch: Service_Port defined, service_port used
# 9. Extra indentation on fourth task

cat > /home/rhel/ansible-lab/debug-challenge.yml << 'EOF'
- name: Final Debugging Challenge
  hosts: webservers
  vars:
    Package_Name: httpd
    Service_Port: 80
  tasks
  - name: Install web server
    ansible.builtin.package:
      name: {{ package_name }}
      state: present

   - name: Start the service
     ansible.builtin.service:
       name: httpd
       state: started

	- name: Show port number
	  ansible.builtin.debug:
	    msg: "Running on port {{ service_port }}"

    - name: Final message
      ansible.builtin.debug:
        msg: "Congratulations - you fixed all the errors!"
EOF

echo "Created debug-challenge.yml with multiple errors for final challenge" >> /tmp/progress.log
