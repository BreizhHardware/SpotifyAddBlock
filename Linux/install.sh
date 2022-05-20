#!/bin/bash

detect_distro() {
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

detect_distro

state="$(head -n 1 .state)"

if [ "$EUID" -ne 0 ]
then
	echo "Please run as superuser"
	exit
fi

if [ "$state" == "$SUDO_USER $HOSTNAME 1" ]
then
	echo "Service already installed, press any key to update it or ctrl-c to avoid installation"    
	read cap
	echo "Service up to date!"
	cp .hosts_original_${OS}.txt /etc/hosts
else
	echo "Service is going to be installed, press any key to continue or ctrl-c to avoid installation"   
	read cap
	echo "Service installed!"
	echo "$SUDO_USER $HOSTNAME 1" > .state
	cp /etc/hosts .hosts_original_${OS}.txt
fi


cat .hosts >> /etc/hosts
