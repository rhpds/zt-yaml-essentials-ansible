#!/bin/bash
set -euo pipefail

cat > /home/rhel/ansible-lab/site.yml << 'EOF'
---
# This playbook configures Apache web servers and firewall config
# Target: webservers group from inventory

- name: Configure web servers
  hosts: webservers
  become: true  # Required for package installation and service management

  vars:
    # Package list includes Apache, SSL module, and firewall
    web_packages:
      - httpd        # Apache web server
      - mod_ssl      # SSL/TLS support
      - firewalld    # Firewall management

    web_service: httpd
    http_port: 80    # Standard HTTP port

  tasks:
    # Connectivity test
    - name: Ping all web servers
      ansible.builtin.ping:

    # Install all required packages in a single task
    - name: Install web server packages
      ansible.builtin.package:
        name: "{{ item }}"
        state: present
      loop: "{{ web_packages }}"

    # Ensure web service is running and enabled at boot
    - name: Start and enable web service
      ansible.builtin.service:
        name: "{{ web_service }}"
        state: started
        enabled: true  # Start automatically on system boot
EOF

echo "Solved module-03: created site.yml"
