# Changelog for ishare2

All notable changes to this project will be documented in this file. You can upgrade ishare2 to the latest version using `ishare2 upgrade` and then selecting `option 1`

## [v1.7.4] - 2023-Mar-05

1) Fixed: Broken links for ishare2 upgrade menu.
2) Prevent broken links for ishare2 upgrade menu.
3) Added: Reboot confirmation to upgrade scripts.

## [v1.7.3] - 2023-Feb-23

1) Added: New upgrade option in upgrade menu: 3) (UNSTABLE) Upgrade to PNETLab 6 (ONLY AVAILABLE FOR UBUNTU 20.04). This will install PNetLab 6 on your VM. It is only supported on Ubuntu 20.04.

## [v1.7.2] - 2023-Feb-12

1) Added: `--overwrite` flag. Users can specify they want to overwrite an image by passing this 4th argument. Useful when download gets interrupted or you want to restore it to the initial state. Syntax: `ishare2 pull <type> <id> --overwrite`

## [v1.7.1] - 2023-Feb-08

1) Modified: Minor changes were made in the check_user_is_root() function in order to be more precise on user privileges when executing ishare2

## [v1.7.0] - 2023-Feb-04

1) Modified: About `ishare2 upgrade` > `option 2`: Now, there are 2 stable versions of PNETLab available to use. Other releases were BETA type and they are not available anymore

## [v1.6.9] - 2023-Feb-04

1) Modified: PNETLab version 5.3.11 changed state from BETA to STABLE. This upgrade can be implemented using this command: `ishare2 upgrade` > `option 2` and selecting the correspondant option

## [v1.6.8] - 2023-Feb-03

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.11 (Not possible for this case: 6.x to 5.3.11)

## [v1.6.7] - 2023-Feb-03

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.10 (Not possible for this case: 6.x to 5.3.10)

## [v1.6.6] - 2023-Feb-02

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.8 (Not possible for this case: 6.x to 5.3.8)

## [v1.6.5] - 2023-Feb-02

1) Added: Now, menu `ishare2 upgrade` > `option 2` displays a message next to each version to distinguish between the STABLE and BETA versions of PNETLab

## [v1.6.4] - 2023-Feb-02

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.7 (Not possible for this case: 6.x to 5.3.7)

## [v1.6.3] - 2023-Jan-31

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.5 (Not possible for this case: 6.x to 5.3.5)

## [v1.6.2] - 2023-Jan-31

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.4 (Not possible for this case: 6.x to 5.3.4)

## [v1.6.1] - 2023-Jan-30

1) Added: Some instructions were added to `ishare2_gui_download()` function in order to avoid some errors related to missing packages (pip install uvicorn, pip install fastapi and pip install jinja2 instructions were added)

## [v1.6.0] - 2023-Jan-30

1) Added: Command `ishare2 gui stop` was added into `ishare2_gui_download()` function in order to avoid errors when downloading/upgrading ishare2 GUI

## [v1.5.9] - 2023-Jan-30

1) Added: A new version control was added for ishare2 GUI. It can be seen using the `ishare2` command and looking at the bottom of it. New functions and variables were implemented. Also, using `ishare2 upgrade` > `option 3` it is possible to upgrade it.

## [v1.5.8] - 2023-Jan-29

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.2 (Not possible for this case: 6.x to 5.3.2)

## [v1.5.7] - 2023-Jan-27

1) Added: A new feature has been added to ishare2: It is a web app to use ishare2 in browser and it is called `ishare2 GUI`. You can download it by using `ishare2 gui download` and then start it with `ishare2 gui start`. Open your web browser using <http://localhost:5000>, <http://127.0.01:5000> or <http://pnetlab_ip_address:5000> to access. Also, it can be stopped by using `ishare2 gui stop` and restarted with `ishare2 gui restart`

## [v1.5.6] - 2023-Jan-25

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.3.0 (Not possible for this case: 6.x to 5.3.0)

## [v1.5.5] - 2023-Jan-23

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.2.9 (Not possible for this case: 6.x to 5.2.9)

## [v1.5.4] - 2023-Jan-23

1) Modified: Changes were made in set_yml_template_folder_location() function. Now, this function support the following PNETLab versions:

    For `/opt/unetlab/html/templates/`: 4.2.10 and 5.0.1

    For `/opt/unetlab/html/templates/intel/` or `/opt/unetlab/html/templates/amd/`: 5.2.x, 5.3.x and 6.x

    5.3.x is not implemented yet (Change made in case it is needed in the future)

## [v1.5.3] - 2023-Jan-22

1) Modified: --content-disposition was added in order to download images from other repo

## [v1.5.2] - 2023-Jan-22

1) Modified: Some strings were modified when using this option: `ishare2 upgrade` > `option 2`. Now, it looks better for users

## [v1.5.1] - 2023-Jan-22

1) Added: A new option was added to `ishare2 upgrade` > `option 2`: Now, it is possible to upgrade PNETLab from almost any version to v5.2.8 (Not possible for this case: 6.x to 5.2.8)

## [v1.5.0] - 2023-Jan-22

1) Added: Some code has been added to ishare2 to support PNETLab upgrade to v5.2.8 (Same as v5.2.7 fix: AMD and Intel folders at html/templates/). PNETLab users from v4.2.10 should not have any problem

## [v1.4.9] - 2023-Jan-19

1) Added: This version adds support to PNETLab 6.x related to yml template location (AMD and Intel folders)

## [v1.4.8] - 2023-Jan-17

1) Added: A menu was added into the `ishare2 upgrade` command. This menu allows users to upgrade ishare2 and PNETLab to their latest versions

## [v1.4.7] - 2023-Jan-16

1) Added: A function called set_url_constants() was added to the code and to the main() execution. This function contains all of the URL needed in the project.
2) Modified: Function called set_color_variables() was renamed to set_color_constants()

## [v1.4.6] - 2023-Jan-16

1) Modified: Minor changes in code: A function called set_color_variables() was created to define all color variables in there. Added to main() execution
2) Deleted: Minor changes in code: Every definition of those variables was removed to get a cleaner code

Note: This update does not change how the code works in any way

## [v1.4.5] - 2023-Jan-13

1) Modified: Minor changes in code: A line was changed from: ls -lh -R /opt/unetlab/addons/iol/bin to: ls -lh -R /opt/unetlab/addons/iol/bin/
2) Deleted: Minor changes in code: A comment stating "# Main code" was deleted from the code

Note: This update does not change how the code works in any way

## [v1.4.4] - 2023-Jan-11

1) Modified: ishare2 code has been modified to better readability using a main() function
2) Modified: Some functions were put together for better understanding: msg_available_options_for_ishare2_search() and msg_incorrect_argument_or_no_arg_for_ishare2_pull()
3) Modified: ishare2 content help function was indented
4) Modified: get_initial_info() renamed to get_initial_information()
5) Modified: check_version_file_exists() renamed to check_ishare2_version_file_exists()
6) Added: - ishare2 search palo and - ishare2 search Licensed were added like examples to the ishare2 message when explaining ishare2 search
7) Added: selector() function was created in order to use a main() function

## [v1.4.3] - 2023-Jan-04

1) Added: A new command was added: `ishare2 changelog`. It shows the last 15 lines of this CHANGELOG.md file in the terminal

## [v1.4.2] - 2023-Jan-03

1) Modified: Code in the set_yml_template_folder_location() function has been rewritten for a better readability (5.2.5, 5.2.6 and 5.2.7)

## [v1.4.1] - 2023-Jan-02

1) Added: Some code has been added to ishare2 to support PNETLab upgrade to v5.2.7 (Same as v5.2.6 fix: AMD and Intel folders at html/templates/). PNETLab users from v4.2.10 should not have any problem

## [v1.4.0] - 2023-Jan-01

1) Added: Some code has been added to ishare2 to support PNETLab upgrade to v5.2.6 (Same as v5.2.5 fix: AMD and Intel folders at html/templates/). PNETLab users from v4.2.10 should not have problems

## [v1.3.9] - 2022-Dec-31

1) Modified: Code has been modified for a better readability

## [v1.3.8] - 2022-Dec-31

1) Deleted: variables called CREDENTIALS (No longer used)
2) Added: Code supporting PNETLab upgrade to v5.2.5. This way, users can upgrade to v5.2.5 and use ishare2 (Problem fixed is related to amd and intel folders). Also, PNETLab v4.2.10 users are able to keep using it without any problems

## [v1.3.7] - 2022-Dec-24

1) Fixed: A problem when trying to download a file in FILE6LINK position (Weird characters added for no reason: ,,,)
2) Modified: Some "if-then" were put in the same line for a better readability
3) Deleted: Code related to problem 1 and png files
4) Deleted: Some echo commands that were previously commented

## [v1.3.6] - 2022-Dec-19

1) Added code in show_ishare2_usage() function:

    This code shows a message when a newer ishare2 upgrade is available when using `ishare2` command

    ![Screenshot_1](https://user-images.githubusercontent.com/115958905/208381203-fe9065ac-9f93-4c2b-85be-47ac86215d1a.jpg)

    Message is displayed in yellow and is located at the bottom part of this command output

    Code looks cleaner and organized in that function now

## [v1.3.5] - 2022-Dec-13

1) Added docker as an option of param1 (type) when using `ishare2`

## [v1.3.4] - 2022-Dec-13

1) Modified function: `corrections_for_docker_images_in_lab_function()` using a for loop and an array

## [v1.3.3] - 2022-Dec-13

1) Added a bin image to ishare2: "i86bi_LinuxL3-AdvEnterpriseK9-M2_157_3_May_2018.bin". This image was already available in ishare2 but the name was a little bit different (specifically it was: "i86bi_Linux-L3-AdvEnterpriseK9-M2_157_3_May_2018.bin"). So, this was made in order to be able to find and download this image in some labs that had this new name. So, it was decided to upload the same image but with a different name.
2) Added support to download dockers from eveng docker hub (<https://hub.docker.com/u/eveng>) when present in lab files
3) Added `ishare2 installed docker` command. Also, available from `ishare2 installed all`
4) Added green colors when using `ishare2 installed all` for better readabillity
5) Added green colors when using `ishare2 labs` and `ishare2 mylabs` for better readabillity

## [v1.3.2] - 2022-Dec-02

1) Modified text on `ishare2`: "Show contact info" changed to "Show useful information"
2) Modified README.md: Now, there are two sections when describing ishare2: Syntax and Examples of usage

## [v1.3.1] - 2022-Dec-02

1) Added a better description message when user tries to upgrade ishare2 and it already has the last version:

    Before

        echo "You have the latest available version: $REMOTE_VALUE"

    After

        echo "ishare2 $REMOTE_VALUE is currently the newest version available"

2) Added some validation related to check if the user is root when executing `ishare2`. If not root, an error message will be prompt and the script will finish

## [v1.3] - 2022-Dec-01

Fixed a bug when using `ishare2 relicense`

## [v1.2] - 2022-Nov-29

Added code to list docker images installed in server after pulling them when using `ishare2 labs` and `ishare2 mylabs`. Also, it retrieves the number of docker images in server.

## [v1.1] - 2022-Nov-24
  
Added some code to check docker service status in order to avoid problems when trying to pull docker images using

* `ishare2 labs <number>`
* `ishare2 labs all`
* `ishare2 mylabs <number>`
* `ishare2 mylabs all`

## [v1.0] - 2022-Nov-22

Initial release
