```batch
This script, designed to be used in Windows, allows you to crack MobaXterm from Personal to Professional Edition using Python3
This code has been modified from its original version

Requirement: You must have Python3 installed in your computer (Tested and working with Python 3.10.6)
```

# crack-mobaxterm.py

### ✨ Quick installation and execution
Use cmd or PowerShell to execute the following:
```batch
curl -s -o crack-mobaxterm.py https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/mobaxterm/22.3/crack-mobaxterm.py && python crack-mobaxterm.py
```
Note: After executing this python file, select `Yes` to confirm

### Installation
Download this script into Windows applying this command in cmd or PowerShell:
```batch
curl -s -o crack-mobaxterm.py https://raw.githubusercontent.com/pnetlabrepo/ishare2/main/mobaxterm/22.3/crack-mobaxterm.py
```

### Useful information
1. Syntax for this script is as follows:

```batch
python crack-mobaxterm.py [username] [version]
```

Note: `username` and `version` are optional parameters

2. When installing MobaXterm, make sure installation path is one of the following because python code will be scanning them in order to know where MobaXterm.exe was installed:

```batch
"C:\Program Files (x86)\Mobatek\MobaXterm\"
"D:\Program Files (x86)\Mobatek\MobaXterm\"
"E:\Program Files (x86)\Mobatek\MobaXterm\"
```

Note: You can add a new installation path by modifing this list inside code

   This allows the code to move the generated crack file to the MobaXterm´s installation path and open the software for you when crack process finishes.
   
   If MobaXterm is installed in another path, crack file will be generated as well but it must be moved manually by you to complete the process.

### Execution
Once MobaXterm is installed, locate in the same directory crack-mobaxterm.py was downloaded and execute it with:
```batch
python crack-mobaxterm.py
```
After executing this python file, select `Yes` to confirm

### Software used:

1. Python 3.10.6
2. MobaXterm Home Edition v22.3 (Installer Edition): Green button at [MobaXterm Home Edition](https://mobaxterm.mobatek.net/download-home-edition.html)
