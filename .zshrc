autoload -Uz compinit && compinit

if which oh-my-posh >/dev/null; then
        eval "$(oh-my-posh init zsh --config $HOME/configs/oh-my-posh-themes/cobalt2.omp.json)"
fi

alias ll="ls -alFh --color=auto"
alias la="ls -A --color=auto"
alias l="ll"
alias c="cd $CODE_LOCATION"
alias gs="git status"
alias dt="cd $DESKTOP"

if [ -d "$HOME/Dropbox" ]; then
    alias db="cd ~/Dropbox"
fi

if command -v nvim &> /dev/null
then
    alias vim="nvim"
fi

export EDITOR="nvim"
export LS_COLORS='ow=01;36;40'

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^e' edit-command-line

autoload -U select-word-style
select-word-style bash

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
