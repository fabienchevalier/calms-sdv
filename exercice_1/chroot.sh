#!/usr/bin/env bash

# Throw an error if any command fails
set -e

echo "
:'######::'##::::'##:'########:::'#######:::'#######::'########:::::::'######::'##::::'##:
'##... ##: ##:::: ##: ##.... ##:'##.... ##:'##.... ##:... ##..:::::::'##... ##: ##:::: ##:
 ##:::..:: ##:::: ##: ##:::: ##: ##:::: ##: ##:::: ##:::: ##::::::::: ##:::..:: ##:::: ##:
 ##::::::: #########: ########:: ##:::: ##: ##:::: ##:::: ##:::::::::. ######:: #########:
 ##::::::: ##.... ##: ##.. ##::: ##:::: ##: ##:::: ##:::: ##::::::::::..... ##: ##.... ##:
 ##::: ##: ##:::: ##: ##::. ##:: ##:::: ##: ##:::: ##:::: ##::::'###:'##::: ##: ##:::: ##:
. ######:: ##:::: ##: ##:::. ##:. #######::. #######::::: ##:::: ###:. ######:: ##:::: ##:
:......:::..:::::..::..:::::..:::.......::::.......::::::..:::::...:::......:::..:::::..::
"

# Make sure the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Check if system version is Debian 12 or a compatible version, exit otherwise
if ! grep -q "^12" /etc/debian_version; then
    echo "This script must be run on Debian 12 or a compatible version." >&2
    exit 1
fi

# Check if architecture is x86_64, exit otherwise
if [ "$(lscpu | grep "Architecture:" | awk '{print $2}')" != "x86_64" ]; then
    echo "This script must be run on an x86_64 arch" >&2
    exit 1
fi

# Install dependencies
echo -e "Installing dependencies..."
apt-get update
apt-get install -y --no-install-recommends \
    libncurses6
echo -e "\e[1;32mOK\e[0m"

# Create the chroot environment & copy binary
echo -e "Creating chroot hierarchy..."
mkdir -p exo1/usr/bin/
cp ./bin/msnake exo1/usr/bin/msnake && chmod +x exo1/usr/bin/msnake

# Copy bash and ls to chroot
cp --parents /bin/bash exo1/
cp --parents /bin/ls exo1/

# Copy required libraries to chroot
cp -r --parents /lib/terminfo exo1/
cp --parents /lib/x86_64-linux-gnu/libncurses.so.6 exo1/
cp --parents /lib/x86_64-linux-gnu/libtinfo.so.6 exo1/
cp --parents /lib/x86_64-linux-gnu/libc.so.6 exo1/
cp --parents /lib/x86_64-linux-gnu/libselinux.so.1 exo1/
cp --parents /lib/x86_64-linux-gnu/libpcre2-8.so.0 exo1/
cp --parents /lib64/ld-linux-x86-64.so.2 exo1/

echo -e "\e[1;32mOK\e[0m"

# Clean up
echo -e "You may now use the chroot environment as follows:"
echo -e "chroot exo1/ msnake or chroot exo1/ bash"

