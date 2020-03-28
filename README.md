![Intro](./docs/okd_3.11_screenshot.png)

This project shows you how to set up the **Origin Community Distribution of Kubernetest (OKD)** on AWS using Terraform. Project has been forked and modified from [Get up and running with OKD on AWS](http://www.dwmkerr.com/get-up-and-running-with-openshift-on-aws/). 

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

* Change OKD admin password

	```
	make ssh-master
	sudo htpasswd /etc/origin/master/htpasswd admin
	Password: << Secure Password >>
	```

* Ingress AWS Security Groups

	* Set `OpenShift Public Ingress` Inbound rules to specific User IP Source address (e.g. `aangelo home`) for each protocol

	* Set `OpenShift SSH Access` Inbound rules to specific User IP Source address (e.g. `aangelo home`)

# Scheduler Installation

```
NOTE: Use the following Tags to schedule servers
us-office-hours = 9 AM - 5 PM, M-F
running         = 24/7 always on
stopped         = Off all the time
```	

* Login to AWS

* Launch CloudFormation as follows:

	* Stack S3 Bucket: 
		https://s3.amazonaws.com/solutions-reference/aws-instance-scheduler/latest/instance-scheduler.template
	* Stack Name: `Scheduler`
	* Region: `us-east-2`

* Download and unzip the scheduler CLI package

	```
	curl https://s3.amazonaws.com/solutions-reference/aws-instance-scheduler/latest/scheduler-cli.zip -o ~/scheduler-cli.zip
	unzip ~/scheduler-cli.zip
	```
* Install Python

	```
	sudo python3 setup.py install
	```
* Create Schedule
	
	```
	scheduler-cli create-schedule --name us-office-hours --periods office-hours --timezone America/New_York --description "Office hours in US EST" --stack Scheduler --region us-east-2
	```
* Other Scheduler Commands

	```
	scheduler-cli describe-schedules --stack=Scheduler --region=us-east-2
	scheduler-cli describe-periods --stack=Scheduler --region=us-east-2
	scheduler-cli describe-schedule-usage --stack=Scheduler --name=us-office-hours --region=us-east-2
	```

* Tag servers usign the `Schedule` tag accordingly

	![Scheduler Tags](./docs/scheduler-tags.png)

# Configure OKD Prometheus to collect HAProxy Router Metrics

Openshift Router Metrics are not by default collected by Prometheus. In this section we will add a ServiceMonitor to the `openshift-monitoring` namespace where Prometheus runs so it can collect metrics from the cluster HAProxy router running in the `default` namespace.

* Login to OKD

* Use the existing STATS_USERNAME and STATS_PASSWORD set on router or change variables to customer values

	```
	oc set env dc/router -n default --list  | grep STATS
	oc set env dc/router STATS_USERNAME=admin STATS_PASSWORD=changeit -n default
	```

* Get routers Cluster IP (e.g. 172.30.145.4)

	```
	oc get service router -n default
	```

* Confirm metrics can be viewed using routers IP

	```
	oc get --raw /metrics --server http://admin:changeit@172.30.145.4:1936
	```

* Create secret to be used for Prometheus to pull metrics from router metrics endpoint
	```
 	oc create secret generic router-auth --from-literal=user=admin --from-literal=password=changeit -n openshift-monitoring
	```

* Create the ServiceMonitor object

	```
	oc create -f templates/router-metrics.yaml
	```