# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_API_VERSION = "2"

if !ENV['APP_NAME']
    abort("FATAL: Environment not loaded")
    exit
end

# System install
$system_install_script = <<-SCRIPT
export DEBIAN_FRONTEND=noninteractive
if command -v ansible >/dev/null 2>&1 ; then
    apt-get remove -qq ansible
fi
apt-get update -qq
apt-get install -qq python3
apt-get install -qq python3-pip
pip3 install ansible
pip3 install jmespath
SCRIPT

Vagrant.configure(VAGRANT_API_VERSION) do |config|
    config.vm.box = "ubuntu/bionic64"
    config.vm.hostname = ENV['APP_NAME']

    # Fix `stdin: is not a tty` warning
    # https://github.com/hashicorp/vagrant/issues/1673
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Sytem install (root)
    config.vm.provision "shell",
        inline: $system_install_script,
        privileged: true

    # Run Ansible playbook
    config.vm.provision "ansible_local" do |ansible|
        ansible_verbose = true
        ansible.playbook = "provisioning/playbook.yml"
        ansible.extra_vars = {
            python_versions: [ ENV['PYTHON_VERSION'] ]
        }
    end

    # VirtualBox
    config.vm.provider "virtualbox" do |vbox, override|
        vbox.name = config.vm.hostname   # vbox ui title
        vbox.gui = false
        vbox.memory = 1024
        vbox.cpus = 1

        # Override Virtualbox time drift threshold ( 20 minutes ) to 1s
        vbox.customize [ "guestproperty", "set", :id, "--timesync-threshold", 1000 ]

        if Vagrant.has_plugin?("vagrant-vbguest")
            config.vbguest.auto_update = false
        end
    end
end

