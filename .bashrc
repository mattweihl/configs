alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias l="ll"
alias c='cd $CODE_LOCATION'
alias gs='git status'
alias dt="cd $DESKTOP" 
alias db="cd ~/Dropbox"

export EDITOR="nvim"
export LS_COLORS='ow=01;36;40'

if command -v oh-my-posh &> /dev/null
then
    eval "$(oh-my-posh init bash --config $HOME/configs/oh-my-posh-themes/gruvbox.omp.json)"
fi

if command -v nvim &> /dev/null
then 
    alias vim="nvim"
    alias vi="nvim"
fi

