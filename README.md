ansible-scaleway-metallb
========================

Quick and dirty demo making use of Ansible to trigger Terraform/Helm and apply configuration to install a Kapsule cluster with MetalLB

Pre-requisites
--------------

- GNU Make
- Ansible
- Terraform
- Helm
- Scaleway environment variables set

Usage
-----

To install:

```
make
```

To remove:

```
make clean
```

Expected output when installing
-------------------------------

```
ansible-playbook install.yml
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [localhost] ***********************************************************************************************************************************************************************************

TASK [Validate if Terraform and Helm are installed] ************************************************************************************************************************************************
changed: [localhost] => (item=None)
changed: [localhost] => (item=None)
changed: [localhost]

TASK [Exit if missing] *****************************************************************************************************************************************************************************
skipping: [localhost]

TASK [Build infrastructure] ************************************************************************************************************************************************************************
changed: [localhost]

TASK [Store PN subnet as fact] *********************************************************************************************************************************************************************
ok: [localhost]

TASK [Add MetalLB chart repo] **********************************************************************************************************************************************************************
changed: [localhost]

TASK [Install MetalLB] *****************************************************************************************************************************************************************************
changed: [localhost]

TASK [Configure MetalLB] ***************************************************************************************************************************************************************************
changed: [localhost]

TASK [Demo usage] **********************************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP *****************************************************************************************************************************************************************************************
localhost                  : ok=7    changed=6    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
