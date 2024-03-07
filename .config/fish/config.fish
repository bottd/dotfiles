if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

alias vim nvim

source $HOME/.config/fish/config.(whoami).fish

# Add cargo to path
set PATH $HOME/.cargo/bin /opt/homebrew/bin $PATH

# eval $(github-copilot-cli alias -- /opt/homebrew/bin/fish)
# bass eval "$(github-copilot-cli alias -- "$0")"

function nvm
   bass source $HOME/.nvm/nvm.sh --no-use ';' nvm $argv
end
# nvm use default

alias gitroot="cd (git rev-parse --show-toplevel)"

set -gx VOLTA_HOME "$HOME/.volta"
set -gx PATH "$VOLTA_HOME/bin" $PATH
