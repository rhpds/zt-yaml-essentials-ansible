#!/bin/bash
set -euo pipefail

INVENTORY=/home/rhel/ansible-lab/inventory.yml

fail() {
  echo "VALIDATION FAILED: $1"
  exit 1
}

check() {
  grep -qE "$1" "$INVENTORY" || fail "$2"
}

test -f "$INVENTORY" || fail "inventory.yml was not found in /home/rhel/ansible-lab/"


check '^---[[:space:]]*$' "The file must start with the YAML document marker ---"
check '^all:[[:space:]]*$' "Missing the top-level 'all:' group"
check '^  vars:[[:space:]]*$' "Missing 'vars:' indented 2 spaces under 'all:'"
check '^    ansible_connection: local[[:space:]]*$' "Missing 'ansible_connection: local' indented 4 spaces under 'vars:'"
check '^  children:[[:space:]]*$' "Missing 'children:' indented 2 spaces under 'all:'"

check '^    webservers:[[:space:]]*$' "Missing the 'webservers:' group indented 4 spaces under 'children:'"
check '^      hosts:[[:space:]]*$' "Missing 'hosts:' indented 6 spaces under a group"
check '^        web1\.example\.com:[[:space:]]*$' "Missing host 'web1.example.com:' indented 8 spaces under the webservers hosts"
check '^          http_port: 80[[:space:]]*$' "web1.example.com needs 'http_port: 80' indented 10 spaces"
check '^          max_clients: 200[[:space:]]*$' "web1.example.com needs 'max_clients: 200' indented 10 spaces"
check '^        web2\.example\.com:[[:space:]]*$' "Missing host 'web2.example.com:' indented 8 spaces under the webservers hosts"
check '^          http_port: 8080[[:space:]]*$' "web2.example.com needs 'http_port: 8080' indented 10 spaces"
check '^          max_clients: 150[[:space:]]*$' "web2.example.com needs 'max_clients: 150' indented 10 spaces"

check '^    databases:[[:space:]]*$' "Missing the 'databases:' group indented 4 spaces under 'children:'"
check '^        db1\.example\.com:[[:space:]]*$' "Missing host 'db1.example.com:' indented 8 spaces under the databases hosts"
check '^          db_port: 5432[[:space:]]*$' "db1.example.com needs 'db_port: 5432' indented 10 spaces"

cd /home/rhel/ansible-lab
ansible-inventory -i inventory.yml --list >/dev/null 2>&1 || fail "inventory.yml is not a valid Ansible inventory. Run 'yamllint inventory.yml' to find the problem."

echo "Module 01 validation passed."
