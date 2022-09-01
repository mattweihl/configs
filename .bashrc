alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias l="ll"
alias c='cd $CODE_LOCATION'
alias gs='git status'
alias dt="cd $DESKTOP" 
alias db="cd ~/Dropbox"

export EDITOR="vim"
export LS_COLORS='ow=01;36;40'

eval "$(oh-my-posh init bash --config $HOME/configs/oh-my-posh-themes/stelbent-compact.minimal.omp.json)"
