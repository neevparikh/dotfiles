# Use Ubuntu as a base
FROM nvidia/cuda:10.1-devel-ubuntu18.04

USER root

RUN apt-get -qq update && apt-get -qq install -y \
    git \
    software-properties-common \
    python3-dev \
    python3-venv \
    sudo \
    locales \
    neovim \
    zsh \
    tmux \
    fonts-powerline \
    curl && \
    locale-gen en_US.UTF-8

# Add user 
RUN useradd -p "$(openssl passwd -1 docker@1010)" -m neev -s /bin/zsh -g root -G sudo 

# Install fd for fzf
RUN curl -o fd.deb -sL https://github.com/sharkdp/fd/releases/download/v7.3.0/fd-musl_7.3.0_amd64.deb && \
    dpkg -i fd.deb && \ 
    rm fd.deb

# Install node for coc.nvim 
RUN curl -sL install-node.now.sh/lts | bash -s -- --yes

# Switch user and cd
USER neev 
WORKDIR "/home/neev/"

# Good idea to run, extensions might need
ENV SHELL=/bin/zsh
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color

RUN curl -sL "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
    && python3 get-pip.py --user

# Install vim-plug
RUN curl -fsLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Clone dotfiles repo 
RUN git clone https://github.com/neevparikh/dotfiles

# Setup neovim 
RUN mkdir -p /home/neev/.config/nvim/ && \
    cp ./dotfiles/nvim/init.vim /home/neev/.config/nvim/init.vim && \
    nvim --headless +PlugInstall +qa 

# Setup tmux *?*

# Setup zsh
RUN mkdir -p /home/neev/.oh-my-zsh/custom/themes && \
    cp ./dotfiles/zsh/gruvbox.zsh-theme /home/neev/.oh-my-zsh/custom/themes/gruvbox.zsh-theme && \
    cp ./dotfiles/zsh/.zshrc ~/.zshrc

# Clean up things
RUN rm -rf ./dotfiles/ 

ENV PATH=/home/neev/.local/bin/:$PATH
 
# Start shell
CMD zsh
