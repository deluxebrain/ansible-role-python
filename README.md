# Role Name: PYTHON

[![Build Status](https://travis-ci.org/deluxebrain/ansible-role-python.svg?branch=master)](https://travis-ci.org/deluxebrain/ansible-role-python)

Python installer for Linux utilizing `pyenv`.

Virtual environment management is native to python for python 3.3 and above.
This drives the following python usage scenarios:

- Single python version using the latest operating system python package version >= 3.3
- Mutliple python versions >= 3.3 using `pyenv` and the `venv` python module
- Multiple python versions ( any version ) using `pyenv` and the `pyenv-virtualenv` plugin

## Requirements

None.

## Role Variables

All of the listed variables are defined in `defaults/main.yml`.
Individual variables can be set or overridden by setting them in a playbook for this role.

- `pyenv_version`: ( default: latest )
  - Pyenv version to install
- `pyenvvirtualenv_version`: ( default: latest )
  - Pyenv-virtualenv version to install
- `install_direnv`: ( default: yes )
  - Install `direnv` to help manage loading of virtual environments
- `global_python_version`: ( default: "" )
  - Configure `pyenv` to use the specified version of python by default
  - Must be one of the versions specified in `python_versions`
- `python_versions`: ( default: [] )
  - List of python versions to install
- `pyenv_plugins`: ( default: [] )
  - List of plugins to install, specified as a list of:
    - `name`: plugin name
    - `repo`: plugin github repository
    - `version`: plugin version, specify "latest" for HEAD
- `pip_packages`: ( default: [] )
  - Pip packages to install for the user into the system python
- `init_shell`: ( default: yes )
  - Configure shell to load pyenv and pyenv-virtualenv

## Dependencies

None.

## Example Playbook

Example below for the following:

- Installation of specific versions of `pyenv` and `pyenv-virtualenv`
- Installation of specific version of Python3 via pyenv
- Setting of the global python ( accessible via the `python` command )
- Installation of the azure-cli pip package into the system Python

```yaml
- hosts: servers
  roles:
      - deluxebrain.python
      pyenv_version: 1.2.16
      pyenvvirtualenv_version: 1.1.5
      python_versions:
        - 3.8.1
      global_python_version: 3.8.1
      pip_packages:
        - azure-cli
```

## Development Installation

Packages are split into development and production dependencies, which are managed through the included files `requirements-dev.txt` and `requirements.txt` respectively.

Production packages are managed through the `pip-tools` suite, which installs and synchronizes the project dependencies through the included `requirements.in` file.

```sh
# Create project virtual environment
# Install development dependencies into virtual environment
make install
```

`pip-tools` is responsible for the generation of the `requirements.txt` which is a fully pinned requirements file used for both synchronizing the Python virtual environment and for the installation of packages within a production environment.

Note that this means that the `requirements.txt` file *should not be manually edited* and must be regenerated every time the `requirements.in` file is changed. This is done as follows, which also synchronizes any package changes into the virtual environment:

```sh
# Compile the requirements.in file to requirements.txt
# Install the requirements.txt pacakges into the virtual environment
make sync
```

`pip-tools` and other development requirements are installed through the `requirements-dev.txt` file, as follows:

## Role usage

The following is an overview of the usage of the components installed and managed through the role.

### Using system python alongside `venv`

`venv` is included from python 3.3+ and should be used in preference to the deprecated `pyvenv` script.

Its use with the system python is demonstrated in the following example:

```sh
# Create project directory
mkdir ~/my-project && cd $_

# Create virtual environment in the .venv directory
python3 -m venv .venv

# Activate the virtual environment
$ source .venv/bin/activate
( .venv ) $

# Deactivate the virtual environment
deactivate
```

### Using `pyenv` to manage multiple python versions >= 3.3

`pyenv` allows you to use multiple python versions on your machine whilst maintaining the integrity of the system python.

Its use for using a specific python version >= 3.3 is demonstrated in the following example:

```sh
# Install specific python version
pyenv install 3.7.0

# Create project directory
mkdir ~/my-project && cd $_

# Configure the project to use specific python version
pyenv local 3.7.0   # creates .python-version

# Create virtual environment in the .venv directory
python -m venv .venv
```

### Using pyenv and pyenv-virtualenv to manage multiple python installations of any version

`pyenv-virtualenv` is a plugin for `pyenv` that allows virtual environment creation across all python versions
inluding `conda`.

Contrast this to `venv`, which although should be used in preference only supports python >= 3.3

Its use is demonstrated in the following example:

```sh
# Install specific Python version
pyenv install 3.7.0

# Create project directory
mkdir ~/my-project && cd $_

# Configure the project to use specific Python version
pyenv local 3.7.0   # creates .python-version

# Create a virtual environment named venv
pyenv virtualenv venv

# Activate the virtual envrironment
pyenv activate venv

# Deactivate the virtual environment
pyenv deactivate
```

### Global Python

`pyenv` will use the version of python specified by the `pyenv global` command as the default python version for the `python` command.

The default system python version is used when no explicit python version is specified as part of this command.

In this case`pyenv` resolves the system python as the version that responds to the `python` command.
This causes issues on systems where python2 is not installed ( and hence the `python` command not available ),
regardless of whether python3 is installed.

Therefore `pyenv global` should only be set to use the system python when python2 is installed.

In the case where python3 is also installed, `pyenv` does not affect the `python3` command and hence
this will be available globally using the `python3` command as per usual.

As this role does not install python2, only python versions installed via `pyenv` should be set as global.

## Python Package Management

Per-project `pip` packages should be installed into a virtual environment and specified in a `requirements.txt` file.

Its use for adding new packages is demonstrated in the following example:

```sh
# Activate the virtual environment
$ source .venv/bin/activate
( .venv ) $

# Install the foo package into the virtual environment
pip install foo                   # latest
pip install 'foo==1.2.3'          # specific
pip install 'foo>=1.0.0,<1.1.0'   # range

# Recreated the requirements.txt file
pip freeze > requirements.txt
```

## Development Workflows

### Deploying `pyenv` managed projects into system python

Recreating a `pyenv` managed project to use system python.
Assumes the project is using python3.7 and hence a system python of version 3.7.

```sh
cd ~/my-project

# Create virtual environment in the .venv directory
python3.7 -m venv .venv
```

### Deploying `pip` managed dependencies into system pythong

Recreating a project with `pip` managed dependencies.
Assumes the project is using python3.7 and hence a system python of version 3.7.

```sh
# Create virtual environment in the .venv directory
python3.7 -m venv .venv

# Activate the virtual environment
$ source .venv/bin/activate
( .venv ) $

# Restore the packages ( -r: from requirements file )
pip install -r requirements.txt
```

## Other Tooling

### `direnv`

`direnv` is optionally installed to create and manage virtual environments.

#### `direnv` and `venv` with system python

The use of `direnv` with `venv` with system python is demonstrated in the following example:

```sh
# Create project directory
mkdir ~/my-project && cd $_

# Create .envrc which will be loaded by direnv to manage the project
$ cat << EOF > .envrc
export VIRTUAL_ENV=.venv      # override venv directory
layout python-venv python3.7  # use venv and (optionall) specify python version
EOF
.envrc is not allowed

# Trust the .envrc file to allow direnv to use it
$ direnv allow .
direnv: reloading
direnv: loading .envrc
```

#### `direnv` and `pyenv`

The use of `direnv` and `pyenv` is demonstrated in the following example:

```sh
# Create project directory
mkdir ~/my-project && cd $_

# Install specific Python version
pyenv install 3.7.0

# Create .envrc which will be loaded by direnv to manage the project
$ cat << EOF > .envrc
use pyenv 3.7.0
EOF
.envrc is not allowed

# Trust the .envrc file to allow direnv to use it
$ direnv allow .
direnv: reloading
direnv: loading .envrc
```

## License

MIT / BSD

## Author Information

This role was created in 2020 by [deluxebrain](https://www.deluxebrain.com/).
