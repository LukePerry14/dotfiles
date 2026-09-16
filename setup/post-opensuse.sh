#!/usr/bin/env bash

# --------------------------------------------------------------
# nwg-displays
# --------------------------------------------------------------

if rpm -q nwg-displays &>/dev/null; then
    sudo zypper rm -y nwg-displays
fi
info "Building and deploying latest nwg-displays..."
NWG_DISPLAYS_BUILD_DIR=$(mktemp -d)
git clone https://github.com/nwg-piotr/nwg-displays.git "$NWG_DISPLAYS_BUILD_DIR"
python3 -m pip install --user --break-system-packages "$NWG_DISPLAYS_BUILD_DIR"
info "nwg-displays installed to ~/.local/bin/"
rm -rf $NWG_DISPLAYS_BUILD_DIR

# --------------------------------------------------------------
# awww
# --------------------------------------------------------------

sudo zypper --non-interactive --gpg-auto-import-keys install awww

# --------------------------------------------------------------
# Quickshell
# --------------------------------------------------------------

# Add DankLinux repository
sudo zypper addrepo https://download.opensuse.org/repositories/home:AvengeMedia:danklinux/openSUSE_Tumbleweed/home:AvengeMedia:danklinux.repo
sudo zypper refresh
sudo zypper --non-interactive --gpg-auto-import-keys install quickshell

# --------------------------------------------------------------
# Oh My Posh
# --------------------------------------------------------------

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# --------------------------------------------------------------
# Oh My Zsh
# --------------------------------------------------------------

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ":: Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    cp $repo_path/dotfiles/.zshrc ~/.zshrc
else
    echo ":: oh-my-zsh already installed"
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo ":: Installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo ":: Installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting" ]; then
    echo ":: Installing fast-syntax-highlighting"
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
fi

# --------------------------------------------------------------
# ML4W Settings App
# --------------------------------------------------------------

curl -sSL https://raw.githubusercontent.com/mylinuxforwork/ml4w-dotfiles-settings/main/setup.sh | bash

# --------------------------------------------------------------
# Quickshell Overview
# --------------------------------------------------------------

curl -sSL https://raw.githubusercontent.com/mylinuxforwork/ml4w-quickshell-overview/main/install.sh | bash

# --------------------------------------------------------------
# Cargo
# --------------------------------------------------------------

TARGET_VERSION="4.0.0"

force_install_matugen() {
    info "Running: cargo install matugen --force"
    cargo install matugen --force
}

if ! command -v matugen &> /dev/null; then
    echo "'matugen' is not currently installed."
    force_install_matugen
else
    CURRENT_VERSION=$(matugen --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    LOWEST_VERSION=$(printf "%s\n%s" "$TARGET_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)
    if [ "$LOWEST_VERSION" = "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$TARGET_VERSION" ]; then
        info "Current version ($CURRENT_VERSION) is lower than $TARGET_VERSION. Updating..."
        force_install_matugen
    else
        info "matugen is already up to date! (Current version: $CURRENT_VERSION)"
    fi
fi

# --------------------------------------------------------------
# JetBrains Mono Nerd Font
# --------------------------------------------------------------

sudo zypper addrepo https://download.opensuse.org/repositories/X11:fonts/openSUSE_Factory/X11:fonts.repo
sudo zypper -n install jetbrainsmono-nerd-fonts

# --------------------------------------------------------------
# Pip
# --------------------------------------------------------------

echo ":: Installing packages with pip"
pipx install pywalfox
pywalfox-install

# --------------------------------------------------------------
# Grimblast
# --------------------------------------------------------------

source $repo_path/setup/clean-install-grimblast.sh

# --------------------------------------------------------------
# Cursors
# --------------------------------------------------------------

source $repo_path/setup/_cursors.sh

# --------------------------------------------------------------
# Fonts
# --------------------------------------------------------------

source $repo_path/setup/_fonts.sh

# --------------------------------------------------------------
# Icons
# --------------------------------------------------------------

source $repo_path/setup/_icons.sh

# --------------------------------------------------------------
# Create XDG Directories
# --------------------------------------------------------------

xdg-user-dirs-update
