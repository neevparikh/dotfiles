FROM archlinux:multilib-devel AS unfetched
RUN --mount=type=cache,target=/var/cache/pacman/pkg/,sharing=private \
    pacman -Syu --noconfirm git cargo inetutils zsh

ARG username
ARG uid
RUN useradd -m -G wheel -u $uid -s /bin/zsh $username \
    && echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER $username
WORKDIR /home/$username

RUN --mount=type=tmpfs,target=/tmp/ \
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin && \
    cd /tmp/paru-bin && \
    makepkg -si --noconfirm

RUN --mount=type=cache,target=/home/$username/.cache/,sharing=private,uid=$uid \
    --mount=type=cache,target=/var/cache/,sharing=private \
    paru -Syu --noconfirm \
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
       gosu \
       kitty-terminfo \
       npm \
       jq \
       git-lfs \
       github-cli \
       tree \
       tmux \
       downgrade \
       cuda \
       nvtop \
       aws-cli-v2

RUN mkdir -p -m 700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=cache,target=/home/$username/.cache/uv,uid=$uid \
    uv tool install llm

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
   "" --unattended

ADD --link --chown=$username https://github.com/zsh-users/zsh-autosuggestions.git ./.oh-my-zsh/custom/plugins/zsh-autosuggestions

COPY --link --chown=$username --chmod=755 <<EOF ./entrypoint.sh
#!/bin/bash

yadm clone --depth 1 git@github.com:neevparikh/dotfiles.git && yadm alt && yadm checkout -- ~/
exec zsh
EOF
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]

FROM unfetched AS prefetched
RUN --mount=type=ssh,uid=$uid \
   yadm clone --depth 1 git@github.com:neevparikh/dotfiles.git \
   && yadm alt \
   && yadm checkout -- ~/ 
ENTRYPOINT ["/bin/zsh"]
