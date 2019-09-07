# Use Ubuntu as a base
FROM nvidia/cuda:10.1-devel-ubuntu18.04

USER root

RUN apt-get -qq update && apt-get -qq install -y \
    git \
    software-properties-common \
    build-essential \
    cmake \
    python3-dev \
    htop \
    tree \
    python3-venv \
    python3-pip \
    unzip \
    sudo \
    locales \
    zsh \
    tmux \
    fonts-powerline \
    curl && \
    locale-gen en_US.UTF-8

RUN sudo add-apt-repository ppa:neovim-ppa/unstable -y \
    && apt-get -yqq install neovim \
    && pip3 install \
        neovim-remote \
        pynvim

# Install fd for fzf
RUN curl -o fd.deb -sL https://github.com/sharkdp/fd/releases/download/v7.3.0/fd-musl_7.3.0_amd64.deb && \
    dpkg -i fd.deb && \ 
    rm fd.deb

# Install node for coc.nvim 
RUN curl -sL install-node.now.sh/lts | bash -s -- --yes

# Good idea to run, extensions might need
ENV SHELL=/bin/zsh
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TERM=screen-256color

# Install vim-plug
RUN curl -fsLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Clone dotfiles repo 
RUN git clone https://github.com/neevparikh/dotfiles

# Setup neovim 
RUN mkdir -p ~/.config/nvim/ && \
    cp ./dotfiles/nvim/init.vim ~/.config/nvim/init.vim && \
    nvim --headless +PlugInstall +qa 

# Setup tmux *?*

# Setup zsh
RUN mkdir -p ~/.oh-my-zsh/custom/themes && \
    cp ./dotfiles/zsh/gruvbox.zsh-theme ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme && \
    cp ./dotfiles/zsh/.zshrc ~/.zshrc

# Clean up things
RUN rm -rf ./dotfiles/ 

ENV PATH=~/.local/bin/:$PATH
 
# Start shell
CMD zsh
