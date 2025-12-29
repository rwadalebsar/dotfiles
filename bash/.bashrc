# ~/.bashrc - WSL/Ubuntu configuration
# Managed by dotfiles repo

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Prompt with git branch
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Colorful prompt with git branch
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add dotfiles bin to PATH
export PATH="$HOME/dotfiles/bin:$PATH"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Source shared aliases
if [ -f "$HOME/dotfiles/shared/.aliases" ]; then
    source "$HOME/dotfiles/shared/.aliases"
fi

# mise (tool version manager)
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# WSL-specific settings
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    # Open files with Windows default application
    alias open="explorer.exe"

    # Use Windows browser
    export BROWSER="wslview"
fi

# Editor
export EDITOR="code --wait"
export VISUAL="code --wait"

# Projects directory
export PROJECTS_DIR="$HOME/projects"

# Handoff configuration directory
export HANDOFF_CONFIG_DIR="$HOME/.config/handoff"

# Enable programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
