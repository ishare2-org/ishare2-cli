# Changelog
All notable changes to this project will be documented in this file. You can upgrade ishare2 to the latest version using `ishare2 upgrade`

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
2) Added support to download dockers from eveng docker hub (https://hub.docker.com/u/eveng) when present in lab files
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
