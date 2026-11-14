if [[ "$TERM" == "linux" ]] || [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
  PROMPT='%F{white}%n%f@%F{yellow}%m%f %F{white}%1~%f %# '
else
  eval "$(starship init zsh)"
fi
