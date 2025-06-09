GIT_COLOR=022
SSH_COLOR=004

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$FG[$GIT_COLOR]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[$GIT_COLOR]%}]%{$reset_color%}" 
ZSH_THEME_GIT_PROMPT_CLEAN="]%{$reset_color%}"

git_custom_info() {
    git_prompt_info
}

remote_host_prompt () {
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "%{$FG[$SSH_COLOR]%}ssh->$(hostname)%{$reset_color%}"
  elif [ -f "/.dockerenv" ]; then
    echo "%{$FG[$SSH_COLOR]%}docker->$(hostname)%{$reset_color%}"
  else
    echo ""
  fi
}

PROMPT='%2~ »%b '
RPROMPT='$(git_custom_info) $(remote_host_prompt)'
