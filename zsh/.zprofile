path=(
  /opt/homebrew/bin
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

manpath=(
  /opt/homebrew/opt/coreutils/libexec/gnuman
  /opt/homebrew/opt/findutils/libexec/gnuman
  $manpath
)

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
