#!/bin/bash

# Set colours for Whiptail
export NEWT_COLORS='root=,black
border=green,black
title=red,black
roottext=green,black
window=red,black
textbox=white,black
button=black,green
compactbutton=white,black
listbox=white,black
actlistbox=black,white
actsellistbox=black,green
checkbox=green,black
actcheckbox=black,green
'

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
reset="\033[0m"

echo -e "${yellow}[ INFO ]${reset} This script requires the following dependencies: Git and Whiptail."
echo -e "${yellow}[ INFO ]${reset} It will create .cache, .config and .local folders if not present."

# Check Git installed
function check_git() {
  if command -v git >/dev/null 2>&1; then
    echo -e "${yellow}[ INFO ]${reset} Git already installed."
  else
    sudo apt-get install -y -qq git > /dev/null 2>&1
    echo -e "${green}[ NOTICE ]${reset} Git has been installed."
  fi
}

check_git

# Check Whiptail installed
function check_whiptail() {
  if command -v whiptail >/dev/null 2>&1; then
    echo -e "${yellow}[ INFO ]${reset} Whiptail already installed."
  else
    sudo apt-get install -y -qq whiptail > /dev/null 2>&1
    echo -e "${green}[ NOTICE ]${reset} Whiptail has been installed."
  fi
}

check_whiptail

mkdir -p "$HOME"/.cache "$HOME"/.config "$HOME"/.local/share "$HOME"/.local/state

# Software menu
mapfile -t CHOICES < <(whiptail --separate-output --title "Linux software & dotfiles installer" --backtitle "<Tab> moves; <Space> select; <Enter> continue;" --checklist \
  "Select packages to install" 0 80 10 \
  "bat" "text viewer" ON \
  "duf" "disk usage viewer" ON \
  "fastfetch" "system information" ON \
  "gnupg" "encryption software" OFF \
  "htop" "system monitor" ON \
  "less" "terminal pager" ON \
  "starship" "terminal prompt" ON \
  "vim" "code editor" ON \
  "zsh" "modern shell" ON \
  3>&1 1>&2 2>&3)

install_bat() {
  sudo apt-get install -y -qq bat > /dev/null 2>&1
  cp -R dotfiles/bat "$HOME"/.config
  whiptail --title "Install completed" --msgbox "Bat installed and configuration restored." 10 80
}

install_duf() {
  sudo apt-get install -y -qq duf > /dev/null 2>&1
  whiptail --title "Install completed" --msgbox "Duf installed and configuration restored." 10 80
}

install_fastfetch() {
  sudo apt-get install -y -qq fastfetch > /dev/null 2>&1
  cp -R dotfiles/fastfetch "$HOME"/.config
  if grep -qi "ubuntu" /etc/os-release; then
    sed -i -e 's/5E81AC/D08770/g' "$HOME"/.config/fastfetch/config.jsonc
  else
    sed -i -e 's/5E81AC/BF616A/g' "$HOME"/.config/fastfetch/config.jsonc
  fi
  whiptail --title "Install completed" --msgbox "Fastfetch installed and configuration restored." 10 80
}

install_gnupg() {
  sudo apt-get install -y -qq gnupg > /dev/null 2>&1
  cp -R dotfiles/gnupg "$HOME"/.local/share
  chmod 700 "$HOME/.local/share/gnupg"
  whiptail --title "Install completed" --msgbox "GnuPG installed and configuration restored." 10 80
}

install_htop() {
  sudo apt-get install -y -qq htop > /dev/null 2>&1
  cp -R dotfiles/htop "$HOME"/.config
  whiptail --title "Install completed" --msgbox "Htop installed and configuration restored." 10 80
}

install_less() {
  sudo apt-get install -y -qq less > /dev/null 2>&1
  cp dotfiles/less/lesskey "$HOME"/.config
  whiptail --title "Install completed" --msgbox "Less installed and configuration restored." 10 80
}

install_starship() {
  sudo apt-get install -y -qq starship > /dev/null 2>&1
  cp -R dotfiles/starship "$HOME"/.config
  if grep -qi "ubuntu" /etc/os-release; then
    sed -i -e 's/7A9A63/D08770/g' "$HOME"/.config/starship/starship.toml
  else
    sed -i -e 's/7A9A63/BF616A/g' "$HOME"/.config/starship/starship.toml
  fi
  whiptail --title "Install completed" --msgbox "Starship installed and configuration restored." 10 80
}

install_vim() {
  sudo apt-get install -y -qq vim > /dev/null 2>&1
  cp -R dotfiles/vim "$HOME"/.config &&
  mkdir -p "$HOME"/.config/vim/after "$HOME"/.config/vim/autoload "$HOME"/.config/vim/pack/{hashivim,itchyny,ojroques,preservim,ryanoasis,tpope}/{start,opt} > /dev/null 2>&1
  git clone --quiet https://github.com/hashivim/vim-terraform.git "$HOME"/.config/vim/pack/hashivim/start/vim-terraform > /dev/null 2>&1
  git clone --quiet https://github.com/itchyny/lightline.vim    "$HOME"/.config/vim/pack/itchyny/start/lightline > /dev/null 2>&1
  git clone --quiet https://github.com/ojroques/vim-oscyank.git   "$HOME"/.config/vim/pack/ojroques/start/vim-oscyank > /dev/null 2>&1
  git clone --quiet https://github.com/preservim/nerdtree.git   "$HOME"/.config/vim/pack/preservim/start/nerdtree > /dev/null 2>&1
  git clone --quiet https://github.com/ryanoasis/vim-devicons   "$HOME"/.config/vim/pack/ryanoasis/start/vim-devicons > /dev/null 2>&1
  git clone --quiet https://github.com/tpope/vim-sensible.git   "$HOME"/.config/vim/pack/tpope/start/vim-sensible > /dev/null 2>&1
  whiptail --title "Install completed" --msgbox "Vim installed and configuration restored." 10 80
}

install_zsh() {
  mkdir -p "$HOME"/.cache/zsh "$HOME"/.local/state/zsh
  sudo apt-get install -y -qq zsh > /dev/null 2>&1
  cp dotfiles/dir_colors/dir_colors "$HOME"/.config
  cp -R dotfiles/zsh "$HOME"/.config
  git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git    "$HOME"/.config/zsh/plugins/zsh-autosuggestions > /dev/null 2>&1
  git clone --quiet https://github.com/zsh-users/zsh-completions.git      "$HOME"/.config/zsh/plugins/zsh-completions > /dev/null 2>&1
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git  "$HOME"/.config/zsh/plugins/zsh-syntax-highlighting > /dev/null 2>&1
  ln -s "$HOME"/.config/zsh/.zshenv "$HOME"/.zshenv
  rm "$HOME"/.config/zsh/.zprofile
  sudo chsh -s "$(which zsh)" "$USER" > /dev/null 2>&1
  whiptail --title "Install completed" --msgbox "ZSH installed and configuration restored." 10 80
}

for choice in "${CHOICES[@]}"; do
  case $choice in
    bat)        install_bat ;;
    duf)        install_duf ;;
    fastfetch)  install_fastfetch ;;
    git)        install_git ;;
    gnupg)      install_gnupg ;;
    htop)       install_htop ;;
    less)       install_less ;;
    starship)   install_starship ;;
    vim)        install_vim ;;
    zsh)        install_zsh ;;
    *)          exit ;;
  esac
done

# Post-Install
function post_install() {
  if whiptail --title "Post Install" --yesno "Do you want to run user post install?" 10 80; then
    rm "$HOME"/.bash_logout "$HOME"/.bash_profile "$HOME"/.bashrc "$HOME"/.profile "$HOME"/.zcompdump > /dev/null 2>&1
    touch "$HOME"/.hushlogin
    echo -e "${red}[ NOTICE ]${reset} Post install completed."
  else
    echo -e "${yellow}[ INFO ]${reset} Post install not completed."
  fi
}

post_install

rm -fr dotfiles

# Exit/Reboot
function exit_reboot() {
  if whiptail --title "Exit or Reboot"  --yes-button "Exit" --no-button "Reboot" --yesno "Do you want to exit or reboot?" 10 80; then
    exit
  else
    sudo reboot
  fi
}

exit_reboot
