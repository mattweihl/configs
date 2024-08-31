#if command -v brew &>/dev/null; then
#  theme_file="$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
#  if [[ -f "$theme_file" ]]; then
#    source "$theme_file"
#  
#   if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#    fi
#
#  fi
#fi
#
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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

function tmux_dev() {
  # First check to see if a session called 'dev' already is running
  # If so, we will attach to it.
  # If not, we will create a new session called 'dev'
  # TODO: eventually hook into tmux-resurrect and tmux-continuum to restore the session

  if tmux has-session -t dev 2>/dev/null; then
    tmux attach -t dev
  else
    tmux new-session -s dev
  fi
}

alias dev="tmux_dev"

export EDITOR='vim'

if command -v fzf &> /dev/null
then
    source <(fzf --zsh)
fi

# Make neovim is installed first before making it the default editor and aliasing vim to neovim
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

