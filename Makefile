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

fix-key:
	chmod 400 deployments/vagrant_private_key

provision:
	ansible-playbook -i $(deploy)/hosts site.yml

destroy:
	pushd $(deploy); \
	vagrant destroy -f; \
	popd

rebuild: destroy all

.PHONY: all rebuild
