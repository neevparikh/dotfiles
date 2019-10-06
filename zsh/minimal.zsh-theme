GIT_COLOR="red"
TIME_COLOR="magenta"
SSH_COLOR="cyan"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[$GIT_COLOR]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[$GIT_COLOR]%}]%{$reset_color%}" 
ZSH_THEME_GIT_PROMPT_CLEAN="]%{$reset_color%}"


local time="%{$fg[$TIME_COLOR]%}%D{%l:%M %P}%{$reset_color%}"

git_custom_info() {
    git_prompt_info
}

remote_host_prompt () {
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "%{$fg[$SSH_COLOR]%}$(hostname)"
  else
    echo ""
  fi
}

PROMPT='%2~ »%b '
RPROMPT='$(git_custom_info) $(remote_host_prompt)'
