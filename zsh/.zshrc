# Path to your oh-my-zsh installation.
export ZSH="/Users/drakebott/.oh-my-zsh"
export EDITOR=vim
ZSH_THEME="agnoster"
function mkd () { mkdir -p "$@" && eval cd "\"\$$#\""; }

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(
  git
  vi-mode
)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
export EDITOR='vim'

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Example aliases
alias vim="nvim"
alias python='python3'
alias ssh='kitty +kitten ssh'

eval "$(rbenv init -)"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# added by travis gem
[ -f /Users/drakebott/.travis/travis.sh ] && source /Users/drakebott/.travis/travis.sh
