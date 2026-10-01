#!/bin/bash
# Setup script for host1 (YAML Essentials lab environment)
# This script is automatically executed by ZT when host1 is provisioned

set -eu  # Exit on error and undefined variables

# Log everything to a file for debugging
exec 1> >(tee -a /var/log/setup-host1.log)
exec 2>&1

echo "=========================================="
echo "Starting setup-host1.sh at $(date)"
echo "=========================================="

LAB_USER="rhel"
LAB_HOME="/home/${LAB_USER}"
WORKSPACE="${LAB_HOME}/ansible-lab"
CODE_SERVER_VERSION="4.96.2"
CODE_SERVER_ARCH="amd64"

echo "=== Starting YAML Essentials Lab Setup on host1 ==="

# Add user to wheel group for sudo access
echo "Adding ${LAB_USER} to wheel group..."
usermod -aG wheel ${LAB_USER}

# Create clean workspace directory for lab files
echo "Creating workspace directory at ${WORKSPACE}..."
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${WORKSPACE}"

# Verify ansible and yamllint are installed
echo "Verifying tools..."
if ! command -v ansible &> /dev/null; then
    echo "Warning: ansible not found - may need to install"
fi

if ! command -v yamllint &> /dev/null; then
    echo "Warning: yamllint not found - may need to install"
fi

# Check if code-server is available (should be pre-installed in devtools-ansible image)
echo "Checking code-server..."
if ! command -v code-server >/dev/null 2>&1; then
  echo "WARNING: code-server not found, attempting installation..."

  CODE_SERVER_RPM="/var/tmp/code-server-${CODE_SERVER_VERSION}-${CODE_SERVER_ARCH}.rpm"
  CODE_SERVER_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-${CODE_SERVER_ARCH}.rpm"

  if curl --fail --location --retry 3 --output "${CODE_SERVER_RPM}" "${CODE_SERVER_URL}"; then
    rpm -Uvh "${CODE_SERVER_RPM}" || echo "RPM install failed"
    rm -f "${CODE_SERVER_RPM}"
  else
    echo "ERROR: Could not download or install code-server"
    exit 1
  fi
else
  echo "code-server found at $(which code-server)"
fi

# Configure code-server
echo "Configuring code-server..."
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${LAB_HOME}/.config/code-server"
cat > "${LAB_HOME}/.config/code-server/config.yaml" <<EOF
bind-addr: 0.0.0.0:8080
auth: none
cert: false
EOF
chown "${LAB_USER}:${LAB_USER}" "${LAB_HOME}/.config/code-server/config.yaml"

# Configure VS Code settings
echo "Configuring VS Code settings..."
VSCODE_USER_DIR="${LAB_HOME}/.local/share/code-server/User"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${VSCODE_USER_DIR}"
cat > "${VSCODE_USER_DIR}/settings.json" <<'EOF'
{
  "security.workspace.trust.enabled": false,
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false
}
EOF
chown "${LAB_USER}:${LAB_USER}" "${VSCODE_USER_DIR}/settings.json"

# Create code-server systemd service
echo "Creating code-server systemd service..."
cat > /etc/systemd/system/code-server.service <<EOF
[Unit]
Description=code-server
After=network.target

[Service]
Type=exec
ExecStart=/usr/bin/code-server ${WORKSPACE}
Restart=always
User=${LAB_USER}
WorkingDirectory=${WORKSPACE}

[Install]
WantedBy=multi-user.target
EOF

# Keep the user service alive after provisioning
echo "Enabling user linger..."
loginctl enable-linger ${LAB_USER} || true

# Start code-server
echo "Starting code-server..."
systemctl daemon-reload
systemctl enable --now code-server
systemctl restart code-server

# Wait for code-server to be ready
echo "Waiting for code-server to start..."
timeout 60 bash -c 'until curl -s http://localhost:8080 >/dev/null; do sleep 1; done' || {
  echo "ERROR: code-server did not start within 60 seconds"
  systemctl status code-server
  exit 1
}

# Update progress log
echo "Setup complete" > /tmp/progress.log
chmod 666 /tmp/progress.log

echo "=========================================="
echo "Verifying setup..."
echo "=========================================="
systemctl --no-pager --full status code-server || true
echo ""
echo "Port 8080 status:"
ss -tlnp | grep 8080 || echo "WARNING: Port 8080 not listening!"
echo ""
echo "=========================================="
echo "Setup Complete at $(date)"
echo "=========================================="
echo "- code-server: $(which code-server || echo 'NOT FOUND')"
echo "- code-server running with NO authentication (auth: none)"
echo "- code-server accessible at http://localhost:8080"
echo "- Workspace: ${WORKSPACE}"
echo "- Lab user: ${LAB_USER}"
echo ""
echo "Students will create YAML files as they progress through modules"
echo ""
echo "- Logs saved to /var/log/setup-host1.log"
echo "=========================================="
