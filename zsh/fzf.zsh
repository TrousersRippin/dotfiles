# Skip everything if fzf isn't installed (e.g. a fresh server)
(( $+commands[fzf] )) || return 0

export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border
  --color=fg:#D8DEE9,bg:-1,hl:#88C0D0
  --color=fg+:#ECEFF4,bg+:#3B4252,hl+:#8FBCBB,gutter:-1
  --color=info:#EBCB8B,prompt:#81A1C1,pointer:#BF616A,marker:#A3BE8C
  --color=spinner:#B48EAD,header:#5E81AC,border:#4C566A,query:#ECEFF4'

# Ubuntu/Debian install fd as "fdfind" and bat as "batcat"
_fd= _bat=
(( $+commands[fd] )) && _fd=fd || { (( $+commands[fdfind] )) && _fd=fdfind }
(( $+commands[bat] )) && _bat=bat || { (( $+commands[batcat] )) && _bat=batcat }

# Without fd, fzf falls back to its own built-in file walker
if [[ -n $_fd ]]; then
  export FZF_DEFAULT_COMMAND="$_fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_fd --type d --hidden --follow --exclude .git"
  eval "_fzf_compgen_path() { $_fd --hidden --follow --exclude .git . \"\$1\" }"
  eval "_fzf_compgen_dir() { $_fd --type d --hidden --follow --exclude .git . \"\$1\" }"
fi

if [[ -n $_bat ]]; then
  export FZF_CTRL_T_OPTS="--preview '$_bat --color=always --theme=Nord --style=numbers --line-range=:200 {}'"
else
  export FZF_CTRL_T_OPTS="--preview 'head -200 {}'"
fi

if (( $+commands[tree] )); then
  export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
else
  export FZF_ALT_C_OPTS="--preview 'ls -la --color=always {}'"
fi

unset _fd _bat
source <(fzf --zsh)
