<h1 align="center">
  <img src="https://media1.giphy.com/media/wvQIqJyNBOCjK/giphy.gif" width="100"/>

ishare2
</h1>

<h2 align="center">
A CLI-based tool written in Bash to easily download and manage images in your PNetLab server

(and possibly other similar platforms)
  
  :star:New: Since v1.5.7, a web app was released to use ishare2 from a web browser.
  
  The web app's source code can be found in its GitHub repo: <a href='https://github.com/ishare2-org/ishare2-web-gui'>ishare2 web GUI</a>
</h2>

## :hammer_and_wrench: Language

<div>
  <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/bash/bash-original.svg" title="Bash" alt="Bash" width="40" height="40"/>&nbsp;
</div>

## 📚 Summary

- [🚀 Installation](#installation)
- [✅ Syntax](#syntax)
- [Examples of usage](#examples)
- [💎 Search for images by type or name](#search)
  - [ishare2 search by type](#search-type)
  - [ishare2 search by name](#search-name)
- [💎 Pull images by image number](#pull)
- [💎 Pull all images at once](#pull-all)
- [💎 Show installed images on server](#installed)
- [💎 Download all images needed for a lab (Default path)](#labs)
- [💎 Download all images needed for a lab (Customized path)](#mylabs)
- [💎 Web app to use ishare2 from a web browser](#gui)
- [💎 Extras](#extras)
- [💎 Useful information](#useful-information)
- [💎 Show the latest changes made to ishare2](#changelog)
- [💎 Upgrade ishare2 and PNETLab VM](#upgrade)
- [💎 Known limitations](#known-limitations)
- [Useful links](#links)
- [Useful resources](#useful-resources)
- [Need help?](#help)

## 🚀 Installation <a id="installation"></a>

There are different ways of installing `ishare2` in your terminal. Choose one of the following options:

### wget

```linux
wget -O /usr/sbin/ishare2 https://raw.githubusercontent.com/pnetlabrepo/ishare2/alpha/ishare2 > /dev/null 2>&1 && chmod +x /usr/sbin/ishare2 && ishare2
```

### curl

```linux
curl -o /usr/sbin/ishare2 https://raw.githubusercontent.com/pnetlabrepo/ishare2/alpha/ishare2 > /dev/null 2>&1 && chmod +x /usr/sbin/ishare2 && ishare2\
```

### Manual installation

- Download the latest version of ishare2 from the GitHub repository.
- Copy the file to /usr/sbin/ishare2
- Make the file executable using `chmod +x /usr/sbin/ishare2`
- Run `ishare2` to start using it

`Note: You can install different versions of ishare2 browsing the releases page or tracking back to previous commits`

## ✅ Syntax <a id="syntax"></a>

```linux
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

## Examples of usage <a id="examples"></a>

## 💎 Search for images by type or name <a id="search"></a>

### ishare2 search <type> <a id="search-type"></a>

```linux
# ishare2 search all
# ishare2 search bin
# ishare2 search qemu
# ishare2 search dynamips
```

### ishare2 search <name> <a id="search-name"></a>

Examples:

```linux
# ishare2 search vios
# ishare2 search win-
# ishare2 search winserver
# ishare2 search kali
# ishare2 search mikro
# ishare2 search forti
# ishare2 search nxos
# ishare2 search vmx
# ishare2 search esxi
# ishare2 search palo
# ishare2 search Licensed
```

`You can search for images by name or by type. If you search by name, you will get all images that match the name you entered. If you search by type, you will get all images of that type`

## 💎 Pull images by image number <a id="pull"></a>

```linux
# ishare2 pull bin <number>
# ishare2 pull qemu <number>
# ishare2 pull dynamips <number>
```

The image number can be obtained using `ishare2 search <type>` command.

## 💎 Pull all images at once <a id="pull-all"></a>

```linux
# ishare2 pull bin all
# ishare2 pull qemu all (Not available for qemu type due to its large size)
# ishare2 pull dynamips all
```

## 💎 Show installed images on server <a id="installed"></a>

```linux
# ishare2 installed all
# ishare2 installed bin
# ishare2 installed qemu
# ishare2 installed dynamips
# ishare2 installed docker
```

## 💎 Download all images needed for a lab (Default path) <a id="labs"></a>

ishare2 can automatically download all images needed for a lab. This feature is available for .unl labs usually downloaded from [PNetLab Store](https://user.pnetlab.com/store/labs/view) or other sources.

```linux
# ishare2 labs
# ishare2 labs <number>
# ishare2 labs all
```

`Not available for every lab because some of them are encrypted by lab authors and cannot be read by ishare2`

## 💎 Download all images needed for a lab (Customized path) <a id="mylabs"></a>

```linux
# ishare2 mylabs <path>
# ishare2 mylabs <path> <number>
# ishare2 mylabs <path> all
```

## 💎 ishare2 GUI <a id="gui"></a>

```linux
# ishare2 gui install

# ishare2 gui start
# ishare2 gui stop
# ishare2 gui restart
```

## 💎 Extras <a id="extras"></a>

```linux
# ishare2 relicense
# ishare2 upgrade
# ishare2 changelog
# ishare2 help
# ishare2 test
```

## Useful information <a id="useful-information"></a>

[HELP.md](https://github.com/pnetlabrepo/ishare2/blob/main/HELP.md)

## See the latest changes on ishare2 <a id="changelog"></a>

[CHANGELOG.md](https://github.com/pnetlabrepo/ishare2/blob/main/CHANGELOG.md)

## How to upgrade your PNetLab server <a id="upgrade"></a>

**Important:** Newer versions of PNetLab might be published in PNetLab's official group chat before they are available in ishare2.  

To upgrade your PNETLab server, you can use the following methods:

- Upgrade from v4.2.10 to v5.0.1: [Instructions](https://github.com/pnetlabrepo/ishare2/tree/main/upgrades/from_4.2.10_to_5.0.1)
- Upgrade from any to v5.3.11: [Instructions](https://github.com/pnetlabrepo/ishare2/tree/main/upgrades/from_any_to_5.3.11)

Note: You can also upgrade PNETLab using `ishare2 upgrade`, then using the `option 2` and finally select an option from list.

## Known limitations <a id="known-limitations"></a>

- **Quota Limits:**  
You might encounter quota limits when downloading images. If that happens, you can wait a few minutes and try again. If the problem persists, please contact us through our Telegram group. Search the link to the group chat in the channel's pinned message or click the chat icon in the channel's description: [@NetLabHub](https://t.me/NetLabHub) (By not sharing the link here, we avoid spam and bots in the group chat)

## 🔗 Links <a id="links"></a>

- Image files source: [LabHub](https://labhub.eu.org/)
- Docker images can be found at [hub.docker.com](https://hub.docker.com/)

## ✨ Useful resources <a id="useful-resources"></a>

Check these links to get information on device credentials

- [Excel file #1: passwords_eve.xlsx](https://labhub.eu.org/UNETLAB%20I/addons/passwords/passwords_eve.xlsx)
- [Excel file #2: Passwords - QEMU.xls](https://labhub.eu.org/UNETLAB%20II/Passwords%20-%20QEMU.xls)
- [PNG file: Eve-NG-Linux.png](https://labhub.eu.org/UNETLAB%20II/qemu/Linux/Eve-NG-Linux/Eve-NG-Linux.png)

## ❓Need help? <a id="help"></a>

You can get in touch with the community through the following links:  

- LabHub Community: [Telegram](https://t.me/NetLabHub)  
- PNETLab Community: [Telegram](https://t.me/pnetlab)
