
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias c='cd $CODE_LOCATION'
alias gs='git status'
alias dt="cd $DESKTOP" 

export EDITOR="vim"
export LS_COLORS='ow=01;36;40'

eval "$(oh-my-posh init bash --config $HOME/Dropbox/.config/oh-my-posh-themes/xtoys.omp.json)"
