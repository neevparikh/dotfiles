if [ -d "/opt/cuda/bin/" ]; then
  export PATH="/opt/cuda/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then #{{{2
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "/usr/local/cuda/bin/" ]; then #{{{2
  export PATH="/usr/local/cuda/bin:$PATH"
fi

if [ -d "/opt/cuda/bin/" ]; then #{{{2
  export PATH="/opt/cuda/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
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

if [ -d "$HOME/go/" ]; then #{{{2
  export PATH="$HOME/go/bin:$PATH"
  export GOPATH="$HOME/go:$HOME/repos/blockchain/"
fi

if [ -d "$HOME/.local/bin" ]; then #{{{2
  PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.mujoco/mujoco200_linux" ]; then #{{{2
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/neev/.mujoco/mujoco200_linux/bin
fi

if [ -d "$HOME/.mujoco/mujoco200" ]; then #{{{2
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/neev/.mujoco/mujoco200/bin
fi

if [ -d "$HOME/.mujoco/mjpro150" ]; then #{{{2
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/neev/.mujoco/mjpro150/bin
fi

if [ -d "/opt/cuda/extras/CUPTI/lib64" ]; then #{{{2
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cuda/extras/CUPTI/lib64
fi

if [ -d "/sys/class/backlight" ]; then #{{{2
  export BACKLIGHT_CARD=$(ls -1 /sys/class/backlight/)
fi

if command -v qt5ct >/dev/null 2>&1; then
  export QT_QPA_PLATFORMTHEME=qt5ct
fi

if command -v clang >/dev/null 2>&1; then
  export CC=clang
fi

if command -v clang++ >/dev/null 2>&1; then
  export CXX=clang++
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

export GDK_SCALE=1
export GDK_DPI_SCALE=1
export SHELLCHECK_OPTS="-e SC1090 -e 2001 -e SC2016 -e SC2139 -e SC2164"

