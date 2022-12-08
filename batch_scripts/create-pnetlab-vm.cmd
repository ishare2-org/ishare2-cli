:: Script designed to create a new PNETLAB VM using VMware Workstation and BATCH

@echo off

:: Related to user preferences
set vmName=PNETLab-4.2.10
set source=D:\images\for-vmware\PNETLab-4.2.10\PNET_4.2.10.ova
set destination=C:\my-vms\pnetlab

if not %destination:~-1% == \ (set destination=%destination%\)

:: Related to VMware installation path
set ovftoolLocation="C:\Program Files (x86)\VMware\VMware Workstation\OVFTool\ovftool.exe"
set vmrunLocation="C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"

:: 0. Three checks before starting
set OVFTOOL_MISSING=FALSE
set VMRUN_MISSING=FALSE

:: 0. a) Checking for ovftool.exe exists
if not exist %ovftoolLocation% ( set OVFTOOL_MISSING=TRUE )

:: 0. b) Checking for vmrun.exe exists
if not exist %vmrunLocation% ( set VMRUN_MISSING=TRUE )

if %OVFTOOL_MISSING% == TRUE (
    if %VMRUN_MISSING% == TRUE (
        echo ovftool.exe has not been found at %ovftoolLocation%
        echo.
        echo vmrun.exe has not been found at %vmrunLocation%
        exit 1
    )
)

if %OVFTOOL_MISSING% == TRUE (
    echo ovftool.exe has not been found at %ovftoolLocation%
    exit 1
)

if %VMRUN_MISSING% == TRUE (
    echo vmrun.exe has not been found at %vmrunLocation%
    exit 1
)

:: 0. c) Checking for the VM does not already exists
if exist %destination%%vmName% (
    echo Folder %destination%%vmName% already exists
    exit 1
)

:: 1. Create a folder that contains the VM
md %destination%

:: 2. Create necessary files using ovftool.exe
%ovftoolLocation% --name=%vmName% %source% %destination% 

:: 3. Create a vmx file with a custom configuration
set vmxFileName=%vmName%.vmx
set vmxFileLocation=%destination%%vmName%\%vmxFileName%

echo> %vmxFileLocation% .encoding = "UTF-8"
echo>> %vmxFileLocation% displayName = %vmName%
echo>> %vmxFileLocation% guestOS = "ubuntu-64"

echo>> %vmxFileLocation% virtualHW.version = "10"
echo>> %vmxFileLocation% virtualHW.productCompatibility = "hosted"

echo>> %vmxFileLocation% config.version = "8"

echo>> %vmxFileLocation% numa.vcpu.coresPerNode = "0"
echo>> %vmxFileLocation% numvcpus = "4"
echo>> %vmxFileLocation% memsize = "4096"
echo>> %vmxFileLocation% vhv.enable = "TRUE"
echo>> %vmxFileLocation% cpuid.numSMT = "1"
echo>> %vmxFileLocation% vcpu.hotadd = "true"
echo>> %vmxFileLocation% mem.hotadd = "true"

echo>> %vmxFileLocation% pciBridge0.present = "TRUE"

echo>> %vmxFileLocation% pciBridge4.present = "TRUE"
echo>> %vmxFileLocation% pciBridge4.virtualDev = "pcieRootPort"
echo>> %vmxFileLocation% pciBridge4.functions = "8"

echo>> %vmxFileLocation% pciBridge5.present = "TRUE"
echo>> %vmxFileLocation% pciBridge5.virtualDev = "pcieRootPort"
echo>> %vmxFileLocation% pciBridge5.functions = "8"

echo>> %vmxFileLocation% pciBridge6.present = "TRUE"
echo>> %vmxFileLocation% pciBridge6.virtualDev = "pcieRootPort"
echo>> %vmxFileLocation% pciBridge6.functions = "8"

echo>> %vmxFileLocation% pciBridge7.present = "TRUE"
echo>> %vmxFileLocation% pciBridge7.virtualDev = "pcieRootPort"
echo>> %vmxFileLocation% pciBridge7.functions = "8"

echo>> %vmxFileLocation% vmci0.present = "TRUE"
echo>> %vmxFileLocation% vmci0.unrestricted = "false"

echo>> %vmxFileLocation% mks.enable3d = "TRUE"

echo>> %vmxFileLocation% scsi0:0.present = "TRUE"
echo>> %vmxFileLocation% scsi0:0.deviceType = "disk"
echo>> %vmxFileLocation% scsi0:0.fileName = %vmName%-disk1.vmdk
echo>> %vmxFileLocation% scsi0:0.allowguestconnectioncontrol = "false"
echo>> %vmxFileLocation% scsi0:0.mode = "persistent"

echo>> %vmxFileLocation% scsi0.virtualDev = "lsilogic"
echo>> %vmxFileLocation% scsi0.present = "TRUE"

echo>> %vmxFileLocation% sata0.present = "TRUE"

echo>> %vmxFileLocation% ethernet0.present = "TRUE"
echo>> %vmxFileLocation% ethernet0.virtualDev = "e1000"
echo>> %vmxFileLocation% ethernet0.connectionType = "nat"
echo>> %vmxFileLocation% ethernet0.startConnected = "TRUE"
echo>> %vmxFileLocation% ethernet0.addressType = "generated"
echo>> %vmxFileLocation% ethernet0.wakeOnPcktRcv = "FALSE"
echo>> %vmxFileLocation% ethernet0.allowguestconnectioncontrol = "true"

echo>> %vmxFileLocation% ethernet1.present = "TRUE"
echo>> %vmxFileLocation% ethernet1.virtualDev = "e1000"
echo>> %vmxFileLocation% ethernet1.connectionType = "bridged"
echo>> %vmxFileLocation% ethernet1.startConnected = "TRUE"
echo>> %vmxFileLocation% ethernet1.addressType = "generated"
echo>> %vmxFileLocation% ethernet1.wakeOnPcktRcv = "false"
echo>> %vmxFileLocation% ethernet1.allowguestconnectioncontrol = "true"

echo>> %vmxFileLocation% tools.syncTime = "false"

echo>> %vmxFileLocation% toolscripts.afterpoweron = "true"
echo>> %vmxFileLocation% toolscripts.afterresume = "true"
echo>> %vmxFileLocation% toolscripts.beforepoweroff = "true"
echo>> %vmxFileLocation% toolscripts.beforesuspend = "true"

echo>> %vmxFileLocation% powerType.powerOff = "soft"
echo>> %vmxFileLocation% powerType.reset = "soft"
echo>> %vmxFileLocation% powerType.suspend = "soft"

echo>> %vmxFileLocation% extendedConfigFile = %vmName%.vmxf
echo>> %vmxFileLocation% floppy0.present = "FALSE"

:: 4. Starting the PNETLAB VM
%vmrunLocation% -T ws start %vmxFileLocation%