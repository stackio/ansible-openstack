#
# Usage:
#   make deploy=deployments/all-in-one
#

SHELL = /bin/bash
TOP := $(dir $(lastword $(MAKEFILE_LIST)))
deploy = deployments/all-in-one
password_file = credentials/keystone-admin-password
password := $(shell cat ${deploy}/${password_file})


all: up fix-key provision show-gen-password

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

provision:
	ansible-playbook -i $(deploy)/hosts site.yml

destroy:
	@echo -e "Using deployment at: \t" $(deploy); \
	pushd $(deploy) 1> /dev/null; \
	vagrant destroy -f; \
	popd 1> /dev/null

rebuild: destroy all

show-gen-password:
	@echo -e "Generated admin password is: \t" $(password)

test-syntax:
	- echo localhost > inventory; \
	  find . -name '*.yml' -type f -not -path "./roles/*" -maxdepth 1 \
	    | xargs -n1  ansible-playbook --syntax-check --list-tasks -i inventory && \
	  find ./playbooks -name '*.yml' -type f \
	    | xargs -n1  ansible-playbook --syntax-check --list-tasks -i inventory; \ 
	  rm -fr inventory

tests: test-syntax

.PHONY: all rebuild tests
