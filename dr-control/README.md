Ansible playbook to configure a server w/ the necessary scripts and cronjobs to manage DR and DR cutover

###DR Cutover

1. ssh into drcontrol instance
2. cd ~/dr_control/scripts
3. ./dr_cutover <mysql password for DRDB1 and DRDB2>

###run ansible playbook to setup dr_control instance w/ scripts necessary to execute automated DR cutover

ansible-playbook -i ./dr_hosts  --private-key=<path to dr-ops.pem file> dr_control_setup.yml

###run ansible playbook to setup drweb and drdb hosts

anisble-playbook -i ./dr_hosts --private-key=<path to drweb.pem file> drweb_setup.yml

ansible-playbook -i ./dr_hosts --private-key=<path to dr-db.pem file> drdb_setup.yml

###run ansible playbook to install AWS CLI on a host

ansible-playbook -i <hosts file> --private-key=<ec2 pem file for hosts> aws_cli.yml

###installing ansbile on OSX

> brew install ansible


#### Using Vagrant to validate Ansible scripts

Install Virtual Box http://virtualbox.org/

Install Vagrant http://vagrantup.com/

```bash
vagrant up
vagrant provision # to repeat runs once vagrant is up and running
```