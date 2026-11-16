# My Dotfiles

This repository contains the dotfiles for my terminal environment and scripts to install the software.

# Requirements

Ensure you have sudo permissions on your system. The install script will install Git, Whiptail and any other software it needs.

# Installation

Clone the repository and run the install script. It works on Debian/Ubuntu and RHEL/CentOS/Fedora and can be run from any directory.

```bash
git clone --quiet https://github.com/TrousersRippin/dotfiles.git
./dotfiles/install.sh
```

Command output is logged to `~/.local/state/install/install.log`, and any packages that failed to install are listed at the end.
