# elasticsearch_base-cookbook

For General ElasticSearch cluster admin see wiki => http://wiki.appthority.com/ElasticSearch-Cluster

Base chef recipe configuration + packer build script to create a EC2 base AMI for Appthority.

### Local Setup

Tutorial: http://misheska.com/blog/2013/06/16/getting-started-writing-chef-cookbooks-the-berkshelf-way/

Install Virtual Box http://virtualbox.org/

Install Vagrant http://vagrantup.com/

Install Berkshelf http://berkshelf.com/ 

  Rbenv Users NOTE: following was required in local .bash_profile after eval "$(rbenv init -)"
  ```bash
  export set PATH=$HOME/.chefdk/gem/ruby/2.1.0/bin:/opt/chefdk/bin:$PATH 
  alias vagrant=/usr/bin/vagrant
  ```

Install Vagrant Plugins

```bash
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
```

###Install Packer 

```bash
brew tap homebrew/binary
brew install packer
```

##Testing chef recipes

Verifing the chef recipe on Vagrant.


###Run chef recipe in vagrant
```bash
vagrant up
```

If you get the following error ```bash ERROR: You must specify at least one cookbook repo path``` run the following:

```bash
vagrant reload
vagrant provision
```

Destroy your vagrant VM when finished verifying the chef recipe
```bash
vagrant destroy
```

##Creating AMIs
The following script will create an nagios-server ami on the Naehas DR account, which can be used to spin up a running and configured nagios server.

./create_ami.sh <aws access key> <aws secret key>

###Mysql Users & Privledges for Nagios checks

on master
mysql>create user 'check_id_range'@'%' identified by 'Uuzehau4Aa';
mysql>GRANT SELECT ON *.* TO 'check_id_range'@'%';


## License and Authors

Author:: mmastoras@appthority.com
