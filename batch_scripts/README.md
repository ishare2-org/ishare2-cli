```batch
This script, designed to be used in Windows, allows you to create a new PNETLAB VM using VMware Workstation and BATCH
```

# create-pnetlab-vm.cmd

### Installation
Download this script into Windows applying this command in cmd or PowerShell:
```batch
curl -o create-pnetlab-vm.cmd https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/batch_scripts/create-pnetlab-vm.cmd

```

### Execution
Before execute it, check requirements and then execute it with:
```batch
.\create-pnetlab-vm.cmd
```
### Requirements

1. You need to have PNETLAB OVA file downloaded in your Windows PC and having specified the path to it in the "source" variable. No spaces allowed in this variable
2. You need to have VMWare Workstation installed. Variables "ovftoolLocation" and "vmrunLocation" define the location of ovftool.exe and vmrun.exe files, respectively. Code is going to check both files exist in the next directories.
With a normal installation this step becomes OPTIONAL. Paths are:

    ```batch
    ovftoolLocation="C:\Program Files (x86)\VMware\VMware Workstation\OVFTool\ovftool.exe"
    vmrunLocation="C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
    ```

3. (OPTIONAL) You can use the same destination folder provided in the "destination" variable, this is:
    ```batch
    destination=C:\my-vms\pnetlab\
    ```
    or you can change it as you desire

Examples of these variables are provided in code
