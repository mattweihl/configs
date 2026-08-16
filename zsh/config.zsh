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
go_to_code()  { cd "${CODE_LOCATION:-$HOME/code}"; }
go_to_desktop() { cd "${DESKTOP:-$HOME/Desktop}"; }

alias c='go_to_code'
alias dt='go_to_desktop'


if [[ -r "$HOME/configs/zsh/worktree.sh" ]]; then
  source "$HOME/configs/zsh/worktree.sh"
fi

if [[ -r "$HOME/configs/zsh/link-agentic-configs.sh" ]]; then
  source "$HOME/configs/zsh/link-agentic-configs.sh"
fi

# These shadow two rarely-typed Homebrew binaries pulled in as dependencies:
# `gs` (ghostscript) and `gc` (graphviz). Aliases only apply to interactive
# shells, so scripts and other tools still resolve the real binaries; use
# `command gs` / `command gc` if you ever need them by hand.
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

#alias clawd='claude --dangerously-skip-permissions'
alias clawd='claude --permission-mode auto'
alias neovide='neovide --fork'

bindkey -e
# VS Code/Cursor send CSI modifier sequences for Option/Ctrl + Arrow.
bindkey '\e[1;3D' backward-word
bindkey '\e[1;3C' forward-word
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word

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

# nvm: inject the default Node version into PATH, but defer nvm.sh until use.
export NVM_DIR="$HOME/.nvm"

_nvm_latest_installed_version() {
  local version_dir
  for version_dir in "$NVM_DIR"/versions/node/v<->.<->.<->(N/); do
    basename "$version_dir"
  done | sort -t. -k1.2,1n -k2,2n -k3,3n | tail -1
}

_nvm_resolve_installed_version() {
  local alias_name="$1"
  local alias_file alias_value seen=" "
  local attempts=0

  while [ -n "$alias_name" ] && [ "$attempts" -lt 20 ]; do
    case "$seen" in
      *" $alias_name "*) return 1 ;;
    esac
    seen="$seen$alias_name "

    if [ -d "$NVM_DIR/versions/node/$alias_name" ]; then
      printf '%s\n' "$alias_name"
      return 0
    fi

    if [ "$alias_name" = "lts/*" ]; then
      for alias_file in "$NVM_DIR"/alias/lts/*; do
        [ -f "$alias_file" ] || continue
        IFS= read -r alias_value < "$alias_file"
        [ -d "$NVM_DIR/versions/node/$alias_value" ] && printf '%s\n' "$alias_value"
      done | sort -t. -k1.2,1n -k2,2n -k3,3n | tail -1
      return
    fi

    alias_file="$NVM_DIR/alias/$alias_name"
    [ -f "$alias_file" ] || return 1
    IFS= read -r alias_name < "$alias_file"
    attempts=$((attempts + 1))
  done
  return 1
}

if [ -d "$NVM_DIR/versions/node" ]; then
  nvm_default_alias=""
  [ -f "$NVM_DIR/alias/default" ] && IFS= read -r nvm_default_alias < "$NVM_DIR/alias/default"
  nvm_node_version="$(_nvm_resolve_installed_version "$nvm_default_alias" 2>/dev/null)"
  [ -n "$nvm_node_version" ] || nvm_node_version="$(_nvm_latest_installed_version)"
  if [ -n "$nvm_node_version" ]; then
    nvm_node_bin="$NVM_DIR/versions/node/$nvm_node_version/bin"
    path=("${(@)path:#${NVM_DIR}/versions/node/*/bin}")
    path=("$nvm_node_bin" "$path[@]")
    export PATH
  fi
  unset nvm_default_alias nvm_node_version nvm_node_bin
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  NVM_SH="$NVM_DIR/nvm.sh"
elif [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"
elif [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
  NVM_SH="/usr/local/opt/nvm/nvm.sh"
elif [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ]; then
  NVM_SH="/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh"
fi

if [ -n "${NVM_SH:-}" ]; then
  nvm() {
    unset -f nvm
    \. "$NVM_SH"
    # Re-wrap nvm so `nvm install <ver>` also sets up corepack-managed
    # yarn/pnpm shims in the newly-installed node's bin dir.
    functions[_nvm_orig]=$functions[nvm]
    nvm() {
      _nvm_orig "$@"
      local rc=$?
      if [[ "$1" == "install" && $rc -eq 0 ]] && command -v corepack >/dev/null 2>&1; then
        corepack enable >/dev/null 2>&1
      fi
      return $rc
    }
    nvm "$@"
  }

  NVM_COMPLETION=""
  if [ -s "$NVM_DIR/bash_completion" ]; then
    NVM_COMPLETION="$NVM_DIR/bash_completion"
  elif [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
    NVM_COMPLETION="/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  elif [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]; then
    NVM_COMPLETION="/usr/local/opt/nvm/etc/bash_completion.d/nvm"
  elif [ -s "/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
    NVM_COMPLETION="/home/linuxbrew/.linuxbrew/opt/nvm/etc/bash_completion.d/nvm"
  fi
  if [ -s "$NVM_COMPLETION" ]; then
    _nvm_lazy_completion() {
      compdef -d nvm
      nvm --version >/dev/null
      \. "$NVM_COMPLETION"
    }
    compdef _nvm_lazy_completion nvm
  fi
fi

if command -v fzf &> /dev/null; then
  vf() {
    local file
    file=$(fzf)

    if [[ -n "$file" && -f "$file" ]]; then
      vim "$file"
    fi
  }
fi
