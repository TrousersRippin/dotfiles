#!/bin/bash

# Set colours for Whiptail
export NEWT_COLORS='root=,black
border=blue,black
title=red,black
roottext=blue,black
window=red,black
textbox=white,black
button=black,blue
compactbutton=white,black
listbox=white,black
actlistbox=black,white
actsellistbox=black,blue
checkbox=blue,black
actcheckbox=black,blue
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
    sudo dnf install -y -q git > /dev/null 2>&1
    echo -e "${green}[ NOTICE ]${reset} Git has been installed."
  fi
}

check_git

# Check Whiptail installed
function check_whiptail() {
  if command -v whiptail >/dev/null 2>&1; then
    echo -e "${yellow}[ INFO ]${reset} Whiptail already installed."
  else
    sudo dnf install -y -q newt > /dev/null 2>&1
    echo -e "${green}[ NOTICE ]${reset} Whiptail has been installed."
  fi
}

check_whiptail

mkdir -p $HOME/.cache $HOME/.config $HOME/.local/share $HOME/.local/state

# Software menu
CHOICES=( $(whiptail --separate-output --title "Linux software & dotfiles installer" --backtitle "<Tab> moves; <Space> select; <Enter> continue;" --checklist \
  "Select packages to install" 0 80 10 \
  "bat" "text viewer" ON \
  "duf" "disk usage viewer" OFF \
  "fastfetch" "system information" ON \
  "gnupg" "encryption software" OFF \
  "htop" "system monitor" ON \
  "less" "terminal pager" ON \
  "starship" "terminal prompt" ON \
  "vim" "code editor" ON \
  "zsh" "modern shell" ON \
  3>&1 1>&2 2>&3) )

install_bat() {
  sudo dnf install -y -q bat > /dev/null 2>&1
  cp -R dotfiles/bat $HOME/.config
  whiptail --title "Install completed" --msgbox "Bat installed and configuration restored." 10 80
}

install_duf() {
  sudo dnf install -y -q duf > /dev/null 2>&1
  cp -R dotfiles/duf $HOME/.config
  whiptail --title "Install completed" --msgbox "Duf installed and configuration restored." 10 80
}

install_fastfetch() {
  sudo dnf install -y -q fastfetch > /dev/null 2>&1
  cp -R dotfiles/fastfetch $HOME/.config
  whiptail --title "Install completed" --msgbox "Fastfetch installed and configuration restored." 10 80
}

install_gnupg() {
  sudo dnf install -y -q gnupg > /dev/null 2>&1
  cp -R dotfiles/gnupg $HOME/.local/share
  chmod 700 "$HOME/.local/share/gnupg"
  whiptail --title "Install completed" --msgbox "GnuPG installed and configuration restored." 10 80
}

install_htop() {
  sudo dnf install -y -q htop > /dev/null 2>&1
  cp -R dotfiles/htop $HOME/.config
  whiptail --title "Install completed" --msgbox "Htop installed and configuration restored." 10 80
}

install_less() {
  sudo dnf install -y -q less > /dev/null 2>&1
  cp dotfiles/less/lesskey $HOME/.config
  whiptail --title "Install completed" --msgbox "Less installed and configuration restored." 10 80
}

install_starship() {
  #curl -sS https://starship.rs/install.sh | sh
  sudo dnf install -y -q starship > /dev/null 2>&1
  cp -R dotfiles/starship/starship.toml $HOME/.config
  if grep -qi '^ID=\("fedora"\|fedora\)' /etc/os-release; then
    sed -i -e 's/7A9A63/5E81AC/g' "$HOME/.config/starship.toml"
  fi
  whiptail --title "Install completed" --msgbox "Starship installed and configuration restored." 10 80
}

install_vim() {
  sudo dnf install -y -q vim > /dev/null 2>&1
  cp -R dotfiles/vim $HOME/.config &&
  mkdir -p $HOME/.config/vim/after $HOME/.config/vim/autoload $HOME/.config/vim/pack/{hashivim,itchyny,junegunn,ojroques,preservim,ryanoasis,tpope}/{start,opt} > /dev/null 2>&1
  git clone --quiet https://github.com/hashivim/vim-terraform.git $HOME/.config/vim/pack/hashivim/start/vim-terraform > /dev/null 2>&1
  git clone --quiet https://github.com/itchyny/lightline.vim    $HOME/.config/vim/pack/itchyny/start/lightline > /dev/null 2>&1
  git clone --quiet https://github.com/junegunn/fzf.git       $HOME/.config/vim/pack/junegunn/start/fzf > /dev/null 2>&1
  git clone --quiet https://github.com/junegunn/fzf.vim.git     $HOME/.config/vim/pack/junegunn/start/fzf.vim > /dev/null 2>&1
  git clone --quiet https://github.com/ojroques/vim-oscyank.git   $HOME/.config/vim/pack/ojroques/start/vim-oscyank > /dev/null 2>&1
  git clone --quiet https://github.com/preservim/nerdtree.git   $HOME/.config/vim/pack/preservim/start/nerdtree > /dev/null 2>&1
  git clone --quiet https://github.com/ryanoasis/vim-devicons   $HOME/.config/vim/pack/ryanoasis/start/vim-devicons > /dev/null 2>&1
  git clone --quiet https://github.com/tpope/vim-sensible.git   $HOME/.config/vim/pack/tpope/start/vim-sensible > /dev/null 2>&1
  whiptail --title "Install completed" --msgbox "Vim installed and configuration restored." 10 80
}

install_zsh() {
  mkdir -p $HOME/.cache/zsh $HOME/.local/state/zsh
  sudo dnf install -y -q zsh > /dev/null 2>&1
  cp dotfiles/dir_colors/dir_colors $HOME/.config
  cp -R dotfiles/zsh $HOME/.config
  git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git    $HOME/.config/zsh/plugins/zsh-autosuggestions > /dev/null 2>&1
  git clone --quiet https://github.com/zsh-users/zsh-completions.git      $HOME/.config/zsh/plugins/zsh-completions > /dev/null 2>&1
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git  $HOME/.config/zsh/plugins/zsh-syntax-highlighting > /dev/null 2>&1
  ln -s $HOME/.config/zsh/.zshenv $HOME/.zshenv
  rm $HOME/.config/zsh/.zprofile
  sudo chsh -s $(which zsh) $USER > /dev/null 2>&1
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
    rm $HOME/.bash_logout $HOME/.bash_profile $HOME/.bashrc $HOME/.profile> /dev/null 2>&1
    touch $HOME/.hushlogin
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
