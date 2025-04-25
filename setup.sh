!#/usr/bin/env bash

set -eo pipefail

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


mkdir -p ~/.config/nvim/
mkdir -p ~/.local/bin/
mkdir ~/downloads/

cd ~/downloads/
wget https://github.com/junegunn/fzf/releases/download/v0.61.3/fzf-0.61.3-linux_amd64.tar.gz
wget https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
wget https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-gnu.tar.gz
wget https://github.com/martanne/abduco/releases/download/v0.6/abduco-0.6.tar.gz
wget https://github.com/martanne/dvtm/releases/download/v0.15/dvtm-0.15.tar.gz
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

ln -s ~/repos/dotfiles/home/.zshrc ~/.zshrc
ln -s ~/repos/dotfiles/home/.zlogin ~/.zlogin
ln -s ~/repos/dotfiles/home/.zprofile ~/.zprofile 
ln -s ~/repos/dotfiles/config/theme.yaml ~/.config/
ln -s ~/repos/dotfiles/config/bat/ ~/.config/bat
ln -s ~/repos/dotfiles/config/theme.yaml ~/.config/theme.yaml
ln -s ~/repos/dotfiles/config/nvim/ ~/.config/nvim
ln -s ~/repos/dotfiles/home/zsh_custom/minimal.zsh-theme ~/.oh-my-zsh/custom/themes/minimal.zsh-theme
ln -s ~/repos/dotfiles/local/bin/nvr ~/.local/bin/nvr
ln -s ~/repos/dotfiles/local/bin/git-editor ~/.local/bin/git-editor
ln -s ~/repos/dotfiles/local/bin/themed-bat ~/.local/bin/themed-bat
