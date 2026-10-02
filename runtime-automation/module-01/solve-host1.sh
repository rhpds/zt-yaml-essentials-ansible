#!/bin/bash
set -euo pipefail

cat > /home/rhel/ansible-lab/inventory.yml << 'EOF'
---
all:
  vars:
    ansible_connection: local
  children:
    webservers:
      hosts:
        web1.example.com:
          http_port: 80
          max_clients: 200
        web2.example.com:
          http_port: 8080
          max_clients: 150
    databases:
      hosts:
        db1.example.com:
          db_port: 5432
EOF

echo "Solved module-01: created inventory.yml"
