# macOS: BSD ls reads LSCOLORS (enabled by CLICOLOR=1 below)
export LSCOLORS=exBxhxDxfxhxhxhxhxcxcx

# Linux + zsh completion: GNU ls and zsh completion read LS_COLORS
if command -v dircolors &> /dev/null; then
  eval "$(dircolors -b)"
else
  export LS_COLORS='di=34:ln=1;32:so=37:pi=1;33:ex=35:bd=37:cd=37:su=37:sg=37:tw=32:ow=32'
fi

setopt PROMPT_SUBST
autoload -Uz add-zsh-hook vcs_info

zstyle ':vcs_info:git:*' formats '(%b)'

_prompt_update() {
  vcs_info
  local msg=$vcs_info_msg_0_

  # Keep PROMPT_SUBST safe-ish: prevent prompt escapes and substitutions from VCS text
  msg=${msg//\%/%%}
  msg=${msg//\$/\\$}
  msg=${msg//\`/\\\`}   # avoid `...` command substitution

  VCS_SAFE=$msg
}

add-zsh-hook precmd _prompt_update

PROMPT=$'%F{blue}%~%f%F{red}${VCS_SAFE:+ ${VCS_SAFE}}%f\n$ '

if ls --color=auto / >/dev/null 2>&1; then
  alias ll="ls -alFh --color=auto"
  alias la="ls -A --color=auto"
else
  alias ll="ls -alFhG"
  alias la="ls -AG"
fi
alias l="ll"
c()  { cd "${CODE_LOCATION:-$HOME/code}"; }
dt() { cd "${DESKTOP:-$HOME/Desktop}"; }

if [[ -r "$HOME/configs/zsh/worktree.sh" ]]; then
  source "$HOME/configs/zsh/worktree.sh"
fi

alias gs="git status"
alias gb="git branch"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gd="git diff"
alias history="history 1"

if command -v fzf &> /dev/null; then
    _fzf_cache="$HOME/.cache/fzf-zsh.zsh"
    if [[ ! -f "$_fzf_cache" || "$_fzf_cache" -ot "$(command -v fzf)" ]]; then
        mkdir -p "$HOME/.cache"
        if ! fzf --zsh > "$_fzf_cache" 2>/dev/null; then
            rm -f "$_fzf_cache"
        fi
    fi
    [[ -s "$_fzf_cache" ]] && source "$_fzf_cache"
fi

export EDITOR='vim'
if command -v nvim &> /dev/null
then
    export EDITOR="nvim"
    alias vim='nvim'
    alias vi='nvim'
fi

if command -v lazygit &> /dev/null
then
  alias lg='lazygit'
fi

alias clawd='claude --dangerously-skip-permissions'
alias neovide='neovide --fork'

agent() {
    if [[ -n "$TMUX" ]]; then
        "$HOME/configs/tmux/agent-tmux-wrapper.sh" "$@"
    else
        command agent "$@"
    fi
}

bindkey -e

autoload edit-command-line
zle -N edit-command-line
bindkey '^X^e' edit-command-line

autoload -U select-word-style
select-word-style bash

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt AUTO_CD

autoload -Uz compinit
# Skip the security audit unless the dump is >24h old (or missing).
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# pyenv: lazy-load. Shims stay on PATH so python/pip resolve; full `pyenv init`
# (which installs pyenv-virtualenv's cd-hook) defers until `pyenv` is called.
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# nvm: inject default node into PATH directly; defer `nvm.sh` source until use.
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR/versions/node" ]; then
  DEFAULT_ALIAS=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
  if [ -d "$NVM_DIR/versions/node/$DEFAULT_ALIAS" ]; then
    NODE_VERSION="$DEFAULT_ALIAS"
  else
    NODE_VERSION=$(command ls -1 "$NVM_DIR/versions/node" | tail -1)
  fi
  if [ -n "$NODE_VERSION" ]; then
    export PATH="$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH"
  fi
fi

nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}

if [ -s "$NVM_DIR/bash_completion" ]; then
  _nvm_lazy_completion() {
    compdef -d nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  }
  compdef _nvm_lazy_completion nvm
fi

