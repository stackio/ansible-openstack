#
# Usage:
#   make deploy=deployments/all-in-one
#

SHELL = /bin/bash
TOP := $(dir $(lastword $(MAKEFILE_LIST)))
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
deploy = deployments/all-in-one
password_file = credentials/keystone-admin-password
password := $(shell cat ${deploy}/${password_file})
dashboard_url = http://localhost:8888/dashboard
venv = venv
bin = $(venv)/bin
development = 1
reqfile = roles.yml
roles_path = roles
os_roles_pattern = os-*
roles_dev_path = $(ROOT_DIR)/../ansible-openstack-roles

ifdef tags
	provision_args += --tags $(tags)
endif

ifeq ($(development),1)
requirements: install-requirements-dev development
else
requirements: install-requirements
endif

all: requirements up fix-key provision show-gen-password show-dashboard-url

development:
	mkdir -p ../ansible-openstack-roles
	@echo "development mode enabled."
	@for d in `find $(roles_path) -type d -name $(os_roles_pattern) -depth 1`; do \
	  name=`basename $$d`; \
	  test -d $(roles_dev_path)/$$name || (mv $$d $(roles_dev_path)/$$name; \
	    echo "moved $$name to $(roles_dev_path)/"); \
	  test -d $$d && rm -fr $$d && \
	    echo "removed $$name (because develop repo exists outside)"; \
	  test -L $$d || (ln -s $(roles_dev_path)/$$name $$d && \
	    echo "develop link created in $(roles_path)/$$name"); \
	done

install-requirements-dev: virtualenv
	@echo "installing role dependencies for dev..."
	$(venv)/bin/python ansible-galaxy install -i -d -r $(reqfile)
	@echo "done."

install-requirements: virtualenv
	@echo "installing role dependencies..."
	# until we fix our meta dependencies, we must keep the -d development flag
	$(venv)/bin/python ansible-galaxy install -i -d -r $(reqfile)
	@echo "done."

clean-requirements:
	rm -fr roles

virtualenv: venv/bin/activate
	@echo "Installing project venv for ansible..."
	$(bin)/pip install -U pip
	$(bin)/pip install -Ur requirements.txt

venv/bin/activate:
	test -d $(venv) || virtualenv $(venv)
	touch $(venv)/bin/activate

up:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant up; \
	popd 1> /dev/null

ssh:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant ssh; \
	popd 1> /dev/null

suspend:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant suspend; \
	popd 1> /dev/null

status:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant status; \
	popd 1> /dev/null

fix-key:
	chmod 400 deployments/vagrant_private_key

box-update:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant box update; \
	popd 1> /dev/null

provision:
	$(bin)/ansible-playbook -i $(deploy)/hosts site.yml $(provision_args)

destroy:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant destroy -f; \
	popd 1> /dev/null

rebuild: destroy clean-requirements all

show-gen-password:
	@echo -e "Generated admin password is: \t" $(password)

show-dashboard-url:
	@echo -e "Openstack dashboard runs at: \t" $(dashboard_url)

test-syntax:
	@echo localhost > inventory;
	@find . -name '*.yml' -type f -not -path "./roles/*" -not -path "./roles.yml" -maxdepth 1 \
	  | xargs -n1  $(bin)/ansible-playbook --syntax-check --list-tasks -i inventory && \
	find ./playbooks -name '*.yml' -type f \
	  | xargs -n1  $(bin)/ansible-playbook --syntax-check --list-tasks -i inventory; \
	rm -fr inventory

tests: test-syntax

.PHONY: all development install-requirements install-requirements-dev clean-requirements \
	    up ssh suspend status fix-key provision destroy rebuild show-gen-password \
		show-dashboard-url test-syntax tests
