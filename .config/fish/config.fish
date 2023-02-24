if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

alias vim nvim

source $HOME/.config/fish/config.(whoami).fish

set -gx LAV_PRECOMMIT true
set -gx AWS_REGION 'us-east-1'
set -gx PATH "$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"
set PATH $HOME/.cargo/bin /opt/homebrew/bin $PATH


set -gx NVM_DIR "$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
