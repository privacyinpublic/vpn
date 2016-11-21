# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'json'

$script = <<SCRIPT
    apt-get update
    apt-get -qq install python python-pycurl python-apt
SCRIPT

extraVars = {};
extraVars['piausername']    = 'ENTER_YOUR_PRIVATE_INTERNET_ACCESS_PIAUSERNAME_HERE';
extraVars['piapassword']    = 'ENTER_YOUR_PRIVATE_INTERNET_ACCESS_PASSWORD_HERE';
extraVars['rsapassphrase']  = 'ENTER_A_SECURE_RSA_PASSWORD_HERE';
delugeport = 8112;

if ENV['DELUGEWEBPORT']
    delugeport = ENV['DELUGEWEBPORT'];
end

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu14.04"
    config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    config.vm.box_check_update = false
    config.vm.network :private_network,
        ip: "10.9.0.9",
        bridge: "en0: Wi-Fi (AirPort)",
        auto_config: false
    config.vm.network "forwarded_port", guest: delugeport, host: 8112
    config.vm.synced_folder "./files/downloads", "/home/deluge/complete", owner: "deluge", disabled: true
    config.vm.synced_folder "./files/src", "/home/vagrant/src", disabled: true

    config.vm.provider "virtualbox" do |vbox|
      vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

# This shouldn't be needed and should already be present in the image
#    config.vm.provision "shell", inline: $script

    config.vm.provision "ansible" do |ansible|
        ansible.verbose = "v" # use "vvv" for more debug output
        ansible.playbook = "site.yml"
        ansible.limit = 'all'
        ansible.extra_vars = extraVars
        ansible.host_key_checking = false
    end
end
