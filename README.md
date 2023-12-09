<h1 align="center">
  <img src="https://media1.giphy.com/media/wvQIqJyNBOCjK/giphy.gif" width="100"/>

ishare2-cli
</h1>

<h2 align="center">
A CLI-based tool written in Bash to easily download and manage images in your PNetLab server
</h2>

## Language

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/bash/bash-original.svg" title="Bash" alt="Bash" width="40" height="40"/>&nbsp;

## 🚀 Quick start

To start using ishare2, you can use one of the following methods:

## One-line installation

### wget

```bash
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/ishare2-org/ishare2-cli/main/ishare2 && chmod +x /usr/sbin/ishare2 && ishare2
```

### curl

```bash
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/ishare2-org/ishare2-cli/main/ishare2 && chmod +x /usr/sbin/ishare2 && ishare2
```

> Note: Run the command as root or using sudo
>
## Line by line installation

1. Download ishare2

```bash
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/ishare2-org/ishare2-cli/main/ishare2
```

2. Make ishare2 executable

```bash
chmod +x /usr/sbin/ishare2
```

3. Run ishare2

```bash
ishare2
```

> Note: Run the command as root or using sudo
>
### Clone the repository

- Download or clone this repository.

  ```bash
  git clone https://github.com/ishare2-org/ishare2-cli.git
  ```

- Copy the file to /usr/sbin/ishare2
  
  ```bash
  cp ishare2-cli/ishare2 /usr/sbin/ishare2
  ```

- Make the file executable using
  
    ```bash
    chmod +x /usr/sbin/ishare2
    ```

- Run `ishare2` to start using it
  
    ```bash
    ishare2
    ```

> Note: Run the command as root or using sudo
>

## Syntax

```bash
    ishare2 [action] [param1] [param2]

    action:
      search      : Search for images by type
      pull        : Download an image by type and number
      installed   : Show installed images on server
      labs        : Show labs on server and download images for those labs
      mylabs      : Same as labs command but using a customized path to labs
      relicense   : Generate a new iourc license for bin images
      upgrade     : Retrieves a menu that allows users to upgrade ishare2 and PNETLab VM
      changelog   : Show the latest changes made to ishare2
      gui         : Web app to use ishare2 in browser
      help        : Show useful information
      test        : Test if ishare2 dependencies are reachable (GitHub, Google Spreadsheets)

    param1:
      type = all, bin, qemu, dynamips, docker or name

    param2:
      number = This number can be obtained using ishare2 search <type>
```

## How to use ishare2

## Search for images

### ishare2 search by name

You can search for images by simply typing the name of the image you want to search for using the following syntax:

```bash
ishare2 search <name> # Example: ishare2 search vios
```

Searches by name should be done taking into account the naming conventions used by emulators. For example, if you want to search for images of Cisco IOSv, you should use the following command:

```bash
ishare2 search vios # Will show all Cisco IOSv images available
```

For qemu images, you can follow the [conventions used by eve-ng](https://www.eve-ng.net/index.php/documentation/qemu-image-namings/). For example, if you want to search for images of Windows 7, you should use the following command:

```bash
ishare2 search win- # Will show all Windows images available
```

Other examples:

```bash
ishare2 search winserver  # Will show all Windows Server images available
ishare2 search linux      # Will show all Linux images available
ishare2 search forti      # Will show all Fortinet images available
ishare2 search palo       # Will show all Palo Alto images available
ishare2 search Licensed   # Will show all images with keyword "Licensed" in their name
```

>Note: You can also also search for images using common keywords for specific Operating Systems.
>

### Search by type

You can search for images by type using the following commands:

```bash
ishare2 search all      # This command will show all available images of all types
ishare2 search bin      # This command will show all available images of bin/iol type
ishare2 search qemu     # This command will show all available images of qemu type
ishare2 search dynamips # This command will show all available images of dynamips type
```

You can narrow your search by specifying the type of image you are looking for by using the following syntax:

```bash
ishare2 search <type> <name> # Example: ishare2 search bin vios
```

For example, if you want to search for images of Cisco IOSv, you should use the following command:

```bash
ishare2 search iol vios # Will show all Cisco IOSv images of the type bin/iol available
```

For qemu images, you can do the following:

```bash
ishare2 search qemu win- # Will show all Windows images of the type qemu available
```

For dynamips images, you can do the following:

```bash
ishare2 search dynamips c7200 # Will show all Cisco 7200 images of the type dynamips available
```

## Pull images

In order to download images, you have to specify the type of image and id number using the following syntax:

```bash
ishare2 pull <type> <id>
```

Syntax for each type:

```bash
ishare2 pull bin <id>
ishare2 pull qemu <id>
ishare2 pull dynamips <id>
```

>Note: You get the id number from the search results ishare2 displays after running the search command.
>

## Download all images at once

You can download all images at once using the following syntax:

```bash
ishare2 pull all <type>
```

Commands for each type:

```bash
ishare2 pull bin all      # Will download all bin/iol images available
ishare2 pull qemu all     # Will download all qemu images available
ishare2 pull dynamips all # Will download all dynamips images available
```

>Note: This is not recommended because it will take a long time to download all images, you will use a lot of our bandwidth and you will probably run out of disk space.

## Show installed images

You can see which images are installed on your server using the following commands:

```bash
ishare2 installed all       # Will show all installed images from all types
ishare2 installed bin       # Will show all bin/iol images installed
ishare2 installed qemu      # Will show all qemu images installed
ishare2 installed dynamips  # Will show all dynamips images installed
ishare2 installed docker    # Will show all docker images installed
```

## Download images for a lab

ishare2 can automatically download all images needed for a lab. This feature is available for .unl labs (usually downloaded from the [PNetLab Store](https://user.pnetlab.com/store/labs/view)).

```bash
ishare2 labs          # Will show all labs available
ishare2 labs <number> # Will download images for the lab with the specified number
ishare2 labs all      # Will download images for all labs available
```

>Note: Feature not available for encrypted labs since ishare2 can't read the contents of those labs.
>

## Download images for a lab using a custom path

You can specify a custom path for ishare2 to look for labs using the following syntax:

```bash
ishare2 mylabs <path>           # Will show all labs available in the specified path
ishare2 mylabs <path> <number>  # Will download images for the lab with the specified number
ishare2 mylabs <path> all       # Will download images for all labs available in the specified path
```

## ishare2 GUI

ishare2 has a web app that allows you to use ishare2 in your browser. To use it, you have to install it using the following command:

```bash
ishare2 gui install
```

Control the ishare2 GUI service using the following commands:

```bash
ishare2 gui start
ishare2 gui stop
ishare2 gui restart
ishare2 gui status
```

## Extra features

We have covered the most important features of ishare2, but there are some extra features that you might find useful:

### Generate a new iourc license for bin images

You can generate a new iourc license for bin images using the following command:

```bash
ishare2 relicense
```

This command will generate a new iourc license and restore the needed files to make it work in case you have accidentally deleted them.

### Upgrade ishare2, ishare2-gui or PNETLab server

Use the following command to upgrade ishare2, ishare2-gui or your PNETLab server:

```bash
ishare2 upgrade
```

Select the option you want to upgrade and wait for the process to finish.

### Show the latest changes made to ishare2

You can see the latest registered changes made to ishare2 using the following command:

```bash
ishare2 changelog
```

### Show useful information

You can see useful information about ishare2 using the following command:

```bash
ishare2 help
```

### Test connectivity

You can test if ishare2 online dependencies are reachable using the following command:

```bash
ishare2 test
```

## Useful information

[HELP.md](https://github.com/pnetlabrepo/ishare2/blob/main/HELP.md)

## See the latest changes on ishare2

[CHANGELOG.md](https://github.com/pnetlabrepo/ishare2/blob/main/CHANGELOG.md)

## Known limitations

- **Quota Limits:**  
You might encounter quota limits when downloading images. If that happens, you can wait a few minutes and try again. If the problem persists, please contact us through our Telegram group. Search the link to the group chat in the channel's pinned message or click the chat icon in the channel's description: [@NetLabHub](https://t.me/NetLabHub) (By not sharing the link here, we avoid spam and bots in the group chat)

## Links

- Image files source: [LabHub](https://labhub.eu.org/)
- Docker images can be found at [hub.docker.com](https://hub.docker.com/)

## Useful resources

Check these links to get information on device credentials

- [Excel file #1: passwords_eve.xlsx](https://labhub.eu.org/UNETLAB%20I/addons/passwords/passwords_eve.xlsx)
- [Excel file #2: Passwords - QEMU.xls](https://labhub.eu.org/UNETLAB%20II/Passwords%20-%20QEMU.xls)
- [PNG file: Eve-NG-Linux.png](https://labhub.eu.org/UNETLAB%20II/qemu/Linux/Eve-NG-Linux/Eve-NG-Linux.png)

## Need help?

You can get in touch with the community through the following links:  

- LabHub Community: [Telegram](https://t.me/NetLabHub)  
- PNETLab Community: [Telegram](https://t.me/pnetlab)
