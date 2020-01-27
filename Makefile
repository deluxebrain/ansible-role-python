.DEFAULT_GOAL := lint
.PHONY: venv install lint converge run connect run-all test test-all clean
VENV_NAME := .venv
VENV := $(VENV_NAME)/.timestamp
VENV_ACTIVATE :=. $(VENV_NAME)/bin/activate
SITE_PACKAGES = $(shell test -d $(VENV_NAME) && $(VENV_ACTIVATE); \
	pip3 show pip | grep ^Location | cut -d':' -f2)
DISTROS := ubuntu_18.04 \
	ubuntu_19.04
TEST_TARGETS := $(addprefix test-,$(DISTROS))
RUN_TARGETS := $(addprefix run-,$(DISTROS))
RUN := .run_timestamp

venv: $(VENV)
$(VENV):
	python3 -m venv $(VENV_NAME)
	touch $@

install: $(SITE_PACKAGES)
$(SITE_PACKAGES): $(VENV) requirements.txt
	$(VENV_ACTIVATE); \
	pip3 install -r requirements.txt; \
	touch $(SITE_PACKAGES)

lint:
	yamllint .
	ansible-lint .

converge: install
	$(VENV_ACTIVATE); \
	molecule converge

run: install $(RUN)
$(RUN):
	$(VENV_ACTIVATE); \
	molecule converge
	touch $@

connect: run
	$(VENV_ACTIVATE); \
	molecule login

run-all: install clean $(RUN_TARGETS)
$(RUN_TARGETS): export MOLECULE_DISTRO = $(subst _,:,$(subst run-,,$@))
$(RUN_TARGETS):
	$(VENV_ACTIVATE); \
	molecule converge; \
	molecule destroy

test: install clean
	$(VENV_ACTIVATE); \
	molecule test

test-all: install clean $(TEST_TARGETS)
$(TEST_TARGETS): export MOLECULE_DISTRO = $(subst _,:,$(subst test-,,$@))
$(TEST_TARGETS):
	$(VENV_ACTIVATE); \
	molecule test

freeze: venv
	$(VENV_ACTIVATE); \
	pip freeze > requirements.txt

clean: install
	$(VENV_ACTIVATE); \
	molecule destroy; \
	rm -f $(RUN)
