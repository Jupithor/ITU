#!/bin/bash

#We need to get dotnet for mftecmd and for ilspy
#copied and adjusted from (https://github.com/sethenoka/Install_EZTools/blob/main/install_net9.sh) to only download dotnet9 and  mftecmd

GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

clear

echo "--------------------------------------------------------------------------------------------"
echo "Installing prereqs..." 1>&2

if sudo apt-get update > /dev/null && sudo apt-get install -y wget apt-transport-https software-properties-common > /dev/null; then
    echo "${GREEN}Prereqs installed.${NC}" 1>&2
else
    echo "${RED}ERROR: Couldn't install prereqs.${NC}" 1>&2
fi

echo "--------------------------------------------------------------------------------------------"
echo "We need to install both .NET8 and .NET9"
echo "Adding microsoft package to repo"
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update && \
echo "Checking for .NET8."
if dpkg -s dotnet-sdk-8.0  &>/dev/null; then
echo ".NET8  is installed";
else
echo "Installing .NET8"
sudo apt-get install -y dotnet-sdk-8.0
fi
echo "Checking for .NET9."
if dpkg -s dotnet-sdk-9.0  &>/dev/null; then
echo ".NET9  is installed";
else
echo "Installing .NET9"
sudo apt-get install -y dotnet-sdk-9.0
fi

# Download a zip file, unzip into a destination, and remove the zip
download_and_unzip() {
  local url="$1"
  local dest_dir="$2"
  local zip_name=$(basename "$url")
  echo "--------------------------------------------------------------------------------------------" 1>&2
  echo "Downloading ${zip_name}..." 1>&2
  if wget "$url" -q && sudo unzip "$zip_name" -d "$dest_dir" > /dev/null 2>&1 && rm -f "$zip_name"; then
    echo "${GREEN}${zip_name} installed.${NC}" 1>&2
  else
    echo "${RED}ERROR: Couldn't install ${zip_name}.${NC}" 1>&2
  fi
}

# Install MFTECmd using download_and_unzip
download_and_unzip "https://download.ericzimmermanstools.com/net9/MFTECmd.zip" "/opt/MFTEcmd"

echo "--------------------------------------------------------------------------------------------"
echo "Checking for Sleuthkit.."
if dpkg -s sleuthkit &>/dev/null; then
echo "Sleuthkit is installed";
else
echo "Installing Sleuthkit"
sudo apt install sleuthkit;
fi
echo "--------------------------------------------------------------------------------------------"
echo "Checking for ILSpy.."
if dotnet tool list ilspycmd &>/dev/null; then
echo "ilspycmd  is installed";
else
echo "Installing ilspycmd"
dotnet tool install --global ilspycmd --version 9.1.0.7988
fi
echo "Finalising..."
export PATH="$PATH:/opt"
echo "alias mftecmd='dotnet /opt/MFTEcmd/MFTECmd.dll'" >> ~/.bashrc

. ~/.bashrc

read -p "Installation complete. You may need to exit the terminal for the relevant aliases to work. Press any key to exit script..."
