#!/bin/bash
set -euo pipefail

PLAYBOOK=/home/rhel/ansible-lab/site.yml

fail() {
  echo "VALIDATION FAILED: $1"
  exit 1
}

# Allows an optional trailing comment, since this module teaches commenting.
check() {
  grep -qE "$1"'[[:space:]]*(#.*)?$' "$PLAYBOOK" || fail "$2"
}

test -f "$PLAYBOOK" || fail "site.yml was not found in /home/rhel/ansible-lab/"

check '^---' "The file must start with the YAML document marker ---"
check '^- name: Configure web servers' "Missing the play name '- name: Configure web servers' at the start of the play"
check '^  hosts: webservers' "Missing 'hosts: webservers' indented 2 spaces under the play"
check '^  become: true' "Missing 'become: true' indented 2 spaces under the play"

check '^  vars:' "Missing 'vars:' indented 2 spaces under the play"
check '^    web_packages:' "Missing the 'web_packages:' list indented 4 spaces under 'vars:'"
check '^      - httpd' "'web_packages' needs a '- httpd' entry indented 6 spaces"
check '^      - mod_ssl' "'web_packages' needs a '- mod_ssl' entry indented 6 spaces"
check '^      - firewalld' "'web_packages' needs a '- firewalld' entry indented 6 spaces"
check '^    web_service: httpd' "Missing 'web_service: httpd' indented 4 spaces under 'vars:'"
check '^    http_port: 80' "Missing 'http_port: 80' indented 4 spaces under 'vars:'"

check '^  tasks:' "Missing 'tasks:' indented 2 spaces under the play"

check '^    - name: Ping all web servers' "Missing the task '- name: Ping all web servers' indented 4 spaces under 'tasks:'"
check '^      ansible\.builtin\.ping:' "The ping task needs 'ansible.builtin.ping:' indented 6 spaces"

check '^    - name: Install web server packages' "Missing the task '- name: Install web server packages' indented 4 spaces under 'tasks:'"
check '^      ansible\.builtin\.package:' "The install task needs 'ansible.builtin.package:' indented 6 spaces"
check '^        name: "\{\{ item \}\}"' "The install task needs 'name: \"{{ item }}\"' indented 8 spaces, with the quotes"
check '^        state: present' "The install task needs 'state: present' indented 8 spaces"
check '^      loop: "\{\{ web_packages \}\}"' "The install task needs 'loop: \"{{ web_packages }}\"' indented 6 spaces, with the quotes"

check '^    - name: Start and enable web service' "Missing the task '- name: Start and enable web service' indented 4 spaces under 'tasks:'"
check '^      ansible\.builtin\.service:' "The service task needs 'ansible.builtin.service:' indented 6 spaces"
check '^        name: "\{\{ web_service \}\}"' "The service task needs 'name: \"{{ web_service }}\"' indented 8 spaces, with the quotes"
check '^        state: started' "The service task needs 'state: started' indented 8 spaces"
check '^        enabled: true' "The service task needs 'enabled: true' indented 8 spaces"

grep -qE '^[[:space:]]*#' "$PLAYBOOK" || fail "This module asks you to document the playbook - add at least one comment line starting with #"

# Syntax-check only. This playbook installs packages and starts services, so it
# is deliberately never executed during validation.
cd /home/rhel/ansible-lab
ansible-playbook --syntax-check -i inventory.yml site.yml >/dev/null 2>&1 || fail "site.yml did not pass 'ansible-playbook --syntax-check'. Run 'yamllint site.yml' to find the problem."

echo "Module 03 validation passed."
