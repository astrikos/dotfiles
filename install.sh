#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

cwd=$(cd "$(dirname "$0")" && pwd)

usage() {
    cat << EOF >&2

Usage: $(basename "$0")

This program installs all necessary config files and binaries for setting up codespaces environment. e.g. neovim, tmux, zsh, oh-my-zsh

Options:

    -h,--help,                  Display usage.

EOF
}

setup-git() {
    echo "==> Setting up git configs"
    rm -rf "$HOME/.gitignore"
    ln -s "$cwd/git/gitignore" "$HOME/.gitignore" 
    rm -rf "$HOME/.gitconfig"
    ln -s "$cwd/git/gitconfig" "$HOME/.gitconfig" 
    echo "==> Finished setting up git configs"
}

setup-tmux() {
    echo "==> Setting up tmux config"
    # config file
    rm -f "$HOME/.tmux.conf"
    ln -s "$cwd/tmux/tmux.conf" "$HOME/.tmux.conf"
    # binary (3.2)
    mkdir -p "$HOME/.local/bin"
    rm -f "$HOME/.local/bin/tmux"
    ln -s "$cwd/tmux/tmux" "$HOME/.local/bin/tmux"
    echo "==> Finished setting up tmux config"
}

setup-nvim() {
    echo "==> Setting up neovim"

    rm -rf "$HOME/.config"
    mkdir "$HOME/.config"

    mkdir -p "$HOME/.local/bin"

    curl -LO https://github.com/neovim/neovim/releases/download/v0.9.4/nvim.appimage
    chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract
    ./squashfs-root/AppRun --version
    ln -s "$PWD/squashfs-root/AppRun" "$HOME/.local/bin/nvim"

    rm -rf "$HOME/.config/nvim"
    mkdir "$HOME/.config/nvim"
    ln -s "$cwd/init.vim" "$HOME/.config/nvim/init.vim"
    nvim --headless +PlugInstall +qa
    echo "==> Finished setting up neovim"
}

setup-oh-my-zsh() {
    echo "==> Setting up oh-my-zsh"
    rm -rf "$HOME/.oh-my-zsh/"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    rm -f "$HOME/.zshrc"
    ln -s "$cwd/zsh/zshrc" "$HOME/.zshrc"
    rm -f "$HOME/.oh-my-zsh/oh-my-zsh.sh"
    ln -s "$cwd/zsh/oh_my_zsh/oh-my-zsh.sh" "$HOME/.oh-my-zsh/oh-my-zsh.sh"
    ln -s "$cwd/zsh/oh_my_zsh/astrikos.zsh-theme" "$HOME/.oh-my-zsh/themes/astrikos.zsh-theme"
    sudo chsh -s "$(which zsh)" "$(whoami)"
    echo "==> Finished setting up oh-my-zsh"
}

setup-gitdelta() {
    echo "==> Setting up git-delta"
    curl -LO https://github.com/dandavison/delta/releases/download/0.15.1/git-delta-musl_0.15.1_amd64.deb
    sudo dpkg -i ./git-delta-musl_0.15.1_amd64.deb
    rm -rf ./git-delta-musl_0.15.1_amd64.deb
    echo "==> Finished setting up git-delta"
}


apt-install() {
    echo "==> Start apt-installing packages"
    # gh cli repo
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y zsh gh exuberant-ctags tree shellcheck icdiff autojump jq ripgrep libevent-dev ncurses-dev build-essential bison pkg-config
    sudo locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales
    echo "==> Finished apt-installing packages"
}

main() {
    if [[ "$#" -gt 0 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        usage
    fi

    echo "==> Starting to set up env"
    apt-install

    # we don't want tmux inside codespaces
    if [[ -z "$CODESPACES" ]]; then
        setup-tmux
    fi
    setup-nvim
    setup-gitdelta
    setup-oh-my-zsh
    setup-git
    echo "==> Successfully finished setting up env"
}

main "$@"
