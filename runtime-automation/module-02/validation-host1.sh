#!/bin/bash
set -euo pipefail

PLAYBOOK=/home/rhel/ansible-lab/site.yml

fail() {
  echo "VALIDATION FAILED: $1"
  exit 1
}

check() {
  grep -qE "$1" "$PLAYBOOK" || fail "$2"
}

test -f "$PLAYBOOK" || fail "site.yml was not found in /home/rhel/ansible-lab/"

check '^---[[:space:]]*$' "The file must start with the YAML document marker ---"
check '^- name: Configure web servers[[:space:]]*$' "Missing the play name '- name: Configure web servers' at the start of the play"
check '^  hosts: webservers[[:space:]]*$' "Missing 'hosts: webservers' indented 2 spaces under the play"
check '^  tasks:[[:space:]]*$' "Missing 'tasks:' indented 2 spaces under the play"

check '^    - name: Ping all web servers[[:space:]]*$' "Missing the task '- name: Ping all web servers' indented 4 spaces under 'tasks:'"
check '^      ansible\.builtin\.ping:[[:space:]]*$' "The ping task needs 'ansible.builtin.ping:' indented 6 spaces"

check '^    - name: Show server hostname[[:space:]]*$' "Missing the task '- name: Show server hostname' indented 4 spaces under 'tasks:'"
check '^        msg: "Running on \{\{ inventory_hostname \}\}"[[:space:]]*$' "The hostname task needs 'msg: \"Running on {{ inventory_hostname }}\"' indented 8 spaces, with the quotes"

check '^    - name: Display welcome message[[:space:]]*$' "Missing the task '- name: Display welcome message' indented 4 spaces under 'tasks:'"
check '^        msg: "Welcome to the YAML Essentials lab!"[[:space:]]*$' "The welcome task needs 'msg: \"Welcome to the YAML Essentials lab!\"' indented 8 spaces, with the quotes"

if [ "$(grep -cE '^      ansible\.builtin\.debug:[[:space:]]*$' "$PLAYBOOK")" -lt 2 ]; then
  fail "Both debug tasks need 'ansible.builtin.debug:' indented 6 spaces"
fi

cd /home/rhel/ansible-lab
ansible-playbook --syntax-check -i inventory.yml site.yml >/dev/null 2>&1 || fail "site.yml did not pass 'ansible-playbook --syntax-check'. Run 'yamllint site.yml' to find the problem."

echo "Module 02 validation passed."
