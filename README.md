Setup
--------

Checkout all submodules:
```
git submodule update --init
```

Install the `netaddr` python module (required for ansible filters plugin):
```
pip install -r requirements.txt
```

All-in-one installation
-----------------------

Make sure to have vagrant installed (v1.7+) with latest virtualbox.

```
cd deployments/local-all-in-one
vagrant up
```

When vagrant VM is ready, go back to the project root and run ansible:

```
ansible-playbook -i deployments/local-all-in-one/hosts site.yml
```
