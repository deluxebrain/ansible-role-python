.DEFAULT_GOAL := lint

export MOLECULE_INSTANCE_NAME := ansible-role-python
DEFAULT_MOLECULE_DISTRO := ubuntu-20.04
MOLECULE_DISTROS := ubuntu-18.04 ubuntu-20.04
VENV_NAME := .venv
INSTALL_TIMESTAMP := $(VENV_NAME)/.timestamp

# Install targets

## Remove virtual environment
clean:
	if [ -d $(VENV_NAME) ]; then \
		command -v molecule && molecule destroy; \
		rm -rf $(VENV_NAME); \
	fi

## Create virtual environment
venv: $(VENV_NAME)
$(VENV_NAME):
	python3 -m venv $(VENV_NAME)

## Install development packages into virtual environment
install: venv $(INSTALL_TIMESTAMP)
$(INSTALL_TIMESTAMP): requirements-dev.txt
	. $(VENV_NAME)/bin/activate; \
	pip3 install -r requirements-dev.txt
	@touch $@

# Development targets

## Run ansible linters
lint: sync
	. $(VENV_NAME)/bin/activate; \
	molecule lint

## Compile requirements.txt from requirements.in
compile: requirements.txt install
requirements.txt: requirements.in
	. $(VENV_NAME)/bin/activate; \
	pip-compile --generate-hashes requirements.in

## Sync virtual environment packages with requirements
sync: compile
	. $(VENV_NAME)/bin/activate; \
	pip-sync

# Molecule targets

## Converge Ansible role
run: export MOLECULE_DISTRO := $(subst -,:,$(DEFAULT_MOLECULE_DISTRO))
run: sync molecule
	@echo "Running for distro: $(MOLECULE_DISTRO)"
	. $(VENV_NAME)/bin/activate; \
	molecule converge

## Connect to molecule docker container
connect: run
	. $(VENV_NAME)/bin/activate; \
	molecule login

# Test targets

## Run tests against default distro
test: export MOLECULE_DISTRO := $(subst -,:,$(DEFAULT_MOLECULE_DISTRO))
test: clean sync
	@echo "Running for distro: $(MOLECULE_DISTRO)"
	. $(VENV_NAME)/bin/activate; \
	molecule test

## Run tests against all distros
TEST_TARGETS := $(addprefix .test-,$(MOLECULE_DISTROS))
test-all: $(TEST_TARGETS)
$(TEST_TARGETS): export MOLECULE_DISTRO = $(subst -,:,$(subst .test-,,$@))
$(TEST_TARGETS): clean sync
	@echo "Running for distro: $(MOLECULE_DISTRO)"
	. $(VENV_NAME)/bin/activate; \
	molecule test

.PHONY: clean venv install lint compile sync run connect test test-all
