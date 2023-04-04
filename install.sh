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
    echo "Setting up git configs"
    rm -rf "$HOME/.gitignore"
    ln -s "$cwd/git/gitignore" "$HOME/.gitignore" 
    rm -rf "$HOME/.gitconfig"
    ln -s "$cwd/git/gitconfig" "$HOME/.gitconfig" 
}

setup-tmux() {
    echo "Setting up tmux config"
    # config file
    rm -f "$HOME/.tmux.conf"
    ln -s "$cwd/tmux/tmux.conf" "$HOME/.tmux.conf"
    # binary (3.2)
    mkdir -p "$HOME/.local/bin"
    rm -f "$HOME/.local/bin/tmux"
    ln -s "$cwd/tmux/tmux" "$HOME/.local/bin/tmux"
}

setup-nvim() {
    echo "Setting up neovim"
    curl -LO https://github.com/neovim/neovim/releases/download/v0.8.2/nvim-linux64.deb
    sudo apt install ./nvim-linux64.deb

    rm -rf "$HOME/.config"
    mkdir "$HOME/.config"
    
    rm -rf "$HOME/.config/nvim"
    mkdir "$HOME/.config/nvim"
    ln -s "$cwd/init.vim" "$HOME/.config/nvim/init.vim"
    rm -rf ./nvim-linux64.deb
    nvim --headless +PlugInstall +qa
}

setup-oh-my-zsh() {
    echo "Setting up oh-my-zsh"
    rm -rf "$HOME/.oh-my-zsh/"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    rm -f "$HOME/.zshrc"
    ln -s "$cwd/zsh/zshrc" "$HOME/.zshrc"
    rm -f "$HOME/.oh-my-zsh/oh-my-zsh.sh"
    ln -s "$cwd/zsh/oh_my_zsh/oh-my-zsh.sh" "$HOME/.oh-my-zsh/oh-my-zsh.sh"
    ln -s "$cwd/zsh/oh_my_zsh/astrikos.zsh-theme" "$HOME/.oh-my-zsh/themes/astrikos.zsh-theme"
    sudo chsh -s "$(which zsh)" "$(whoami)"
}

apt-install() {
    # gh cli repo
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y zsh gh exuberant-ctags tree shellcheck icdiff autojump jq ripgrep libevent-dev ncurses-dev build-essential bison pkg-config
}

main() {
	if [[ "$#" -gt 0 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        usage
    fi

    apt-install
    setup-tmux
    setup-nvim
    setup-oh-my-zsh
    setup-git
    echo "Successfully setting up env"
}

main "$@"
