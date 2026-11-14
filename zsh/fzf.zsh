export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border
  --color=fg:#D8DEE9,bg:-1,hl:#88C0D0
  --color=fg+:#ECEFF4,bg+:#3B4252,hl+:#8FBCBB,gutter:-1
  --color=info:#EBCB8B,prompt:#81A1C1,pointer:#BF616A,marker:#A3BE8C
  --color=spinner:#B48EAD,header:#5E81AC,border:#4C566A,query:#ECEFF4'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --theme=Nord --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
_fzf_compgen_path() { fd --hidden --follow --exclude .git . "$1" }
_fzf_compgen_dir() { fd --type d --hidden --follow --exclude .git . "$1" }

source <(fzf --zsh)
