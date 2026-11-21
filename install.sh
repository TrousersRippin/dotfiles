#!/bin/bash
# Linux software & dotfiles installer for Debian/Ubuntu and RHEL/CentOS/Fedora

# Use the repo this script lives in, wherever it is run from
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
reset="\033[0m"

info()   { echo -e "${yellow}[ INFO ]${reset} $*"; }
notice() { echo -e "${green}[ NOTICE ]${reset} $*"; }
error()  { echo -e "${red}[ ERROR ]${reset} $*"; }

# --- Distribution -----------------------------------------------------------
# shellcheck source=/dev/null
. /etc/os-release
case " ${ID} ${ID_LIKE:-} " in
  *" debian "*|*" ubuntu "*)         FAMILY=debian; ACCENT=brown ;;
  *" rhel "*|*" fedora "*|*" centos "*) FAMILY=rhel;   ACCENT=blue ;;
  *) error "Unsupported distribution: ${ID}"; exit 1 ;;
esac

# Set colours for Whiptail
export NEWT_COLORS="root=,black
border=${ACCENT},black
title=red,black
roottext=${ACCENT},black
window=red,black
textbox=white,black
button=black,${ACCENT}
compactbutton=white,black
listbox=white,black
actlistbox=black,white
actsellistbox=black,${ACCENT}
checkbox=${ACCENT},black
actcheckbox=black,${ACCENT}
"

# --- Helpers ----------------------------------------------------------------
# Command output goes to a log; failures are summarised at the end
LOG="${HOME}/.local/state/install/install.log"
mkdir -p "${LOG%/*}"
printf '\n===== install %s =====\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG}"
FAILED=()

run() {
  printf '\n$ %s\n' "$*" >> "${LOG}"
  "$@" >> "${LOG}" 2>&1
  local rc=$?
  if (( rc != 0 )); then
    printf '[ FAILED: exit %s ]\n' "${rc}" >> "${LOG}"
    FAILED+=("$*")
  fi
  return "${rc}"
}

pkg_install() {
  if [[ "${FAMILY}" == debian ]]; then
    run sudo apt-get install -y -qq "$@"
  else
    run sudo dnf install -y -q "$@"
  fi
}

# Clone a repo unless it is already there, so re-runs don't log errors
clone() {
  [[ -d "$2" ]] && return 0
  run git clone --quiet --depth 1 "$1" "$2"
}

# --- Requirements -----------------------------------------------------------
info "This script requires the following dependencies: Git and Whiptail."
info "It will create .cache, .config and .local folders if not present."
info "Command output is logged to ${LOG}"

if [[ "${FAMILY}" == debian ]]; then
  run sudo apt-get update -qq
fi

if command -v git >/dev/null 2>&1; then
  info "Git already installed."
elif pkg_install git; then
  notice "Git has been installed."
else
  error "Git could not be installed. See ${LOG}"; exit 1
fi

if command -v whiptail >/dev/null 2>&1; then
  info "Whiptail already installed."
elif pkg_install "$([[ "${FAMILY}" == debian ]] && echo whiptail || echo newt)"; then
  notice "Whiptail has been installed."
else
  error "Whiptail could not be installed. See ${LOG}"; exit 1
fi

mkdir -p "${HOME}"/.cache "${HOME}"/.config "${HOME}"/.local/share "${HOME}"/.local/state

# --- Software menu ----------------------------------------------------------
if ! CHOICES_RAW=$(whiptail --separate-output --title "Linux software & dotfiles installer" --backtitle "<Tab> moves; <Space> select; <Enter> continue;" --checklist \
  "Select packages to install" 0 80 10 \
  "bat" "text viewer" ON \
  "duf" "disk usage viewer" ON \
  "fastfetch" "system information" ON \
  "fzf" "interactive filter" ON \
  "htop" "system monitor" ON \
  "less" "terminal pager" ON \
  "starship" "terminal prompt" ON \
  "vim" "code editor" ON \
  "zsh" "modern shell" ON \
  3>&1 1>&2 2>&3); then
  info "Cancelled, nothing installed."
  exit 0
fi
mapfile -t CHOICES <<< "${CHOICES_RAW}"

# --- Installers (return non-zero if the package failed) ---------------------
install_bat() {
  pkg_install bat || return 1
  cp -R "${DOTFILES}"/bat "${HOME}"/.config/
}

install_duf() {
  pkg_install duf
}

install_fastfetch() {
  pkg_install fastfetch || return 1
  cp -R "${DOTFILES}"/fastfetch "${HOME}"/.config/
}

install_fzf() {
  pkg_install fzf
}

install_htop() {
  pkg_install htop || return 1
  cp -R "${DOTFILES}"/htop "${HOME}"/.config/
}

install_less() {
  pkg_install less || return 1
  cp "${DOTFILES}"/less/lesskey "${HOME}"/.config/
}

install_starship() {
  pkg_install starship || return 1
  cp -R "${DOTFILES}"/starship "${HOME}"/.config/
  local palette=""
  case "${ID}" in
    ubuntu) palette=orange ;;
    debian) palette=red ;;
    fedora) palette=blue ;;
    *) ;;
  esac
  if [[ -n "${palette}" ]]; then
    sed -i -e "s/^palette = .*/palette = \"${palette}\"/" "${HOME}"/.config/starship/starship.toml
  fi
}

install_vim() {
  pkg_install vim || return 1
  cp -R "${DOTFILES}"/vim "${HOME}"/.config/
  mkdir -p "${HOME}"/.config/vim/after "${HOME}"/.config/vim/autoload
  clone https://github.com/hashivim/vim-terraform.git "${HOME}"/.config/vim/pack/hashivim/start/vim-terraform
  clone https://github.com/itchyny/lightline.vim      "${HOME}"/.config/vim/pack/itchyny/start/lightline
  clone https://github.com/junegunn/fzf.vim.git       "${HOME}"/.config/vim/pack/junegunn/start/fzf.vim
  clone https://github.com/ojroques/vim-oscyank.git   "${HOME}"/.config/vim/pack/ojroques/start/vim-oscyank
}

ZSH_OK=0
install_zsh() {
  pkg_install zsh || return 1
  mkdir -p "${HOME}"/.cache/zsh "${HOME}"/.local/state/zsh
  cp "${DOTFILES}"/dir_colors/dir_colors "${HOME}"/.config/
  cp -R "${DOTFILES}"/zsh "${HOME}"/.config/
  # .zprofile only holds macOS Homebrew paths
  rm -f "${HOME}"/.config/zsh/.zprofile
  clone https://github.com/zsh-users/zsh-autosuggestions.git      "${HOME}"/.config/zsh/plugins/zsh-autosuggestions
  clone https://github.com/zsh-users/zsh-completions.git          "${HOME}"/.config/zsh/plugins/zsh-completions
  clone https://github.com/zsh-users/zsh-syntax-highlighting.git  "${HOME}"/.config/zsh/plugins/zsh-syntax-highlighting
  ln -sf "${HOME}"/.config/zsh/.zshenv "${HOME}"/.zshenv
  run sudo chsh -s "$(command -v zsh)" "${USER}" || return 1
  ZSH_OK=1
}

INSTALLED=()
NOT_INSTALLED=()
for choice in "${CHOICES[@]}"; do
  case "${choice}" in
    bat|duf|fastfetch|fzf|htop|less|starship|vim|zsh)
      info "Installing ${choice}..."
      if "install_${choice}"; then
        INSTALLED+=("${choice}")
      else
        NOT_INSTALLED+=("${choice}")
      fi
      ;;
    "") ;;
    *) error "Unknown choice: ${choice}" ;;
  esac
done

summary="Installed and configured: ${INSTALLED[*]:-none}"
if (( ${#NOT_INSTALLED[@]} )); then
  summary+="\n\nFailed (not in the ${ID} repositories?): ${NOT_INSTALLED[*]}\n\nDetails in ${LOG}"
fi
whiptail --title "Install summary" --msgbox "$(echo -e "${summary}")" 16 80

# --- Post-install -----------------------------------------------------------
# Only remove the bash dotfiles once zsh is installed and is the login shell
if (( ZSH_OK )); then
  if whiptail --title "Post Install" --yesno "Remove bash dotfiles (.bashrc, .profile, ...) and silence the login message?" 10 80; then
    rm -f "${HOME}"/.bash_logout "${HOME}"/.bash_profile "${HOME}"/.bashrc "${HOME}"/.profile "${HOME}"/.zcompdump
    touch "${HOME}"/.hushlogin
    notice "Post install completed."
  else
    info "Post install skipped."
  fi
else
  info "zsh is not the login shell, so the bash dotfiles were kept."
fi

if (( ${#FAILED[@]} )); then
  error "${#FAILED[@]} command(s) failed. Details in ${LOG}:"
  printf '  - %s\n' "${FAILED[@]}"
fi

# --- Clean up ---------------------------------------------------------------
# Configs are copied, not linked, so the clone isn't needed afterwards.
# Only delete a directory that is really this repo, never $HOME itself
if [[ -d "${DOTFILES}/.git" && -f "${DOTFILES}/install.sh" && "${DOTFILES}" != "${HOME}" ]]; then
  rm -rf "${DOTFILES}"
  notice "Removed ${DOTFILES}"
fi

# --- Exit/Reboot ------------------------------------------------------------
if whiptail --title "Exit or Reboot" --yes-button "Exit" --no-button "Reboot" --yesno "Do you want to exit or reboot?" 10 80; then
  exit 0
else
  sudo reboot
fi
