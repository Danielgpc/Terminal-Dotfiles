# Custom functions and configurations
# ~/.zsh/custom.zsh

# Directory navigation
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
function extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick directory switching with fzf
function fd() {
    local dir
    dir=$(find ${1:-.} -type d 2>/dev/null | fzf +m) && cd "$dir"
}

# Git branch cleanup
function gclean() {
    git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
}

# Docker cleanup
function dclean() {
    docker system prune -af --volumes
}

# Weather
function weather() {
    curl -s "wttr.in/${1:-}" | head -7
}