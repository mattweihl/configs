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
function nonzero_return() {
    RETVAL=$?
    [ $RETVAL -ne 0 ] && echo "$RETVAL"
}

export PS1="\[\e[31m\]\`nonzero_return\`\[\e[m\][\[\e[35m\]\@\[\e[m\]] \[\e[32m\]\u\[\e[m\]@\[\e[33m\]\h\[\e[m\]:\[\e[34m\]\W\[\e[m\]\\n↳ "
#PROMPT_COMMAND='echo -en "\033]0; $("pwd") \a"'
PROMPT_COMMAND='echo -en "\033]0;$(whoami)@$(hostname)|$(pwd|cut -d "/" -f 4-100)\a"'

