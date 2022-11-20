# ishare2

### CLI-based tool written in Bash used to download and install images into a PNETLab server automatically and with minimal efforts

### Installation (for version 4.2.10)
Apply this command using the terminal
```linux
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/releases/4.2.10/ishare2 > /dev/null 2>&1 && chmod +x /usr/sbin/ishare2 && ishare2
```

### Installation (for version 5.0.1)
Apply this command using the terminal
```linux
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/releases/5.0.1/ishare2 > /dev/null 2>&1 && chmod +x /usr/sbin/ishare2 && ishare2
```

Note: There is no need to be in the same directory where *ishare2* file is installed in order to execute it

### How to use it

    Usage ishare2 [action] [param1] [param2]
    
    action:
      search      : Search for images by type
      pull        : Download an image by type and number
      installed   : Show installed images on server
      labs        : Show labs on server and download images for those labs
      ownlabs     : Same as labs command but using a customized path to labs
      relicense   : Generate a new iourc license for bin images
      upgrade     : Upgrade ishare2 code to the latest version
      help        : Show contact info
      
    param1:
      type = all, bin, qemu, dynamips or name
      
    param2:
      number = This number can be obtained using ishare2 search <type>
      
    Examples:
    
    - ishare2 search <type>
        - ishare2 search all
        - ishare2 search bin
        - ishare2 search qemu
        - ishare2 search dynamips
        - ishare2 search <name>
            Examples:
            - ishare2 search vios
            - ishare2 search win-
            - ishare2 search winserver
            - ishare2 search kali
            - ishare2 search mikro
            - ishare2 search forti
            - ishare2 search nxos
            - ishare2 search vmx
            - ishare2 search esxi
            - More <name> options using ishare2 search all
            
    - ishare2 pull bin <number>
    - ishare2 pull qemu <number>
    - ishare2 pull dynamips <number>
    
    - ishare2 pull bin all
    - ishare2 pull qemu all (Unavailable for qemu type)
    - ishare2 pull dynamips all
    
    - ishare2 installed all
    - ishare2 installed bin
    - ishare2 installed qemu
    - ishare2 installed dynamips
    
    - ishare2 labs
    - ishare2 labs <number>
    - ishare2 labs all
    
    - ishare2 ownlabs <path>
    - ishare2 ownlabs <path> <number>
    - ishare2 ownlabs <path> all
    
    - ishare2 relicense
    - ishare2 upgrade
    - ishare2 help

### How to upgrade your PNETLab server to v5.0.1

Only applicable for cases where your PNETLab version is 4.2.10:

Copy and paste this command in your server
```linux
wget -O upgrade.sh https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/upgrades/to_5.0.1/upgrade.sh > /dev/null 2>&1 && chmod +x upgrade.sh && bash upgrade.sh
```
After a few seconds, the upgrade will be done.

Note: This upgrade does not use ishare2:
It just downloads the upgrade.sh file from this repository and executes it using the same instructions described in the PNETLab Official website ["How to Upgrade PNETLab? Section 2. PNETLab can not connect to Internet."](https://pnetlab.com/pages/documentation?slug=how-to-upgrade-pnetlab)

### Known Limitations

1) Avoid to cancel a download in progress:

    You will not be allowed to download that image again because ishare2 will recognize that your file/folder already exists in the server.
    In this case, you will have to manually remove that file/folder

### Links

Images (QEMU, bin and dynamips) can be found at [unetlab.cloud](https://unetlab.cloud/)

### Useful resources

There are 2 Excel and 1 PNG password files for device credentials

[Excel file 1](https://unetlab.cloud/0:/addons/passwords/)

[Excel file 2](https://unetlab.cloud/1:/)

[PNG file 3](https://unetlab.cloud/1:/qemu/Linux/Eve-NG-Linux/)

### Need help?

Get in touch with us using our Telegram Channel: [PNETLab platform Group](https://t.me/PNETLab)
