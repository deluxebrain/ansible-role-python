# ANSIBLE-ROLE-PYTHON

Ansible role for the installation and management of python via pyenv

## Development environment setup

Development of the ansible role is performed in a virtual machine specified by the included `Vagrantfile` and managed through Vagrant.
As configured within the `Vagrantfile`, Vagrant will use VirtualBox as the hypervisor, although this can obviously be changed.

Configuration of the development environment is centralized by the `config.env` file.
A `.envrc` file has been included as a convenience to automatically source `config.env` into the environment when entering the project directory.
This requires direnv to be installed, and the `.envrc` file to be authorized as follows:

```sh
# perform this step whilst in the root of the project directory
direnv allow
```

In summary:

- Mandatory dependencies:
  - Vagrant
  - VirtualBox ( assuming default hypervisor )
- Optional dependencies:
  - direnv

## TODO

pyenv usage
pipenv usage
