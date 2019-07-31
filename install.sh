#!/bin/bash

# Configure variables
USER=neev
HOME=/home/$USER
VERSION=$(lsb_release -rs)

# All the stuff to install
apt-get update -yqq && apt-get upgrade -yqq > /dev/null
apt-get install -yqq \
	git \
	zsh \
	curl \
	neovim > /dev/null

# Install node for coc
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && apt-get install -yqq nodejs

# Only if not headless
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt-get/sources.list.d/google-chrome.list
curl -sL https://dl.google.com/linux/linux_signing_key.pub | apt-get-key add && apt-get update -yqq 
apt-get install -yqq \
	google-chrome-stable \
	i3 \
	compton \
	feh \
	rofi \
	fonts-powerline > /dev/null

# Create the required directory structure
sudo -u neev \
    && mkdir -p $HOME/repos/ \
    && mkdir -p $HOME/.config/rofi/ \
    && mkdir -p $HOME/.config/nvim/ \
    && mkdir -p $HOME/.config/i3/ \
    && mkdir -p $HOME/.config/i3status/ \

# Install node for coc
curl -sL install-node.now.sh/lts | bash -s -- --yes > /dev/null

# Set some env var
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
export TERM=xterm-256color

# Install vim-plug
sudo -u neev /usr/bin/curl -fsLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim > /dev/null

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended > /dev/null
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions > /dev/null

# Installing fd for fzf 
if [[ ${VERSION:0:2} -ge "19" ]]
then
	apt-get install -yqq fd-find
else
	curl -o fd.deb -sL https://github.com/sharkdp/fd/releases/download/v7.3.0/fd-musl_7.3.0_amd64.deb && dpkg -i fd.deb && rm fd.deb
fi

# Clone repo and symlinks
cd $HOME/repos/ && git clone https://github.com/neevparikh/dotfiles/
ln -sfn nvim/init.vim $HOME/.config/nvim/init.vim
ln -sfn i3/config $HOME/.config/i3/config
ln -sfn i3status/config $HOME/.config/i3status/config
ln -sfn rofi/config $HOME/.config/rofi/config
ln -sfn feh/.fehbg $HOME/.fehbg
ln -sfn zsh/.zshrc $HOME/.zshrc

# Will need to be copied
sudo -u neev cp zsh/.gruvbox.zsh-theme $HOME/.oh-my-zsh/custom/themes/gruvbox.zsh-theme

# To be run as root
ln -sfn rofi/themes /usr/share/rofi/themes
ln -sfn wallpaper/* /usr/share/backgrounds/
cd $HOME

# Setup neovim 
sudo -u neev /usr/bin/nvim --headless +PlugInstall +qa
