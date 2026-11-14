# Keep only the first occurrence of each entry
typeset -U path fpath manpath

# Prepended here because macOS /etc/zprofile (path_helper) reorders PATH
# after .zshenv runs, pushing user entries behind the system dirs.
path=(
  $HOME/.local/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /opt/homebrew/opt/coreutils/libexec/gnubin
  /opt/homebrew/opt/curl/bin
  /opt/homebrew/opt/findutils/libexec/gnubin
  /opt/homebrew/opt/gawk/libexec/gnubin
  /opt/homebrew/opt/gnu-sed/libexec/gnubin
  /opt/homebrew/opt/gnu-tar/libexec/gnubin
  /opt/homebrew/opt/gnu-which/libexec/gnubin
  /opt/homebrew/opt/grep/libexec/gnubin
  /opt/homebrew/opt/libpq/bin
  $path
)
# Drop entries that don't exist on this machine (e.g. gawk, or Linux installs)
path=($^path(N-/))

manpath=(
  /opt/homebrew/opt/coreutils/libexec/gnuman
  /opt/homebrew/opt/findutils/libexec/gnuman
  $manpath
)
manpath=($^manpath(N-/))
# Trailing ":" tells man to also search its default system locations
export MANPATH="${(j.:.)manpath}:"

# Homebrew
export HOMEBREW_AUTO_UPDATE_QUIET=TRUE
export HOMEBREW_CACHE="$XDG_CACHE_HOME/homebrew"
export HOMEBREW_CLEANUP_MAX_AGE_DAYS=0
export HOMEBREW_LOGS="$XDG_STATE_HOME/homebrew/logs"
export HOMEBREW_NO_ASK=TRUE
export HOMEBREW_NO_ENV_HINTS=TRUE
export HOMEBREW_NO_UPDATE_REPORT_NEW=TRUE
export HOMEBREW_TEMP="/tmp/homebrew"

export SHELL_SESSIONS_DISABLE=1
