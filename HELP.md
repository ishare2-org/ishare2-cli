# Useful information

## 1

For problems, use our Telegram Channel describing your problem and sending a screenshot and/or a video.

## 2

For new files to be uploaded, you can also use our Telegram Channel: In this case, you can send or ask for new images to be uploaded.

## 3

Using `ishare2 upgrade` will display a menu that allows users to upgrade ishare2 or the ishare2 GUI.

## 4

If `CiscoIOUKeygen.py`, `iourc` and/or `keepalive.pl` files in `/opt/unetlab/addons/iol/bin/` are deleted, you can recover them by using `ishare2 relicense`. This will not affect images in there. Also, this command, when used, will generate a new license file called `iourc`, needed for bin files.

## 5

Don't cancel a download. In case you do it, you will have to remove incomplete files or folders manually.

## 6

`ishare2 labs` lists the `.unl` labs available in the default labs directory, while `ishare2 mylabs <path>` lets you point ishare2 at any folder where your labs are stored.

## 7

By default ishare2 does not fix image permissions automatically after downloading. Enable this in the setup wizard (`ishare2 config`) or run `ishare2 fix permissions` manually whenever needed.

## 8

Some images ship shell (`.sh`) or PHP (`.php`) scripts that run on your server. ishare2 warns you before downloading such files and lets you skip them, and warns you when one is found inside an extracted archive. Only run or install scripts from sources you trust.

## 9

ishare2 detects your distribution's package manager (`apt`, `dnf`, `yum`, `apk`, `pacman`, or `zypper`) when installing dependencies. Required packages are installed automatically, while suggested (optional) packages ask for confirmation and can be skipped — ishare2 will keep working on a best-effort basis if you skip them.
