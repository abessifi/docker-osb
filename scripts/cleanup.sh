#!/bin/bash

set -e

el_common(){

	# Clean YUM cache
	yum clean all
}

common_actions(){

	# Clear bash history
	cat /dev/null > ~/.bash_history && history -c
	# Remove tmp files
	rm -rf /tmp/* /home/oracle/logs/*
}

case "$PACKER_DISTRO_TYPE" in
        centos) el_common;;
        *) echo "[ERROR] Unknown PACKER_DISTRO_TYPE value";
           exit 1;;
esac

common_actions
