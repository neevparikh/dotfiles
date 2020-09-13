#install specific environment variables (mostly path) {{{1
if [ -d "$HOME/bin" ]; then #{{{2
  PATH="$HOME/bin:$PATH"
fi

if [ -d "/usr/local/cuda/bin/" ]; then #{{{2
  export PATH="/usr/local/cuda/bin/:$PATH"
fi

if [ -d "$HOME/scripts" ]; then #{{{2
  export PATH="$HOME/scripts:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then #{{{2
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -d "$HOME/.yarn/bin" ]; then #{{{2
  export PATH="$HOME/.yarn/bin:$PATH"
fi

if [ -d "$HOME/.config/yarn/global/node_modules/.bin" ]; then #{{{2
  export PATH="$HOME/.config/yarn/global/node_modules/.bin:$PATH"
fi

if [ -d "$HOME/.npm-global/bin" ]; then #{{{2
  export PATH="$HOME/.npm-global/bin:$PATH"
fi

if [ -d "$HOME/.nvm" ]; then #{{{2
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

if [ -d "/usr/local/go/" ]; then #{{{2
  export GOROOT=/usr/local/go
  export PATH="$GOROOT/bin:$PATH"
fi

if [ -d "$HOME/go/" ]; then #{{{2
  export PATH="$HOME/go/bin:$PATH"
  export GOPATH="$HOME/go:$HOME/repos/2951O/"
fi

if [ -d "$HOME/.local/bin" ]; then #{{{2
  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.mujoco/mujoco200" ]; then #{{{2
  PATH="$HOME/.local/bin:$PATH"
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/neev/.mujoco/mujoco200/bin
fi

if [ -d "$HOME/.mujoco/mjpro150" ]; then #{{{2
  PATH="$HOME/.local/bin:$PATH"
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/neev/.mujoco/mjpro150/bin
fi

if [ -d "$HOME/.local/bin/toggle_theme" ]; then #{{{2
     $HOME/.local/bin/toggle_theme --dark
fi

if command -v javac >/dev/null 2>&1; then
  JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")"
  export JAVA_HOME
fi

if command -v firefox >/dev/null 2>&1; then
  export MOZ_USE_XINPUT2=1
fi


#generic environment vars {{{1
if hash nvim 2>/dev/null; then
  export VISUAL=nvim
elif hash vim 2>/dev/null; then
  export VISUAL=vim
elif hash vi 2>/dev/null; then
  export VISUAL=vi
fi

# GDK 
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5

export EDITOR="$VISUAL"
export SUDO_EDITOR="editor"
a="-e SC1090 -e 2001 -e SC2016 -e SC2139 -e SC2164"
export SHELLCHECK_OPTS="$a"

if [ -d "$HOME/.fzf" ]; then #{{{1
  gruvbox_fg_1='#ebdbb2'
  gruvbox_yellow='#fabd2f'
  gruvbox_bg_1='#3c3836'
  gruvbox_blue='#83a598'
  gruvbox_fg_4='#a89984'
  gruvbox_orange='#fe8019'
  gruvbox_bg_3='#665c54'

  fd_base_args='--follow --hidden --exclude .git --color=always'
  export FZF_DEFAULT_COMMAND="fd $fd_base_args"
  export FZF_DIR_COMMAND="fd --type directory $fd_base_args"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FZF_DIR_COMMAND"

  # export FZF_COMPLETION_OPTS="--preview 'preview {}' --preview-window=wrap"
  # export FZF_ALT_C_OPTS="$FZF_COMPLETION_OPTS"
  # a='--preview "echo {}" --preview-window down:3:hidden:wrap'
  # export FZF_CTRL_R_OPTS="$a"
  # export FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"

  export FZF_DEFAULT_OPTS
  # FZF_DEFAULT_OPTS+="--layout=reverse --bind 'ctrl-s:select-all+accept,"
  # FZF_DEFAULT_OPTS+="ctrl-j:jump-accept,ctrl-k:jump,ctrl-p:toggle-preview,"
  # FZF_DEFAULT_OPTS+="ctrl-w:toggle-preview-wrap,ctrl-g:top,"
  # FZF_DEFAULT_OPTS+="alt-e:execute-silent[(nvr --remote-tab {} &)]' --ansi "
  FZF_DEFAULT_OPTS+="--layout=reverse --ansi "
  FZF_DEFAULT_OPTS+="--color=fg:$gruvbox_fg_1,hl:$gruvbox_yellow,"
  FZF_DEFAULT_OPTS+="fg+:$gruvbox_fg_1 --color=bg+:$gruvbox_bg_1,"
  FZF_DEFAULT_OPTS+="hl+:$gruvbox_yellow,info:$gruvbox_blue "
  FZF_DEFAULT_OPTS+="--color=prompt:$gruvbox_fg_4,pointer:$gruvbox_blue "
  FZF_DEFAULT_OPTS+="--color=marker:$gruvbox_orange,spinner:$gruvbox_yellow "
  FZF_DEFAULT_OPTS+="--color=header:$gruvbox_bg_3 "

  PATH="$HOME/.fzf/bin/:$PATH"
fi


export PROFILE_SOURCED=1

#}}}

# vim: set fdm=marker:
