Ansible playbook to configure a server w/ the necessary scripts and cronjobs to manage DR and DR cutover

###running ansible playbook

ansible-playbook -i ./hosts playbook.yml -i --private-key=<path to dr-ops.pem file>


###installing ansbile on OSX

> brew install ansible