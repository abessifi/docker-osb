#!/bin/bash

set -e

# Install Ansible required roles
ansible-galaxy install \
	--roles-path /etc/ansible/roles/ \
	--role-file /tmp/requirements.txt \
	--force

# Fix docker entrypoint scipt permissions
chmod 0755 /entrypoint.sh
