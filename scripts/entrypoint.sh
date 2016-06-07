#!/bin/bash

set -e

# Prepare Ansible inventory file
echo "localhost" > /tmp/inventory.ini

# Run Ansible to setup the container
ANSIBLE_ROLES_PATH=/etc/ansible/roles sudo -Es  ansible-playbook \
	--inventory-file /tmp/inventory.ini \
   	--connection local \
   	--tags "$ANSIBLE_OSB_SETUP_TAGS" \
	--verbose \
	$ANSIBLE_OSB_SETUP_PLAYBOOK
