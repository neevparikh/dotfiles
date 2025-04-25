eval "$(/opt/homebrew/bin/brew shellenv)"
if [ -f "$HOME/.api_keys.env" ]; then 
  export $(cat ~/.api_keys.env | xargs)
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
