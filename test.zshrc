function mkd () { mkdir -p "$@" && eval cd "\"\$$#\""; }


# Zplug
source ~/.zplug/init.zsh

zplug "zsh-users/zsh-history-substring-search"
zplug "bhilburn/powerlevel9k"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load --verbose
clear
