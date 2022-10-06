source $HOME/configs/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Alias
alias ll='ls -alFh --color=auto'
alias la='ls -A --color=auto'
alias l="ll"
alias c='cd $CODE_LOCATION'
alias gs='git status'
alias dt="cd $DESKTOP"
alias db="cd ~/Dropbox"

# Alias neovim as vi and vim, if present
if command -v nvim &> /dev/null
then
    alias vim="nvim"
    alias vi="nvim"
fi

# Variables
export EDITOR="nvim"
export LS_COLORS='ow=01;36;40'

if which starship >/dev/null; then
    eval "$(starship init zsh)"
fi

