.DEFAULT_GOAL := lint
.PHONY: install venv dev-install compile sync clean run connect lint test test-all

export MOLECULE_INSTANCE := ansible-role-python
MOLECULE_DISTROS := ubuntu-18.04 \
	ubuntu-19.04

VENV_NAME := .venv
VENV_TIMESTAMP := $(VENV_NAME)/.timestamp
VENV_ACTIVATE :=. $(VENV_NAME)/bin/activate
DEV_INSTALLED = $(shell $(VENV_ACTIVATE); pip3 show pip | grep ^Location | cut -d':' -f2)
TEST_TARGETS := $(addprefix test-,$(MOLECULE_DISTROS))

# Install targets

## Create virtual environment
venv: $(VENV_TIMESTAMP)
$(VENV_TIMESTAMP):
	python3 -m venv $(VENV_TIMESTAMP)
	touch $@

## Install development packages
install: venv $(DEV_INSTALLED)
$(DEV_INSTALLED): requirements-dev.txt
	$(VENV_ACTIVATE); \
	pip3 install -r requirements-dev.txt
	touch $@

# Development targets

## Compile requirements.txt from requirements.in
compile: requirements.txt install
requirements.txt: requirements.in
	$(VENV_ACTIVATE); \
	pip-compile --generate-hashes requirements.in

## Sync virtual environment packages with requirements
sync: compile
	$(VENV_ACTIVATE); \
	pip-sync

## Tear down all molecule containers
clean: install
	$(VENV_ACTIVATE); \
	molecule destroy
	rm -f $(RUN);

run: install
	$(VENV_ACTIVATE); \
	molecule converge

connect: install
	$(VENV_ACTIVATE); \
	molecule login

# Test targets

## Run ansible linters
lint: install
	$(VENV_ACTIVATE); \
	molecule lint

## Run tests against default distro
test: clean
	$(VENV_ACTIVATE); \
	molecule test

## Run tests against all distros
test-all: clean $(TEST_TARGETS)
$(TEST_TARGETS): export MOLECULE_DISTRO = $(subst -,:,$(subst test-,,$@))
$(TEST_TARGETS):
	$(VENV_ACTIVATE); \
	molecule test
