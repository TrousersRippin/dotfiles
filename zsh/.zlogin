# The bash session install.sh was run from saves ~/.bash_history when it exits
# (often at the reboot), after the script has cleaned up; zsh doesn't use it
rm -f "$HOME/.bash_history"

if [[ -o interactive ]] && [[ -t 1 ]]; then
    clear
fi
