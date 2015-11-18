Ansible playbook to configure a server w/ the necessary scripts and cronjobs to manage DR and DR cutover

###running ansible playbook

ansible-playbook -i ./hosts playbook.yml --private-key=<path to dr-ops.pem file>


###installing ansbile on OSX

> brew install ansible


#### Using Vagrant to validate Ansible scripts

Install Virtual Box http://virtualbox.org/

Install Vagrant http://vagrantup.com/

```bash
vagrant up
vagrant provision # to repeat runs once vagrant is up and running
```