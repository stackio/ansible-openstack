#
# Usage:
#   make deploy=deployments/all-in-one
#

SHELL = /bin/bash
TOP := $(dir $(lastword $(MAKEFILE_LIST)))
deploy = deployments/all-in-one

all: up fix-key provision

up:
	pushd $(deploy); \
	vagrant up; \
	popd

ssh:
	pushd $(deploy); \
	vagrant ssh; \
	popd

suspend:
	pushd $(deploy); \
	vagrant suspend; \
	popd

fix-key:
	chmod 400 deployments/vagrant_private_key

provision:
	ansible-playbook -i $(deploy)/hosts site.yml

destroy:
	pushd $(deploy); \
	vagrant destroy -f; \
	popd

rebuild: destroy all

test-syntax:
	- echo localhost > inventory; \
	  find . -name '*.yml' -type f -not -path "./roles/*" -maxdepth 1 \
	    | xargs -n1  ansible-playbook --syntax-check --list-tasks -i inventory && \
	  find ./playbooks -name '*.yml' -type f \
	    | xargs -n1  ansible-playbook --syntax-check --list-tasks -i inventory; \ 
	  rm -fr inventory

tests: test-syntax

.PHONY: all rebuild
