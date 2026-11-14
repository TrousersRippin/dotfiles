# --- Colors -----------------------------------------------------------------
test -r "$XDG_CONFIG_HOME/dir_colors" && eval "$(dircolors -b "$XDG_CONFIG_HOME/dir_colors")"

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

# --- Keybindings ------------------------------------------------------------
bindkey -v
KEYTIMEOUT=1   # 10ms Esc delay in vi mode (default 40 = 0.4s)
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^W' backward-kill-word
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^[f' forward-word
bindkey '^[b' backward-word

# --- Options ----------------------------------------------------------------
autoload -U zmv
alias zmv='noglob zmv -W'

setopt auto_cd auto_pushd
setopt auto_list auto_menu
setopt complete_in_word
setopt correct
setopt extended_glob
setopt interactive_comments
setopt always_to_end
setopt bang_hist
setopt notify
setopt no_beep
setopt no_case_glob

# --- History ----------------------------------------------------------------
HISTSIZE=200
SAVEHIST="$HISTSIZE"
HISTFILE="${XDG_STATE_HOME}/zsh/history"
setopt inc_append_history
setopt hist_find_no_dups hist_ignore_all_dups hist_ignore_space
setopt hist_reduce_blanks hist_save_no_dups hist_verify

# --- Completion -------------------------------------------------------------
# zsh-completions must be on fpath before compinit runs
# /bin/zsh doesn't include Homebrew's completions dir; (N-/) skips it if absent (Linux)
fpath=(
  "$XDG_CONFIG_HOME/zsh/plugins/zsh-completions/src"
  /opt/homebrew/share/zsh/site-functions(N-/)
  $fpath
)

# Prefer zsh's built-in _git over Homebrew's bash-based wrapper
# (system dirs come last in fpath, so [-1] picks zsh's own copy)
autoload -Uz $^fpath/_git(N[-1])

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
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' rehash true

compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# --- Modules ----------------------------------------------------------------
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/prompt.zsh"
source "$ZDOTDIR/plugins.zsh"
