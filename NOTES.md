Why roles.yml dependencies over git submodules
==============================================

1. Easier merge, pull requests
2. CI tests and workflows that were impossible before
3. Ansible galaxy integration
4. More control when doing development
5. More explicit and clearer for developers
6. More control for testing parallel versions, especially during migrations
   e.g pull nova icehouse and nova juno together, make a playbook that borrows things
       from icehouse and then run juno tasks
