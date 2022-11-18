QEMU image directory name: linux-kali2020-epiol
QEMU image name: virtioa.qcow2

Username (non-root): epiol
Password: 123456

A simple optimization has been carried out:

* The update source has been modified
* The problem of garbled characters has been solved

In order to have greater flexibility:

* The disk partition adopts LVM support
This is convenient for subsequent expansion and the current size of the entire kali disk is 20 GB

Tip: Remember to fix permissions after importing
