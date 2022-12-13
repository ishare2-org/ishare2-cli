# Change Log
All notable changes to this project will be documented in this file. You can upgrade ishare2 to the latest version using "ishare2 upgrade"

## [v1.3.3] - 2022-Dic-13

1) Added a bin image to ishare2: "i86bi_LinuxL3-AdvEnterpriseK9-M2_157_3_May_2018.bin". This image was already available in ishare2 but the name was a little bit different (specifically it was: "i86bi_Linux-L3-AdvEnterpriseK9-M2_157_3_May_2018.bin"). So, this was made in order to be able to find and download this image in some labs that had this new name. So, it was decided to upload the same image but with a different name.
2) Added support to download dockers from eveng docker hub (https://hub.docker.com/u/eveng) when present in lab files
3) Added "ishare2 installed docker" command. Also, available from "ishare2 installed all"
4) Added green colors when using "ishare2 installed all" for better readabillity
5) Added green colors when using "ishare2 labs" and "ishare2 mylabs" for better readabillity

## [v1.3.2] - 2022-Dic-02

1) Modified text on ishare2: "Show contact info" changed to "Show useful information"
2) Modified README.md: Now, there are two sections when describing ishare2: Syntax and Examples of usage

## [v1.3.1] - 2022-Dic-02

1) Added a better description message when user tries to upgrade ishare2 and it already has the last version:

    Before
    
        echo "You have the latest available version: $REMOTE_VALUE"

    After
    
        echo "ishare2 $REMOTE_VALUE is currently the newest version available"

2) Added some validation related to check if the user is root when executing ishare2. If not root, an error message will be prompt and the script will finish

## [v1.3] - 2022-Dic-01

Fixed a bug when using "ishare2 relicense"

## [v1.2] - 2022-Nov-29

Added code to list docker images installed in server after pulling them when using "ishare2 labs" and "ishare2 mylabs". Also, it retrieves the number of docker images in server.

## [v1.1] - 2022-Nov-24
  
Added some code to check docker service status in order to avoid problems when trying to pull docker images using

* "ishare2 labs \<number\>"
* "ishare2 labs all"
* "ishare2 mylabs \<number\>"
* "ishare2 mylabs all"

## [v1.0] - 2022-Nov-22
Initial release
