# ~/.zshrc - macOS configuration
# Managed by dotfiles repo

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=20000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space

# Enable colors
autoload -U colors && colors

# Prompt with git branch
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f$ '

# Enable completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Add dotfiles bin to PATH
export PATH="$HOME/dotfiles/bin:$PATH"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon)
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew (Intel)
if [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Source shared aliases
if [ -f "$HOME/dotfiles/shared/.aliases" ]; then
    source "$HOME/dotfiles/shared/.aliases"
fi

# macOS-specific aliases
alias ls='ls -G'

# mise (tool version manager)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# Editor
export EDITOR="code --wait"
export VISUAL="code --wait"

# Projects directory
export PROJECTS_DIR="$HOME/projects"

# Handoff configuration directory
export HANDOFF_CONFIG_DIR="$HOME/.config/handoff"

# Key bindings (emacs-style)
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
