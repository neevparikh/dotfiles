# Use Ubuntu as a base
FROM ubuntu:18.04

# Install necessary packages
RUN apt update && apt install -y \
    git \
    neovim \
    zsh \
    tmux \
    curl

# Add user neev
RUN useradd -p dockerneev@1010 -m neev && \
    usermod -aG sudo neev

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
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM xterm
ENV ZSH_THEME gruvbox  

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

# Setup tmux

# Setup zsh
RUN mkdir -p /home/neev/.oh-my-zsh/custom/themes && \
    cp ./dotfiles/zsh/gruvbox.zsh-theme /home/neev/.oh-my-zsh/custom/themes/gruvbox.zsh-theme && \
    cp ./dotfiles/zsh/zshrc ~/.zshrc

# Clean up things
RUN rm -rf ./dotfiles/ 
 
# Start shell
CMD zsh
