# Role Name: PYTHON

[![Build Status](https://travis-ci.org/deluxebrain/ansible-role-python.svg?branch=master)](https://travis-ci.org/deluxebrain/ansible-role-python)

Python installer for Linux.

The following Python usage scenarios are supported:

- Single Python version using the latest operating system Python package version >= 3.3
- Mutliple Python versions >= 3.3 using `pyenv` and `venv`
- Multiple Python versions ( any version ) using `pyenv` and `pyenv-virtualenv`

## Requirements

None.

## Role Variables

All of the listed variables are defined in `defaults/main.yml`.
Individual variables can be set or overridden by setting them in a playbook for this role.

- `pyenv_version`: ( default: latest )
  - Pyenv version to install
- `pyenv_root`: ( default: ~/.pyenv )
  - Pyenv installation directory
- `pyenvvirtualenv_version`: ( default: latest )
  - Pyenv-virtualenv version to install
- `init_shell`: ( default: yes )
  - Configure shell to load pyenv and pyenv-virtualenv
- `python_versions`: ( default: [] )
  - Optional array of Python versions to install via pyenv
- `pip_packages`: ( default: [] )
  - Pip packages to install for the user into the system Python
- `install_direnv`: ( default: yes )
  - Install `direnv` to help manage loading of virtual environments
- `link_python`: ( default: no )
  - Symlink Python2 to Python3

## Dependencies

None.

## Example Playbook

Example below for the following:

- Installation of specific versions of `pyenv` and `pyenv-virtualenv`
- Installation of specific version of Python3
- Installation of the azure cli pip package into the system Python

```yaml
- hosts: servers
  roles:
      - deluxebrain.python
      pyenv_version: 1.2.16
      pyenvvirtualenv_version: 1.1.5
      python_versions:
        - 3.8.1
      pip_packages:
        - azure-cli
```

## Usage

### `venv`

`venv` is included from Python 3.3+ and should be used in preference to the deprecated `pyvenv` script.

Its use with the system Python is demonstrated in the following example:

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

### `pyenv`

`pyenv` allows you to use multiple Python versions on the machine
whilst maintaining the consistency of system Python.

Its use for using a specific Python version >= 3.3 is demonstrated in the following example:

```sh
# Install specific Python version
pyenv install 3.7.0

# Create project directory
mkdir ~/my-project && cd $_

# Configure the project to use specific Python version
pyenv local 3.7.0   # creates .python-version

# Create virtual environment in the .venv directory
python3 -m venv .venv
```

#### `pyenv` and recreating the project using system Python

The use of `pyenv` when recreating a project to use system Python
is demonstrated in the following example:

```sh
cd ~/my-project

# Create virtual environment in the .venv directory
python3.7 -m venv .venv
```

### `pyenv-virtualenv`

`pyenv-virtualenv` is a plugin for `pyenv` that allows virtual environment creation across all Python versions
inluding `conda`.

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

### `pip`

Per-project `pip` packages should be installed into a virtual environment
and specified in a `requirements.txt` file.

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

#### `pip` and recreating the project

The use of `pip` when recreating a project is demonstrated in the following example:

```sh
# Create virtual environment in the .venv directory
python3 -m venv .venv

# Activate the virtual environment
$ source .venv/bin/activate
( .venv ) $

# Restore the packages
pip install -r requirements.txt
```

### `direnv`

`direnv` is optionally installed to create and manage virtual environments.

#### `direnv` and `venv` with system Python

The use of `direnv` with `venv` with system Python is demonstrated in the following example:

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
