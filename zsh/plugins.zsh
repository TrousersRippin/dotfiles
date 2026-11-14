_plugins="$XDG_CONFIG_HOME/zsh/plugins"

source "$_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# zsh-completions is added to fpath in .zshrc, before compinit
source "$_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"   # keep last

unset _plugins
