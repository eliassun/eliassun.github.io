#!/bin/bash

# way 1 to install suricata deb

# Get the path to the .deb file
DEB_FILE_PATH="$1"
NETWORK_INTERFACE="${2:-eth0}"

if [[ ! -f "$DEB_FILE_PATH" ]]; then
    echo "Error: .deb file does not exist at the specified path: $DEB_FILE_PATH"
    exit 1
fi

sudo apt -y install libluajit-5.1-2 luarocks lua5.4 liblua5.4-dev libelf-dev
sudo mkdir /var/log/suricata
sudo mkdir -p /usr/var/run/suricata
sudo luarocks --lua-version=5.4 install luasyslog
sudo luarocks --lua-version=5.4 install lua-cjson

sudo systemctl stop suricata.service
echo "dpkg -i $DEB_FILE_PATH "
# Install the package using dpkg
sudo dpkg -i "$DEB_FILE_PATH"
echo "dpkg-deb -x ${DEB_FILE_PATH} ${DEB_FILE_PATH}_pkg"
# Unpack the Suricata .deb package to a temporary directory
sudo dpkg-deb -x "${DEB_FILE_PATH}" "${DEB_FILE_PATH}_pkg"
# Copy configuration files from the unpacked package to /etc/suricata/
sudo cp -r "${DEB_FILE_PATH}"_pkg/etc/suricata/* /etc/suricata/
# Correct file ownership and permissions
sudo chown -R root:root /etc/suricata
sudo chmod -R 755 /etc/suricata
cd /etc/suricata/
sudo python3 generate_confg.py "$NETWORK_INTERFACE"
sudo systemctl enable suricata.service
sudo systemctl daemon-reload
sudo systemctl start suricata.service
cd /tmp
sudo rm -rf "${DEB_FILE_PATH}_pkg"

echo "Installed $DEB_FILE_PATH"

exit 0

