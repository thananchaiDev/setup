#!/bin/bash
set -e

echo "=== macOS Setup Script ==="
echo ""

# --------------------------------------------------
# 1. Homebrew
# --------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed"
fi

# --------------------------------------------------
# 2. Homebrew formulae
# --------------------------------------------------
FORMULAE=(
  bun
  chezmoi
  gh
  lazygit
  mysql-client
  node
  pnpm
  python@3.13
  yarn
  zsh-autosuggestions
  zsh-syntax-highlighting
)

echo ""
echo "Installing Homebrew formulae..."
for formula in "${FORMULAE[@]}"; do
  if brew list "$formula" &>/dev/null; then
    echo "  $formula already installed"
  else
    brew install "$formula"
  fi
done

# --------------------------------------------------
# 3. Homebrew casks (GUI apps)
# --------------------------------------------------
CASKS=(
  1password
  android-studio
  flutter
  google-chrome
  visual-studio-code
  warp
)

echo ""
echo "Installing Homebrew casks..."
for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    echo "  $cask already installed"
  else
    brew install --cask "$cask"
  fi
done

# --------------------------------------------------
# 4. Oh My Zsh
# --------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo ""
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo ""
  echo "Oh My Zsh already installed"
fi

# --------------------------------------------------
# 5. Xcode (via App Store)
# --------------------------------------------------
if ! xcode-select -p &>/dev/null; then
  echo ""
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "  After Xcode CLT finishes, install full Xcode from App Store manually"
else
  echo ""
  echo "Xcode Command Line Tools already installed"
fi

# --------------------------------------------------
# 6. Claude Code CLI
# --------------------------------------------------
if ! command -v claude &>/dev/null; then
  echo ""
  echo "Installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code 2>/dev/null || echo "  Skipped (npm not available yet — install via bun/node later)"
else
  echo "Claude Code already installed"
fi

# --------------------------------------------------
# 8. Dotfiles via chezmoi
# --------------------------------------------------
echo ""
echo "Applying dotfiles with chezmoi..."
chezmoi init --apply 2>/dev/null || echo "  Run 'chezmoi init <your-repo>' manually to set up dotfiles"

# --------------------------------------------------
# 9. macOS defaults
# --------------------------------------------------
echo ""
echo "Applying macOS defaults..."

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

killall Finder 2>/dev/null || true

# --------------------------------------------------
# Done
# --------------------------------------------------
echo ""
echo "=== Setup complete! ==="
echo ""
echo "Manual steps:"
echo "  1. chezmoi init <your-dotfiles-repo> (if not set up)"
echo "  2. Sign in to 1Password"
echo "  3. Sign in to GitHub CLI: gh auth login"
echo "  4. Set up SSH keys"
echo "  5. Open VS Code and sign in to sync settings"
echo "  6. Install full Xcode from App Store"
