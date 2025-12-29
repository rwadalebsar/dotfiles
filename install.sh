#!/bin/bash
# Dotfiles installer - detects OS and sets up environment
# Usage: ./install.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"

echo -e "${BLUE}Dotfiles Installer${NC}"
echo "===================="

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        echo "wsl"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo -e "Detected OS: ${GREEN}$OS${NC}"

# Backup existing file if it exists and is not a symlink
backup_file() {
    local file="$1"
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        echo -e "  ${YELLOW}Backing up${NC} $file -> $file.backup"
        mv "$file" "$file.backup"
    elif [ -L "$file" ]; then
        rm "$file"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    backup_file "$target"
    ln -sf "$source" "$target"
    echo -e "  ${GREEN}Linked${NC} $target -> $source"
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "  ${GREEN}Created${NC} $dir"
    fi
}

# Install shared configs
install_shared() {
    echo -e "\n${BLUE}Installing shared configs...${NC}"

    # Git config
    create_symlink "$DOTFILES_DIR/shared/.gitconfig" "$HOME/.gitconfig"

    # Create projects directory
    ensure_dir "$HOME/projects"

    # Create handoff config directory
    ensure_dir "$HOME/.config/handoff"
}

# Install macOS specific configs
install_macos() {
    echo -e "\n${BLUE}Installing macOS configs...${NC}"

    # zsh config
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo -e "\n${YELLOW}Homebrew not found. Install it with:${NC}"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    else
        echo -e "  ${GREEN}Homebrew${NC} already installed"
    fi

    # Install mise if not present
    if ! command -v mise &> /dev/null; then
        echo -e "\n${YELLOW}mise not found. Install it with:${NC}"
        echo "brew install mise"
    else
        echo -e "  ${GREEN}mise${NC} already installed"
    fi
}

# Install WSL/Linux specific configs
install_wsl() {
    echo -e "\n${BLUE}Installing WSL/Linux configs...${NC}"

    # bash config
    create_symlink "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

    # Install mise if not present
    if ! command -v mise &> /dev/null; then
        echo -e "\n${YELLOW}mise not found. Install it with:${NC}"
        echo "curl https://mise.run | sh"
        echo 'Then add to your shell: eval "$(~/.local/bin/mise activate bash)"'
    else
        echo -e "  ${GREEN}mise${NC} already installed"
    fi
}

# Install GPG and pass
install_secrets_tools() {
    echo -e "\n${BLUE}Checking secrets management tools...${NC}"

    if ! command -v gpg &> /dev/null; then
        echo -e "  ${YELLOW}gpg not found${NC}"
        if [[ "$OS" == "macos" ]]; then
            echo "  Install with: brew install gnupg"
        else
            echo "  Install with: sudo apt install gnupg"
        fi
    else
        echo -e "  ${GREEN}gpg${NC} already installed"
    fi

    if ! command -v pass &> /dev/null; then
        echo -e "  ${YELLOW}pass not found${NC}"
        if [[ "$OS" == "macos" ]]; then
            echo "  Install with: brew install pass"
        else
            echo "  Install with: sudo apt install pass"
        fi
    else
        echo -e "  ${GREEN}pass${NC} already installed"
    fi
}

# Main installation
main() {
    # Check if running from correct directory
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${RED}Error: Dotfiles directory not found at $DOTFILES_DIR${NC}"
        echo "Please clone your dotfiles repo to ~/dotfiles first."
        exit 1
    fi

    # Install shared configs
    install_shared

    # Install OS-specific configs
    case "$OS" in
        macos)
            install_macos
            ;;
        wsl|linux)
            install_wsl
            ;;
        *)
            echo -e "${YELLOW}Unknown OS, installing shared configs only${NC}"
            ;;
    esac

    # Check secrets tools
    install_secrets_tools

    # Summary
    echo -e "\n${BLUE}===================${NC}"
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "  2. Update ~/dotfiles/shared/.gitconfig with your name and email"
    echo "  3. Set up GPG and pass for secrets management"
    echo "  4. Register your projects: handoff add ~/projects/your-project"
    echo ""
    echo "Commands available:"
    echo "  handoff    - Push all changes before switching machines"
    echo "  pickup     - Pull all changes when arriving at a machine"
}

main
