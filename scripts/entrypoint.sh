#!/bin/bash

set -e

# Configure the OSB by default
if [ -z $ANSIBLE_OSB_SETUP_TAGS ]; then
	ANSIBLE_OSB_SETUP_TAGS="osb-configure"
fi

# Prepare Ansible inventory file
echo "localhost" > /tmp/inventory.ini

# Run Ansible to setup the container
ANSIBLE_ROLES_PATH=/etc/ansible/roles sudo -Es  ansible-playbook \
	--inventory-file /tmp/inventory.ini \
   	--connection local \
   	--tags "$ANSIBLE_OSB_SETUP_TAGS" \
	--verbose \
	$ANSIBLE_OSB_SETUP_PLAYBOOK
