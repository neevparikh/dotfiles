if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -f "$HOME/.api_keys.env" ]; then 
  export $(cat ~/.api_keys.env | xargs)
fi

if [ -f "$HOME/.orbstack/shell/init.zsh" ]; then
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi
