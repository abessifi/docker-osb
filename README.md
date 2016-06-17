# Ansible OSB Role for Docker

## Description

This is an Ansible role to configure a [Docker](http://www.docker.com) container for Oracle Service Bus 12c.

## Supported systems

- CentOS 7

## Role dependencies

- [ansible-java](https://github.com/abessifi/ansible-java)
- [ansible-weblogic](https://github.com/abessifi/ansible-weblogic)
- [ansible-osb](https://github.com/abessifi/ansible-osb)

## Requirements

### Software Requirements

- **Ansible 1.9** or higher (can be easily installed via `pip`. E.g: `sudo pip install ansible==1.9.2`)
- **[Packer](https://www.packer.io) 0.10** or higher
- **[Docker](https://www.docker.com) 1.10** or higher
- **[Vagrant](https://www.vagrantup.com) 1.7** or higher (for )
- `sshpass` package which is needed by Ansible if you are using SSH authentication by password. On Ubuntu/Debian: `$ sudo apt-get install sshpass`
- **Virtualbox**
- **[Oh-my-box](https://github.com/abessifi/oh-my-box)** tool, optional, if you want to quickly provision and package a Docker base box with **Ansible** and **Ruby** pre-installed.

### Docker image build requirements

- **Oracle JDK 8** [RPM package](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html), `jdk-8u77-linux-x64.rpm` for instance, to install Oracle JAVA 8.

- **Fusion Middleware Infrastructure 12c Plateform**, which You can download the installer JAR file `fmw_12.2.1.0.0_infrastructure.jar` from the [Oracle Software Delivery Cloud](https://edelivery.oracle.com).

- **Oracle Service Bus**, the installer JAR file `fmw_12.2.1.0.0_osb.jar` which can be obtained from the [Oracle Software Delivery Cloud](https://edelivery.oracle.com).

- **SQLPLUS client** [packages](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html). This is not required but may be useful for testing and debugging issues. For example `oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm` and `oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm` RPM files can be downloaded. See [ansible-sqlplus](https://github.com/abessifi/ansible-sqlplus) role documentation for more details.

- **CentOS 7 Docker image**. You need also to pull a basic CentOS 7 Docker image with Ansible installed. You can already pull the `abessifi/centos-7-ansible` image from Docker hub or use [Oh-my-box](https://github.com/abessifi/oh-my-box) project to quickly build you own ;)

### Memory requirements

A plain installation using this Ansible role and running a nodemanager, an AdminServer and a Managed Server in the same Container, requires at least **4GB** of physical memory.

## Role Variables

#### Build and setup OSB image parameters

- **`jdk_rpm_file`** -  The JDK package file name (default: `jdk-8u77-linux-x64.rpm`)
- **`weblogic_jar_file`** - The weblogic installer JAR name (default: `fmw_12.2.1.0.0_infrastructure.jar`)
- **`osb_jar_file`** - The OSB installer JAR name (default: `fmw_12.2.1.0.0_osb.jar`)
- **`artifacts_download_directory`** - The JARs and RPMs download directory (default: `/srv/files`)
- **`docker_osb_base_img_name`** - A basic CentOS 7 Docker image with Ansible installed (default: `abessifi/centos-7-ansible`)
- **`docker_osb_base_img_pull`** -  Tell Packer to pull or not the basic image (default: `true`)
- **`docker_ansible_tags`** - Tags passed to Packer to provision the OSB image with Ansible (default: `[install-java, wls-plain-install, osb-plain-install]`)
- **`docker_osb_img_repository`** - The generated OSB Docker image name (default: `foobar/centos-7-osb-12c`)
- **`docker_osb_img_tag`** -  The generated OSB Docker image tag (default: `latest`)
- **`packer_working_directory`** - Absolute path to the Packer working directory where the build template, the configuration file, provisioning playbook/scripts will be copied (default: `/usr/local/src/packer`)
- **`ansible_osb_setup_tags`** - Tags which are passed to the embedded `ansible-osb` role to finish configuring the OSB container with Ansible by initializing the AdminServer and the ManagedServer services (default: `[osb-start-adminserver, osb-start-managed-servers]`)

#### Database container setup and connection

- **`docker_database_address`** - The database address (default: `db.weblogic.local`)
- **`docker_database_port`** - The database connection system identifier (default: `1521`)
- **`docker_database_sid`** - The database connection system identifier (default: `xe.oracle.docker`)
- **`docker_database_user`** - The database admin user name (default: `sys`)
- **`docker_database_password`** - The database admin user password (default: `oracle`)
- **`docker_database_service_ctn_hostname`** - The Oracle database address/hostname (default: `db.weblogic.local`)
- **`docker_database_data_ctn_name`** - The database data volume container name (default: `db-data-ctn`)
- **`docker_database_service_ctn_name`** - The database service container name (default: `db-service-ctn`)
- **`docker_database_server_host_port`** - The host 'public' port to map to the container database server port (default: `1521`)
- **`docker_database_webadmin_host_port`** - The host 'public' port to map to the container database webadmin http port (default: `8080`)
- **`docker_database_dbca_memory`** - Max Oracle DBCA memory (default: `768`)
- **`docker_database_service_ctn_memory`** - Max memory allocated to the database service container (default: `1024MB`)


## Available tags

- **`build-osb-base-image`** - Use this tag if you want to build and tag an OSB image.
- **``**
- **``**

## Local facts

- None.

# Image build workflow and containers lifecycle

Put an image and a description here.

# Usage

## Installation

First of all, make sure you've downloaded the required packages from Oracle website (See `Docker image build requirements` section).

Create a local working directory on the host machine where you can put the downloaded Oracle JAR/RPM files, lets say `/srv/files/`.

## Build base image

You can use this role within a Continuous Integration process to build, tag and push the OSB image to a private registry for instance. To build and tag a Docker image, simply create the following playbook:

```yaml
- hosts: localhost
  roles:
    - role: abessifi.docker-osb
      docker_osb_img_repository: 'abessifi/centos-7-osb-12c'
      docker_osb_img_tag: '0.1'
```

and then call Ansible to play it:

	$ ansible-playbook -c local --tags='build-osb-base-image' provision.yml

#### What if you include the SQL*PLUS client tool ?

It is easy to include the SQL*PLUS database client tool to the OSB base image. A such tool can be very helpful for testing and debugging database connection issues. To do so, use the following Ansible playbook and build the image:

```yaml
- hosts: localhost
  roles:
    - role: abessifi.docker-osb
      docker_ansible_tags:
        - install-java
        - install-sqlplus
        - wls-plain-install
        - osb-plain-install
      docker_osb_img_repository: 'abessifi/centos-7-osb-12c'
      docker_osb_img_tag: '0.1'
```

## Use cases

First of all add the database container fqdn, by default `db.weblogic.local`, to the host's /etc/hosts file.

#### Run database container




Personally and for quick tests, I use the Docker image [sath89/oracle-12c](https://hub.docker.com/r/sath89/oracle-12c/) that brings up an Oracle 12c database server. All you need is to pull the image, create a local data directory and spin up an `oracle-db` container:

	$ sudo docker pull sath89/oracle-12c:latest
	$ sudo mkdir -p /var/lib/oracledb/data
    $ sudo docker run --name oracle-db -d -p 8080:8080 -p 1521:1521 -v /var/lib/oracledb/data:/u01/app/oracle -e DBCA_TOTAL_MEMORY=1024 sath89/oracle-12c

To test the database connection:

	$ sqlplus -L sys/oracle@db.weblogic.local/xe.oracle.docker as sysdba

	Connected to:
	Oracle Database 12c Standard Edition Release 12.1.0.2.0 - 64bit Production

	SQL>


### All from scratch

First, download Oracle JDK 8 rpm, Fusion Middleware Infrastructure and OSB 12c installer JARs and put them somewhere in the server to provision. Below an example:

	$ ls -1 /srv/files/
	fmw_12.2.1.0.0_infrastructure.jar
	fmw_12.2.1.0.0_osb.jar
	jdk-8u77-linux-x64.rpm

Next, clone this project and download the required Ansible roles to install and configure the Oracle JDK and the WebLogic platform:

	$ sudo ansible-galaxy install -p /etc/ansible/roles/ -r requirements.txt

To install an Oracle Service Bus Infrastructure (that uses Oracle JDK 8 as the Java Virtual Machine) you can use the following `provision.yml` playbook:

```yaml
- hosts: my-server
  roles:
    - role: abessifi.java
      sudo: yes
      java_version: 8
      java_jdk_type: 'oracle'
      oracle_jdk_rpm_package: 'jdk-8u77-linux-x64.rpm'
      rpm_download_directory: '/srv/files'
      java_set_as_default: true
      tags:
        - install-java

    - role: abessifi.weblogic
      weblogic_jar_path: '/srv/files/fmw_12.2.1.0.0_infrastructure.jar'
      weblogic_quick_installation: false
      weblogic_installation_type: 'Fusion Middleware Infrastructure'
      weblogic_domain_name: 'osb_domain'

    - role: ansible-osb
      osb_jar_path: '/srv/files/fmw_12.2.1.0.0_osb.jar'
      oracle_db_address: 'db.weblogic.local'
      oracle_db_sid: 'xe.oracle.docker'
      oracle_db_password: 'oracle'
      osb_schemas_common_password: 'oracle'
      osb_domain_name: 'osb_domain'
      osb_admin_server_listen_address: 'osb.weblogic.local'
      osb_managed_server_listen_address: 'osb.weblogic.local'
```

That's all ! It's now time to call Ansible to provision your server. Here is an example of ansible-playbook command:

	$ ansible-playbook --user=<user-name> --connection=ssh --timeout=30 --inventory-file=inventory.ini --tags='install-java,wls-plain-install,osb-plain-install' -v provision.yml

**Notes:**

- In the above playbook example, the `db.weblogic.local` refers to the host machine where the oracle database is installed and the `osb.weblogic.local` is the FQDN of the server we are provisioning.
- Make sure you have updated `/etc/hosts` file, so the FQDNs `db.weblogic.local` and `osb.weblogic.local` can be resolved correctly. Otherwise, replace the FQDNs by IP address in the playbook.
- You need to create and adapt the Ansible inventory files and variables to suit your environment (services ports, IP addresses, etc)

### Purge existing OSB schemas

If you want to purge an existing OSB schemas and start a clean installation, use the Ansible tags `osb-purge-db-schemas` and set the role parameter `osb_schemas_created` to remove the schemas from the Oracle database before recreating them during installation process:

	$ ansible-playbook --user=<user-name> --connection=ssh --timeout=30 --inventory-file=inventory.ini --tags='install-java,wls-plain-install,osb-purge-db-schemas,osb-plain-install' -v provision.yml

### Installation on top of an existing WebLogic platform

The installation is kept straightforward even with a such use case ! Just specify the **absolute path** of the Oracle Middleware installation directory using the `middleware_home_dir` parameter:

```yaml
- hosts: my-server
  roles:

    - role: ansible-osb
      osb_jar_path: '/srv/files/fmw_12.2.1.0.0_osb.jar'
      oracle_db_address: 'db.weblogic.local'
      oracle_db_sid: 'xe.oracle.docker'
      oracle_db_password: 'oracle'
      osb_schemas_common_password: 'oracle'
      middleware_home_dir: '/u01/app/oracle/product/middleware_12.2.1'
      osb_domain_name: 'osb_domain'
      osb_admin_server_listen_address: 'osb.weblogic.local'
      osb_managed_server_listen_address: 'osb.weblogic.local'
```

	$ ansible-playbook --user=<user-name> --connection=ssh --timeout=30 --inventory-file=inventory.ini --tags='osb-plain-install' -v provision.yml

Note that the only passed Ansible tag to perform the installation is `osb-plain-install`.

### Restart cluster services

In case of problem with the WebLogic instances, you can restart the chain service by restarting the Nodemanager service "the entrypoint":

	$ ansible-playbook --user=<user-name> --connection=ssh --timeout=30 --inventory-file=inventory.ini --tags='osb-restart-nodemanager' -v provision.yml

# Development and testing

## Test with Vagrant


## Run acceptance tests


## Notes

- This project is Ansible 2.0 compatible.
- Containers memory limitation didn't work correctly with Ansible 1.9.2. If you care about memory limitation, you can run this role with Ansible 2.0 and make sure that containers memory is limited as expected.
- Actually, the OSB container depends on the database container image `sath89/oracle-12c`. If you want to build and link a database container, based on another Docker image, the provisioning may fail.

## Author

This role was created by [Ahmed Bessifi](https://www.linkedin.com/in/abessifi), a DevOps enthusiast.













![alt tag](typical_ci_cd_workflow.png)
