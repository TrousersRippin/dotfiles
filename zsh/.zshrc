test -r "$XDG_CONFIG_HOME/dir_colors" && eval "$(dircolors "$XDG_CONFIG_HOME/dir_colors")"

if [[ "$TERM" == "linux" ]]; then
  echo -en "\e]P0000000" # black
  echo -en "\e]P9BF616A" # red
  echo -en "\e]PAA3BE8C" # green
  echo -en "\e]PBEBCB8B" # yellow
  echo -en "\e]PC5E81AC" # blue
  echo -en "\e]PD81A1C1" # magenta
  echo -en "\e]PE8FBCBB" # cyan
  echo -en "\e]PFE5E9F0" # white
fi

bindkey -v
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^W' backward-kill-word
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^[f' forward-word
bindkey '^[b' backward-word

autoload -U zmv
alias zmv='noglob zmv -W'

setopt auto_cd auto_pushd
setopt auto_list auto_menu menu_complete
setopt complete_in_word
setopt correct
setopt extended_glob
setopt interactive_comments
setopt always_to_end
setopt bang_hist
setopt notify
setopt no_beep
setopt no_case_glob

HISTSIZE=200
SAVEHIST="$HISTSIZE"
HISTFILE="${XDG_STATE_HOME}/zsh/history"
setopt append_history inc_append_history
setopt hist_expire_dups_first hist_find_no_dups hist_ignore_dups
setopt hist_ignore_all_dups hist_ignore_space
setopt hist_reduce_blanks hist_save_no_dups hist_verify

autoload -Uz compinit

zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{cyan} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' rehash true

compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

source "$ZDOTDIR/aliases"
source "$XDG_CONFIG_HOME/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$XDG_CONFIG_HOME/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh"
source "$XDG_CONFIG_HOME/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ "$TERM" == "linux" ]] || [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    source $ZDOTDIR/.zshrc-console
else
    eval "$(starship init zsh)"
fi
