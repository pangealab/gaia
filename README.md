# gaia

This project shows you how to set up the **Origin Community Distribution of Kubernetest (OKD)** on AWS using Terraform. Project has been forked and modified from [Get up and running with OKD on AWS](http://www.dwmkerr.com/get-up-and-running-with-openshift-on-aws/). 

![OpenShift Sample Project](./docs/okd_3.11_screenshot.png)

# Overview

Terraform is used to create the following infrastructure:

![Network Diagram](./docs/network-diagram.png)

Once the infrastructure is set up, an inventory of the system is dynamically created, which is used to install the OKD platform on the hosts.

# Prerequisites

* AWS Console
* WSL, Python 3, AWS CLI
* Terraform v0.12.9

# Get AWS Access Keys

* Login to AWS
* Create IAM Account (e.g. `advlab`)
* Create AWS Keys (e.g. `AWS Access Key ID` & `AWS Secret Access Key`)
* Update AWS CLI Profile & Config Files w/ the AWS Keys from above

# Create AWS Bucket

* Login to AWS
* Create AWS Bucket (e.g. `gaia-terraform-backend` )

# Create SSH Key

* Create SSH Key

    ```
    ssh-keygen -t rsa -b 4096 -C "advlab@demo.com" -f $HOME/.ssh/advlab
    ```

* SSH Permissions

    ```
    chmod -R 700 ~/.ssh
    chmod 644 ~/.ssh/authorized_keys    
    ```

# Clone Project	

* Clone Project

	```
	git clone https://gitlab.com/advlab/gaia.git
	cd gaia
	```

# Install OKD

* Create Infrastructure

	```
	export AWS_PROFILE=advlab; printenv AWS_PROFILE
	make infrastructure FDQN=openshift.sytes.net
	```
	
	Example:

	```
	Apply complete! Resources: 31 added, 0 changed, 0 destroyed.
	Outputs:
	bastion-public_ip = 3.132.153.220
	master-public_ip = 18.219.252.114
	master-url = https://openshift.sytes.net:8443
	```

* Create Wildcard DNS on `noip.com` (e.g. `*.openshift.sytes.net`) using the `master-public-ip` from above

* Install OKD

	> NOTE: Wait until all servers are initialized from the _Create Infrastructure_ step above before proceeding

	```
	make openshift
	```

# Secure Installation

* Change admin password

	```
	make ssh-master
	sudo htpasswd /etc/origin/master/htpasswd admin
	Password: << Secure Password >>
	```

* Ingress AWS Security Groups

	* Set `OpenShift Public Ingress` Inbound rules to specific User IP Source address (e.g. `aangelo home`) for each protocol
