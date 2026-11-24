#!/bin/bash
# Linux software & dotfiles installer for Debian/Ubuntu and RHEL/CentOS/Fedora
# The install_* functions are called indirectly as "install_${choice}"
# shellcheck disable=SC2329

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

# --- Installers -------------------------------------------------------------
# Return 0 on success, 1 if the package didn't install, 2 if the package
# installed but a setup step (config copy, plugin clone, chsh) failed.
# Setup steps all go through run, so failures are logged and listed.
install_bat() {
  pkg_install bat || return 1
  run cp -R "${DOTFILES}"/bat "${HOME}"/.config/ || return 2
}

install_duf() {
  pkg_install duf || return 1
}

install_fastfetch() {
  pkg_install fastfetch || return 1
  run cp -R "${DOTFILES}"/fastfetch "${HOME}"/.config/ || return 2
}

install_fzf() {
  pkg_install fzf || return 1
}

install_htop() {
  pkg_install htop || return 1
  run cp -R "${DOTFILES}"/htop "${HOME}"/.config/ || return 2
}

install_less() {
  pkg_install less || return 1
  run cp "${DOTFILES}"/less/lesskey "${HOME}"/.config/ || return 2
}

install_starship() {
  pkg_install starship || return 1
  run cp -R "${DOTFILES}"/starship "${HOME}"/.config/ || return 2
  local palette=""
  case "${ID}" in
    ubuntu) palette=orange ;;
    debian) palette=red ;;
    fedora) palette=blue ;;
    *) ;;
  esac
  if [[ -n "${palette}" ]]; then
    run sed -i -e "s/^palette = .*/palette = \"${palette}\"/" "${HOME}"/.config/starship/starship.toml || return 2
  fi
}

# Plugin steps keep going after a failure, so one bad clone doesn't skip the rest
install_vim() {
  pkg_install vim || return 1
  local rc=0
  run cp -R "${DOTFILES}"/vim "${HOME}"/.config/ || rc=2
  run mkdir -p "${HOME}"/.config/vim/after "${HOME}"/.config/vim/autoload || rc=2
  clone https://github.com/hashivim/vim-terraform.git "${HOME}"/.config/vim/pack/hashivim/start/vim-terraform || rc=2
  clone https://github.com/itchyny/lightline.vim      "${HOME}"/.config/vim/pack/itchyny/start/lightline     || rc=2
  clone https://github.com/junegunn/fzf.vim.git       "${HOME}"/.config/vim/pack/junegunn/start/fzf.vim      || rc=2
  clone https://github.com/ojroques/vim-oscyank.git   "${HOME}"/.config/vim/pack/ojroques/start/vim-oscyank  || rc=2
  return "${rc}"
}

# ZSH_OK means zsh is the login shell, so the bash dotfiles can go
ZSH_OK=0
install_zsh() {
  pkg_install zsh || return 1
  local rc=0
  run mkdir -p "${HOME}"/.cache/zsh "${HOME}"/.local/state/zsh || rc=2
  run cp "${DOTFILES}"/dir_colors/dir_colors "${HOME}"/.config/ || rc=2
  run cp -R "${DOTFILES}"/zsh "${HOME}"/.config/ || rc=2
  # .zprofile only holds macOS Homebrew paths
  run rm -f "${HOME}"/.config/zsh/.zprofile || rc=2
  clone https://github.com/zsh-users/zsh-autosuggestions.git      "${HOME}"/.config/zsh/plugins/zsh-autosuggestions     || rc=2
  clone https://github.com/zsh-users/zsh-completions.git          "${HOME}"/.config/zsh/plugins/zsh-completions         || rc=2
  clone https://github.com/zsh-users/zsh-syntax-highlighting.git  "${HOME}"/.config/zsh/plugins/zsh-syntax-highlighting || rc=2
  run ln -sf "${HOME}"/.config/zsh/.zshenv "${HOME}"/.zshenv || rc=2
  if run sudo chsh -s "$(command -v zsh)" "${USER}"; then
    ZSH_OK=1
  else
    rc=2
  fi
  return "${rc}"
}

INSTALLED=()
NOT_INSTALLED=()
SETUP_FAILED=()
for choice in "${CHOICES[@]}"; do
  case "${choice}" in
    bat|duf|fastfetch|fzf|htop|less|starship|vim|zsh)
      info "Installing ${choice}..."
      if "install_${choice}"; then rc=0; else rc=$?; fi
      case ${rc} in
        0) INSTALLED+=("${choice}") ;;
        1) NOT_INSTALLED+=("${choice}") ;;
        *) SETUP_FAILED+=("${choice}") ;;
      esac
      ;;
    "") ;;
    *) error "Unknown choice: ${choice}" ;;
  esac
done

# --- Summary ----------------------------------------------------------------
# A heading per result, with bullets: packages three to a line, commands one
# per line. A 24-row terminal only fits ~16 lines of text, and every line is
# kept short enough not to wrap, so the box height can be worked out exactly
summary=""
short() {
  local s=${1//"${HOME}"/\~}
  (( ${#s} > 70 )) && s="${s:0:67}..."
  printf '%s' "${s}"
}
# $1 = items per line, $2 = heading, rest = items
add_section() {
  local per_line=$1 heading=$2 i line=""; shift 2
  (( $# )) || return 0
  [[ -n "${summary}" ]] && summary+=$'\n'
  summary+="${heading}"$'\n'
  for (( i = 1; i <= $#; i++ )); do
    if (( per_line > 1 )); then
      line+=$(printf '  - %-18s' "${!i}")
    else
      line="  - $(short "${!i}")"
    fi
    if (( i % per_line == 0 || i == $# )); then
      summary+="${line%"${line##*[! ]}"}"$'\n'
      line=""
    fi
  done
}
add_section 3 "Installed and configured:" "${INSTALLED[@]}"
add_section 3 "Not installed (not in the ${ID} repositories?):" "${NOT_INSTALLED[@]}"
add_section 3 "Installed, but setup failed:" "${SETUP_FAILED[@]}"
add_section 1 "Failed commands:" "${FAILED[@]}"
if (( ${#FAILED[@]} )); then
  summary+=$'\n'"Details in $(short "${LOG}")"
fi
[[ -n "${summary}" ]] || summary="Nothing was installed."
summary=${summary%$'\n'}

# Box = text lines + borders and button, capped to the terminal height. Only
# scroll when capped: --scrolltext draws a scroll arrow even when it all fits
box_height=$(( $(wc -l <<< "${summary}") + 7 ))
max_height=$(( $(tput lines 2>/dev/null || echo 24) - 2 ))
scroll=()
if (( box_height > max_height )); then
  box_height=${max_height}
  scroll=(--scrolltext)
fi
whiptail --title "Install Summary" "${scroll[@]}" --msgbox "${summary}" "${box_height}" 80

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

# --- Clean up ---------------------------------------------------------------
# Configs are copied, not linked, so the clone isn't needed afterwards. Only
# offer to delete it when everything worked (otherwise it's needed to fix and
# re-run), only if it's really this repo, never $HOME itself, and only on Yes
if (( ${#FAILED[@]} || ${#NOT_INSTALLED[@]} || ${#SETUP_FAILED[@]} )); then
  info "Kept ${DOTFILES} so you can fix the failures and re-run."
elif [[ -d "${DOTFILES}/.git" && -f "${DOTFILES}/install.sh" && "${DOTFILES}" != "${HOME}" ]]; then
  if whiptail --title "Clean Up" --defaultno --yesno "Delete the dotfiles repo at ${DOTFILES}?"$'\n\n'"Any uncommitted changes in it will be lost." 10 80; then
    rm -rf "${DOTFILES}"
    notice "Removed ${DOTFILES}"
  else
    info "Kept ${DOTFILES}"
  fi
fi

# --- Exit/Reboot ------------------------------------------------------------
# whiptail returns 0 for Exit, 1 for Reboot and 255 for Esc; only reboot when
# Reboot was actually chosen
whiptail --title "Exit or Reboot" --yes-button "Exit" --no-button "Reboot" --yesno "Do you want to exit or reboot?" 10 80
if (( $? == 1 )); then
  sudo reboot
fi

# The dialogs cover terminal output, so list failures again on the way out
if (( ${#FAILED[@]} )); then
  error "${#FAILED[@]} command(s) failed. Details in ${LOG}:"
  printf '  - %s\n' "${FAILED[@]}"
fi
exit 0
