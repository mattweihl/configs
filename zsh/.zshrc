export LS_COLORS=gxBxhxDxfxhxhxhxhxcxcx

setopt PROMPT_SUBST
export PROMPT='%F{green}%t%f %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

alias ll="ls -alFh --color=auto"
alias la="ls -A --color=auto"
alias l="ll"
alias c="cd $CODE_LOCATION"
alias gs="git status"
alias gb='git branch'
alias dt="cd $DESKTOP"
alias configs="cd $HOME/configs"

export EDITOR='vim'

#if command -v lvim &> /dev/null
#then
#    alias vim="lvim"
#    export EDITOR="lvim"
#fi

if command -v fzf &> /dev/null
then
    source <(fzf --zsh)
fi

if command -v nvim &> /dev/null
then
    alias vim="nvim"
    export EDITOR="nvim"
fi

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^e' edit-command-line

autoload -U select-word-style
select-word-style bash

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

bindkey -e 
export CLICOLOR=1

if [ -n "$TMUX" ]; then
    alias e='tmux split-window -h nvim $@'
fi
