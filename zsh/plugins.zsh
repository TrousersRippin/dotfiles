_plugins="$XDG_CONFIG_HOME/zsh/plugins"

for _p in zsh-autosuggestions zsh-syntax-highlighting; do
  [[ -r "$_plugins/$_p/$_p.zsh" ]] && source "$_plugins/$_p/$_p.zsh"
done

unset _plugins _p
