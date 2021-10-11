# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias c='cd ~/code'
alias gs='git status'
alias dt="cd /mnt/c/Users/mattw/Desktop"

# Exports
export EDITOR="vim"
export LS_COLORS='ow=01;36;40'

# Source PS1 variable
source "$HOME/Dropbox/.config/.mkps1.sh"
PS1="$(__mkps1)"