# Clear the screen on interactive login
if [[ -o interactive ]] && [[ -t 1 ]]; then
    clear
fi
