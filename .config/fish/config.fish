if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source
alias vim nvim

set -gx LAV_PRECOMMIT true
set -gx AWS_REGION 'us-east-1'
set -gx PATH "$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"
set PATH $HOME/.cargo/bin /opt/homebrew/bin $PATH


set -gx NVM_DIR "$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
set -gx JIRA_API_TOKEN "ATATT3xFfGF0pRvLs_VdMLq_HnTuvOx2KNWzd9tiCsbtb3oBcsFoi4258xEL4h85A_g0J_kK01ObiokiARkz7WjNEgJD3qVyl3mcwST6KBgI1fAwPoO3rmx3qW7oZyRN9LBFt8kgze50DG92KbBLKI-YVIEQSid_hYOGuO0QTpxahQXJPRY0kcw=A16C1000"
