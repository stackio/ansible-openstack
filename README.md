Setup
======

Checkout all submodules:
```
git submodule update --init
```

Install the `netaddr` python module (required for ansible filters plugin):
```
pip install -r requirements.txt
```

All-in-one local installation
=============================

Make sure to have vagrant installed (v1.7+) with latest virtualbox.


Using make
----------

Default all-in-one:

```
make
```

Or more explicit:

```
make deploy=deployments/all-in-one
```

Rebuild everything:

```
make rebuild
```

Destroy your environment:

```
make destroy
```


Manual trigger
--------------

If you cannot run Make on your platform, then do the following.

First, make sure the private key has the correct permissions:

```
chmod 400 deployments/vagrant_private_key
```

Then launch vagrant for the target deployment:


```
cd deployments/all-in-one
vagrant up
```

When vagrant VM is ready, go back to the project root and run ansible:

```
ansible-playbook -i deployments/local-all-in-one/hosts site.yml
```

Destroy your environment:

```
cd deployments/all-in-one
vagrant destroy -f
```
