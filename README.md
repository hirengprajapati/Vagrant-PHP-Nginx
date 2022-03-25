## Virtual Machine for development

* make sure VirtualBox is installed (https://www.virtualbox.org)
* make sure Vagrant is installed (http://www.vagrantup.com)
* open a terminal
* navigate to this repository
* execute the following commands and follow the instructions

```
vagrant up
vagrant ssh
sudo su
apt-get update
apt-get install dos2unix
cd /vagrant/vm
dos2unix provision.sh
cd /vagrant
bash vm/provision.sh
```

## Install vendors

```
vagrant ssh
cd /vagrant
composer install
```

*The provision script does this for you!*
