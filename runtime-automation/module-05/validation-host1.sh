#!/bin/bash
set -euo pipefail

PLAYBOOK=/home/rhel/ansible-lab/debug-challenge.yml

fail() {
  echo "VALIDATION FAILED: $1"
  exit 1
}

check() {
  grep -qE "$1" "$PLAYBOOK" || fail "$2"
}

test -f "$PLAYBOOK" || fail "debug-challenge.yml was not found in /home/rhel/ansible-lab/"

# Error 1 - missing document start
check '^---[[:space:]]*$' "The file is still missing the YAML document marker --- on the first line"

reject() {
  if grep -q "$1" "$PLAYBOOK"; then
    fail "$2"
  fi
}

# Error 7 - tab characters
if grep -qF "$(printf '\t')" "$PLAYBOOK"; then
  fail "The file still contains tab characters. YAML only allows spaces - run 'cat -A debug-challenge.yml' to find them."
fi

# Errors 5 and 8 - case mismatches
reject 'Package_Name' "'Package_Name' is still in the file. Variable names are case sensitive - make the definition and the reference match."
reject 'Service_Port' "'Service_Port' is still in the file. Variable names are case sensitive - make the definition and the reference match."

check '^    package_name: httpd[[:space:]]*$' "Missing 'package_name: httpd' indented 4 spaces under 'vars:'"
check '^    service_port: 80[[:space:]]*$' "Missing 'service_port: 80' indented 4 spaces under 'vars:'"

# Error 2 - missing colon
check '^  tasks:[[:space:]]*$' "'tasks' still needs a colon after it, indented 2 spaces under the play"

# Errors 3, 6 and 9 - task indentation
check '^    - name: Check connectivity[[:space:]]*$' "The task '- name: Check connectivity' must be indented 4 spaces under 'tasks:'"
check '^    - name: Show the package name[[:space:]]*$' "The task '- name: Show the package name' must be indented 4 spaces under 'tasks:'"
check '^    - name: Show port number[[:space:]]*$' "The task '- name: Show port number' must be indented 4 spaces under 'tasks:'"
check '^    - name: Final message[[:space:]]*$' "The task '- name: Final message' must be indented 4 spaces under 'tasks:'"

# Error 4 - unquoted Jinja2 variable
check '^        msg: "\{\{ package_name \}\}"[[:space:]]*$' "The 'Show the package name' task needs its variable quoted: msg: \"{{ package_name }}\""

cd /home/rhel/ansible-lab

yamllint -d '{extends: default, rules: {line-length: disable, trailing-spaces: disable, comments: disable}}' debug-challenge.yml >/dev/null 2>&1 || fail "debug-challenge.yml still has yamllint errors. Run 'yamllint debug-challenge.yml' to see them."

ansible-playbook --syntax-check -i inventory.yml debug-challenge.yml >/dev/null 2>&1 || fail "debug-challenge.yml did not pass 'ansible-playbook --syntax-check'."

ansible-playbook -i inventory.yml debug-challenge.yml >/dev/null 2>&1 || fail "debug-challenge.yml parses but does not run successfully. Run it yourself to see the error."

echo "Module 05 validation passed."
