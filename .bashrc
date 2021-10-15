alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias c='cd ~/code'
alias gs='git status'
alias dt="cd /mnt/c/Users/mattw/Desktop"

export EDITOR="vim"
export LS_COLORS='di=0;35:'

function nonzero_return() {
    RETVAL=$?
    [ $RETVAL -ne 0 ] && echo "$RETVAL"
}

export PS1="\[\e[31m\]\`nonzero_return\`\[\e[m\][\[\e[35m\]\@\[\e[m\]] \[\e[32m\]\u\[\e[m\]@\[\e[33m\]\h\[\e[m\]:\[\e[15m\]\W\[\e[m\]\\n↳ "
PROMPT_COMMAND='echo -en "\033]0; $("pwd") \a"'


# Disable Ctrl-S suspend
stty -ixon
