# Change Log
All notable changes to this project will be documented in this file. You can upgrade ishare2 to the latest version using "ishare2 upgrade"

## [v1.3.2] - 2022-Dic-02

1) Modified text on ishare2: "Show contact info" changed to "Show useful information"
2) Modified README.md: Now, there two sections when describing ishare2: Syntax and Examples of usage

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
