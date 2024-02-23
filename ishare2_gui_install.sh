#!/usr/bin/env bash

# Check if the script is running on Ubuntu 20.04
if [[ ! -f /etc/os-release ]]; then
    echo -e "${RED}Error: This script only supports Ubuntu 20.04.${NO_COLOR}"
    exit 1
fi

ISHARE2_GUI_DIR=/opt/ishare2/gui
PYTHON3_11_PATH=$(command -v python3.11)

if [[ -z "$PYTHON3_11_PATH" ]]; then
    echo -e "${RED}Error: Python 3.11 is not installed.${NO_COLOR}"
    echo -e "${YELLOW}Do you want to install Python 3.11?${NO_COLOR}"
    read -p "Press [y/n]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_python3_11_from_ppa
    else
        echo -e "${RED} [-] ishare2 GUI installation was canceled. ${NO_COLOR}"
        exit 1
    fi
fi

echo -e "${GREEN} [+] ishare2 GUI is being downloaded and installed. Please, wait until the process is done...${NO_COLOR}"
echo -e "${YELLOW} [!] Stopping ishare2 GUI service...${NO_COLOR}"
sudo systemctl stop ishare2_gui.service

if [[ ! -d "$ISHARE2_GUI_DIR" ]]; then
    mkdir -p "$ISHARE2_GUI_DIR"
fi

if [[ -d "$ISHARE2_GUI_DIR" ]]; then
    read -p "Found a previous installation of ishare2 GUI. Are you sure you want to remove it? [y/n]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Removing the previous installation of ishare2 GUI...${NO_COLOR}"
        sudo rm -rf "$ISHARE2_GUI_DIR"/* >"$ISHARE2_DIR/ishare2_gui_install.log"
        sudo rm -rf "$ISHARE2_GUI_DIR"/.* >"$ISHARE2_DIR/ishare2_gui_install.log"
        # Remove systemd service
        echo -e "${YELLOW} [!] Removing ishare2 GUI systemd service...${NO_COLOR}"
        sudo systemctl disable ishare2_gui.service >"$ISHARE2_DIR/ishare2_gui_install.log"
        sudo rm /etc/systemd/system/ishare2_gui.service >"$ISHARE2_DIR/ishare2_gui_install.log"
    else
        echo -e "${RED} [-] ishare2 GUI installation was canceled. ${NO_COLOR}"
        exit 1
    fi
fi

echo -e "${GREEN} [+] Downloading ishare2 GUI...${NO_COLOR}"
URL_GUI_APP_ZIP="URL_GUI_APP_ZIP=https://github.com/ishare2-org/ishare2-web-gui/archive/refs/heads/master.zip"
wget -q --show-progress "$URL_GUI_APP_ZIP" -O "$ISHARE2_GUI_DIR/app.zip"

# Unzip
echo -e "${GREEN} [+] Unzipping ishare2 GUI files...${NO_COLOR}"
unzip -o -q "$ISHARE2_GUI_DIR/app.zip" -d "$ISHARE2_GUI_DIR"
if [[ $? -ne 0 ]]; then
    echo "${RED} [-] Error unzipping ishare2 GUI. The file may be corrupted. ${NO_COLOR}"
    echo "${RED} [-] Please check your internet connection and try again. ${NO_COLOR}"
    exit 1
fi

# Move files
echo -e "${GREEN} [+] Moving files... ${NO_COLOR}"
sudo mv "$ISHARE2_GUI_DIR"/ishare2-web-gui-master/* "$ISHARE2_GUI_DIR"
# Move files starting with a dot if any
sudo mv "$ISHARE2_GUI_DIR"/ishare2-web-gui-master/.* "$ISHARE2_GUI_DIR"
sudo rmdir "$ISHARE2_GUI_DIR"/ishare2-web-gui-master

sudo rm "$ISHARE2_GUI_DIR/app.zip"

echo -e "${GREEN} [+] Installing ishare2 GUI requirements...${NO_COLOR}"
# Make sure pip3 is installed for Python 3.11
sudo apt-get update
curl -sS --insecure https://bootstrap.pypa.io/get-pip.py | python3.11

# Check if pip3.11 is installed and check version pip3.11 -V
pip3.11 -V
if [[ $? -ne 0 ]]; then
    echo -e "${RED} [-] Error installing pip3.11. ${NO_COLOR}"
    echo -e "${RED} [-] Please install pip3.11 manually and try again. ${NO_COLOR}"
    echo -e "${RED} [-] You can find more information here: https://pip.pypa.io/en/stable/installing/ ${NO_COLOR}"
    exit 1
fi

# Make sure venv is installed for Python 3.11
sudo apt install -y python3.11-venv
if [[ $? -ne 0 ]]; then
    echo -e "${RED} [-] Error installing venv for Python 3.11. ${NO_COLOR}"
    echo -e "${RED} [-] Please install venv manually for Python 3.11 and try again. ${NO_COLOR}"
    echo -e "${RED} [-] You can find more information here: https://docs.python.org/3/library/venv.html ${NO_COLOR}"
    exit 1
fi

# Make venv for ishare2 GUI
python3.11 -m venv "$ISHARE2_GUI_DIR/venv"
if [[ $? -ne 0 ]]; then
    echo -e "${RED} [-] Error creating venv for ishare2 GUI. ${NO_COLOR}"
    echo -e "${RED} [-] Please read previous logs for troubleshooting. ${NO_COLOR}"
    exit 1
fi

# Install requirements
"$ISHARE2_GUI_DIR/venv/bin/pip" install -r "$ISHARE2_GUI_DIR/requirements.txt"
if [[ $? -ne 0 ]]; then
    echo -e "${RED} [-] Error installing ishare2 GUI requirements. ${NO_COLOR}"
    echo -e "${RED} [-] Please read previous logs for troubleshooting. ${NO_COLOR}"
    exit 1
fi

# Create systemd service to run ishare2 GUI
echo -e "${GREEN} [+] Creating systemd service to run ishare2 GUI...${NO_COLOR}"
cat >/etc/systemd/system/ishare2_gui.service <<EOL
[Unit]
Description=ishare2 GUI Web App
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/opt/ishare2/gui
ExecStart=/opt/ishare2/gui/venv/bin/uvicorn main:app --workers 4 --host 0.0.0.0 --port 5000
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start ishare2 GUI service
echo -e "${GREEN} [+] Enabling and starting ishare2 GUI service...${NO_COLOR}"
read -p "Do you want to start ishare2 GUI on boot? [y/n]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo systemctl enable ishare2_gui.service
fi
sudo systemctl start ishare2_gui.service
if [[ $? -ne 0 ]]; then
    echo -e "${RED} [-] Error starting ishare2 GUI service. ${NO_COLOR}"
    echo -e "${RED} [-] Please see the logs for troubleshooting. Run: systemctl status ishare2_gui.service ${NO_COLOR}"
    exit 1
fi
echo -e "${GREEN} [!] ishare2 GUI was installed successfully. ${NO_COLOR}"
echo -e "${GREEN}You can access ishare2 GUI at: http://<server_ip>:5000 or http://localhost:5000 ${NO_COLOR}"
echo -e "${GREEN}Additionally, you can use the following commands to manage ishare2 GUI: ${NO_COLOR}"
echo -e "${GREEN}   ishare2 gui start: Start ishare2 GUI service ${NO_COLOR}"
echo -e "${GREEN}   ishare2 gui stop: Stop ishare2 GUI service ${NO_COLOR}"
echo -e "${GREEN}   ishare2 gui restart: Restart ishare2 GUI service ${NO_COLOR}"
echo -e "${GREEN}   systemctl ishare2_gui status: Check ishare2 GUI service status ${NO_COLOR}"

function install_python3_11_from_ppa() {
    # Install the required dependency package
    sudo apt-get update
    sudo apt-get install -y software-properties-common

    # Add the deadsnakes PPA to the APT package manager sources list
    sudo add-apt-repository ppa:deadsnakes/ppa

    # Proceed with the installation of Python 3.11
    sudo apt-get update
    sudo apt-get install -y python3.11

    # Verify the installation
    python3.11 --version
}
