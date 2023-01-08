<h1 align="center">
  <img src="https://media1.giphy.com/media/wvQIqJyNBOCjK/giphy.gif" width="100"/>
    ishare2
</h1>

<h2 align="center">
  CLI-based Bash tool used to download and install images into a PNETLab server automatically and with minimal efforts
</h2>

## :hammer_and_wrench: Language:
<div>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/bash/bash-original.svg" title="Bash" alt="Bash" width="40" height="40"/>&nbsp;
</div>

## 🚀 Installation
Apply this command using the terminal
```linux
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/ishare2 > /dev/null 2>&1 && chmod +x /usr/sbin/ishare2 && ishare2
```

Note: There is no need to be in the same directory where *ishare2* file is installed in order to execute it

## ✅ Syntax
    
    ishare2 [action] [param1] [param2]
    
    action:
      search      : Search for images by type
      pull        : Download an image by type and number
      installed   : Show installed images on server
      labs        : Show labs on server and download images for those labs
      mylabs      : Same as labs command but using a customized path to labs
      relicense   : Generate a new iourc license for bin images
      upgrade     : Upgrade ishare2 code to the latest version
      changelog   : Show the latest changes made to ishare2
      help        : Show useful information
      
    param1:
      type = all, bin, qemu, dynamips, docker or name
      
    param2:
      number = This number can be obtained using ishare2 search <type>
   
## ✅ Examples of usage
    
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
    - ishare2 installed docker
    
    - ishare2 labs
    - ishare2 labs <number>
    - ishare2 labs all
    
    - ishare2 mylabs <path>
    - ishare2 mylabs <path> <number>
    - ishare2 mylabs <path> all
    
    - ishare2 relicense
    - ishare2 upgrade
    - ishare2 changelog
    - ishare2 help
    
## Useful information

    1) For problems, use our Telegram Channel describing your problem and sending a screenshot and/or a video
    2) For new files to be uploaded, you can use our Telegram Channel too. In this case, you can send or ask for new images to be uploaded
    3) Using ishare2 upgrade will result in upgrading this utility (ishare2). It will not upgrade your PNETLab Ubuntu VM version
    4) If CiscoIOUKeygen.py, iourc and/or keepalive.pl files in /opt/unetlab/addons/iol/bin/ are deleted, you can recover them by using ishare2 relicense. This will not affect images in there
    Also, this command when used, will generate a new license file called "iourc", needed for bin files
    5) Don't cancell a download. In case you do it, you will have to remove incomplete files or folders manually
    6) The main difference between ishare2 labs and ishare2 mylabs is that, in the first case, the folder used is the one PNETLab creates when you download a lab from the store and in the second case you are able to select any folder you want in order to download labs
    
    Telegram Channel: https://t.me/unetlab_cloud

## See the latest changes on ishare2

[CHANGELOG.md](https://github.com/pnetlabrepo/ishare2/blob/main/CHANGELOG.md)

## How to upgrade your PNETLab server

- Upgrade from v4.2.10 to v5.0.1: [Instructions](https://github.com/pnetlabrepo/ishare2/tree/main/upgrades/to_5.0.1)

## Known limitations

1) Avoid to cancel a download in progress: (BUG FOUND AND TRYING TO FIX IT)

    If you cancel a download in progress, next time you try to download it you will not be allowed to do it again because ishare2 will recognize that it already exists in the server.
    
    In this case, you will have to manually remove it in order to restart the download

## Links

* QEMU, bin and dynamips images can be found at [unetlab.cloud](https://unetlab.cloud/)
* Docker images can be found at [hub.docker.com](https://hub.docker.com/)

## Useful resources

There are 2 Excel and 1 PNG file for device credentials

* [Excel file #1: passwords_eve.xlsx](https://unetlab.cloud/0:/addons/passwords/)
* [Excel file #2: Passwords - QEMU.xls](https://unetlab.cloud/1:/)
* [PNG file: Eve-NG-Linux.png](https://unetlab.cloud/1:/qemu/Linux/Eve-NG-Linux/)

## Need help?

Get in touch with us using our Telegram Channel: [PNETLab platform Group](https://t.me/PNETLab)
