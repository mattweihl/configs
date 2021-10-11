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
#source "$HOME/Dropbox/.config/.mkps1.sh"
#PS1="$(__mkps1)"

if [ "`id -u`" -eq 0 ]; then
    PS1="\[\033[m\]|\[\033[1;35m\]\t\[\033[m\]|\[\e[1;31m\]\u\[\e[1;36m\]\[\033[m\]@\[\e[1;36m\]\h\[\033[m\]:\[\e[0m\]\[\e[1;32m\][\W]> \[\e[0m\]"
else
    PS1="\[\033[m\]|\[\033[1;35m\]\t\[\033[m\]|\[\e[1m\]\u\[\e[1;36m\]\[\033[m\]@\[\e[1;36m\]\h\[\033[m\]:\[\e[0m\]\[\e[1;32m\][\W]> \[\e[0m\]"
fi


