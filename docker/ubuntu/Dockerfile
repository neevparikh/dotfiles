# Use Ubuntu as a base
FROM ubuntu:18.04

# Install necessary packages
RUN apt update && apt install -y \
    git \
    neovim \
    zsh \
    curl \

# Install fd for fzf
RUN wget -q -O fd.deb https://github.com/sharkdp/fd/releases/download/v7.3.0/fd-musl_7.3.0_amd64.deb && \
    dpkg -i fd.deb && \ 
    rm fd.deb

# Install vim-plug
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

# Clone dotfiles repo 
RUN git clone https://github.com/neevparikh/dotfiles

# Setup neovim 
# Setup zsh
