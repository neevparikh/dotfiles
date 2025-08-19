FROM archlinux:multilib-devel AS unfetched 
RUN pacman -Syu --noconfirm git cargo inetutils zsh 
ARG username
RUN useradd -m -G wheel -s /bin/zsh $username \
    && echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers 
USER $username
WORKDIR /home/$username
RUN cd /tmp \
   && git clone https://aur.archlinux.org/paru.git \
   && cd paru \
   && makepkg -si --noconfirm 
RUN paru -S --noconfirm \
   neovim \
   yadm \
   fzf \
   ripgrep \
   fd \
   bat \
   htop \
   uv \
   jujutsu \
   neovim-remote \
   tailscale \
   openssh \
   luarocks \
   nvidia-open \
   gosu \
   kitty-terminfo \
   npm 
RUN uv tool install llm 
RUN mkdir -p -m 700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts 
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
   "" --unattended 
RUN git clone https://github.com/zsh-users/zsh-autosuggestions \
   ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions 
RUN paru -S --noconfirm aws-cli-v2 --mflags "--skippgpcheck" 

RUN paru -Syu --noconfirm 
RUN paru -S --noconfirm \
   jq \
   git-lfs \
   github-cli 


COPY <<EOF ./entrypoint.sh
#!/bin/bash

yadm clone --depth 1 git@github.com:neevparikh/dotfiles.git && yadm alt && yadm checkout -- ~/
exec zsh
EOF
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]

FROM unfetched AS prefetched
RUN --mount=type=ssh,uid=1000 \
   yadm clone --depth 1 git@github.com:neevparikh/dotfiles.git \
   && yadm alt \
   && yadm checkout -- ~/ 
ENTRYPOINT ["/bin/zsh"]
