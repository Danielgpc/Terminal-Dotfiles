
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set Powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k configuration if it exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2026-09-03 18:22:33
export PATH="$PATH:/Users/danielgp/.local/bin"

# Enable vi mode
bindkey -v
# Reduce key delay when switching modes (1 = 10ms)
export KEYTIMEOUT=1

# ==============================================================================
# TYPO GUARDS
# ==============================================================================
alias bwer='brew'
alias mkae='make'

# ==============================================================================
# MODERN CLI REPLACEMENTS
# ==============================================================================
# eza (replacement for ls / colorls)
if command -v eza &> /dev/null; then
  alias ls="eza --color=auto --icons=auto --group-directories-first"
  alias l="eza -1 --color=auto --icons=auto --group-directories-first"

  alias ll="eza -lh --git --color=auto --icons=auto --group-directories-first"
  alias la="eza -lah --git --color=auto --icons=auto --group-directories-first"

  alias lt="eza --tree --level=2 --color=auto --icons=auto --group-directories-first" # Tree view
  alias llm="eza -lh --sort=modified --git --color=auto --icons=auto"                  # Long list, newest firstalias grep='grep --color=auto'
fi

# bat (replacement for cat)
if command -v bat &> /dev/null; then
  alias cat="bat --style=plain"
  alias catp="bat"                    # With full metadata/line numbers/header
fi

# zoxide (smarter replacement for cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# ==============================================================================
# NAVIGATION & SYSTEM
# ==============================================================================
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"                     # Jump back to last directory

alias c="clear"
alias h="history"
alias q="exit"

alias cp="cp -iv"                     # Safe cp (asks before overwrite, verbose)
alias mv="mv -iv"                     # Safe mv
alias rm="rm -iv"                     # Safe rm
alias mkdir="mkdir -pv"               # Auto-creates parent dirs

alias zshconfig="${EDITOR:-nano} ~/.zshrc"
alias reload="source ~/.zshrc && echo 'Zsh reloaded!'"

# ==============================================================================
# GIT ALIASES
# ==============================================================================
alias g="git"
alias gs="git status"
alias gss="git status -s"
alias ga="git add"
alias gaa="git add --all"
alias gap="git add --patch"

# Commits
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gcam="git commit --amend"
alias gcan="git commit --amend --no-edit"

# Branches & Checkout
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias gbD="git branch -D"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcm="git checkout main 2>/dev/null || git checkout master"

# Diff & Logs
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph --decorate"
alias glla="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Syncing
alias gf="git fetch --all --prune"
alias gpl="git pull"
alias gplr="git pull --rebase"
alias gps="git push"
alias gpsf="git push --force-with-lease"

# Stash & Reset
alias gst="git stash"
alias gstp="git stash pop"
alias grh="git reset --hard"
alias grs="git reset --soft"

# ==============================================================================
# NETWORK & UTILITIES
# ==============================================================================
alias myip="curl -s https://ipinfo.io/ip"
alias localip="ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print \$1}'"
alias ports="netstat -tulanp"

# ==============================================================================
# GENERAL ALIASES
# ==============================================================================
alias nv="nvim"
